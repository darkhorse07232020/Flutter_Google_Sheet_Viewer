import 'dart:ui';
import 'package:meena_supplies/authentication/auth_manager.dart';
import 'package:meena_supplies/domain/model/DocImageData.dart';
import 'package:meena_supplies/other/my_client.dart';
import 'package:meena_supplies/ui/routing/router.dart';
import 'package:meena_supplies/ui/widgets/progress_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/docs/v1.dart' as docsV1;
import 'package:kt_dart/collection.dart';
import 'package:kt_dart/kt.dart';

class DocumentPage extends StatefulWidget {
  final String fileId;

  DocumentPage({Key key, this.fileId}) : super(key: key);

  @override
  _DocumentPageState createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  GoogleSignInAccount _currentUser;
  List<docsV1.StructuralElement> _listItems = [];
  Map<String, DocImageData> _imagesData = {};
  bool _contentLoaded = false;
  String _documentTitle = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.fileId);
    return Scaffold(
      appBar: AppBar(
        title: Text(_documentTitle),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: _contentLoaded
                ? ListView.builder(
                    itemBuilder: (context, index) {
                      final element = _listItems[index];
                      return _elementToWidget(element);
                    },
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _listItems.length,
                  )
                : Stack(
                    children: <Widget>[
                      Align(
                        child: ProgressLoaderWidget(width: 50.0, height: 50.0),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadDocument() async {
    if (_currentUser == null) return;

    GoogleSignInAuthentication authentication =
        await _currentUser.authentication;
    print('authentication: $authentication');
    final client = MyClient(defaultHeaders: {
      'Authorization': 'Bearer ${authentication.accessToken}'
    });

    final docsApi = docsV1.DocsApi(client);
    var document = await docsApi.documents.get(widget.fileId);
    print('document.title: ${document.title}');
    print('content.length: ${document.body.content.length}');
    _parseDocument(document);
  }

  Future<void> _parseDocument(docsV1.Document document) async {
    _documentTitle = document.title;
    var content = KtList.from(document.body.content);

    final elements = content
        .mapNotNull(
          (element) => (element?.paragraph?.elements != null ||
                  element?.paragraph?.positionedObjectIds != null)
              ? element
              : null,
        )
        .asList();

    var inlineObjects = emptyMap<String, DocImageData>();
    if (document.inlineObjects?.isNotEmpty == true) {
      inlineObjects = KtMap.from(document.inlineObjects).map((inlineObject) {
        var embeddedObject =
            inlineObject.value.inlineObjectProperties.embeddedObject;
        return KtPair(
          inlineObject.key,
          DocImageData(
            url: embeddedObject.imageProperties.contentUri,
            width: embeddedObject.size.width.magnitude,
            height: embeddedObject.size.height.magnitude,
          ),
        );
      }).associate((pair) => pair);
    }

    var positionedObjects = emptyMap<String, DocImageData>();
    if (document.positionedObjects?.isNotEmpty == true) {
      positionedObjects =
          KtMap.from(document.positionedObjects).map((positionedObject) {
        var embeddedObject =
            positionedObject.value.positionedObjectProperties.embeddedObject;
        return KtPair(
          positionedObject.key,
          DocImageData(
            url: embeddedObject.imageProperties.contentUri,
            width: embeddedObject.size.width.magnitude,
            height: embeddedObject.size.height.magnitude,
          ),
        );
      }).associate((pair) => pair);
    }

    setState(() {
      _listItems = elements;
      _imagesData = inlineObjects.plus(positionedObjects).asMap();
      _contentLoaded = true;
    });
  }

  Widget _elementToWidget(docsV1.StructuralElement element) {
    final alignment =
        _getAlignment(element.paragraph.paragraphStyle?.alignment);
    final paragraphSpans = KtList.from(element.paragraph.elements)
        .mapNotNull((element) => element?.textRun)
        .map(
      (textRun) {
        if (textRun.textStyle != null) {
          return TextSpan(
            text: textRun.content,
            style: _getTextStyle(
              element.paragraph.paragraphStyle?.namedStyleType,
              textRun.textStyle,
            ),
          );
        } else {
          return TextSpan(text: textRun.content);
        }
      },
    );
    var paragraphText = paragraphSpans.isNotEmpty()
        ? Container(
            width: double.infinity,
            child: RichText(
              textAlign: alignment,
              text: TextSpan(
                children: paragraphSpans.asList(),
                style: TextStyle(color: Colors.black),
              ),
            ),
          )
        : null;

    var paragraphInlineImages = [];
    if (element.paragraph.elements != null) {
      paragraphInlineImages = KtList.from(element.paragraph.elements)
          .mapNotNull((element) => element.inlineObjectElement?.inlineObjectId)
          .map((String objectId) => _imagesData[objectId])
          .map((DocImageData imgData) {
        return Image.network(
          imgData.url,
          width: imgData.width,
          height: imgData.height,
        );
      }).asList();
    }

    var paragraphPositionedImages = [];
    if (element.paragraph.positionedObjectIds != null) {
      paragraphPositionedImages =
          KtList.from(element.paragraph.positionedObjectIds)
              .map((String objectId) {
        return _imagesData[objectId];
      }).map((DocImageData imgData) {
        return Image.network(
          imgData.url,
          width: imgData.width,
          height: imgData.height,
        );
      }).asList();
    }

    final hasImages = (paragraphInlineImages.isNotEmpty == true) ||
        (paragraphPositionedImages.isNotEmpty == true);

    return hasImages
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ...paragraphInlineImages,
              ...paragraphPositionedImages,
              if (paragraphText != null) paragraphText,
            ],
          )
        : (paragraphText != null)
            ? paragraphText
            : Container();
  }

  TextStyle _getTextStyle(String paragraphStyle, docsV1.TextStyle textStyle) {
    final fontSize = _getFontSize(paragraphStyle);

    final foregroundColor = textStyle?.foregroundColor?.color?.rgbColor;
    final backgroundColor = textStyle?.backgroundColor?.color?.rgbColor;
    Color textColor;
    if (foregroundColor != null) {
      textColor = colorFromRGBO(foregroundColor);
    } else {
      textColor =
          paragraphStyle == 'SUBTITLE' ? Colors.black.withOpacity(0.5) : null;
    }
    Color textBgColor;
    if (backgroundColor != null) {
      textBgColor = colorFromRGBO(backgroundColor);
    }

    return TextStyle(
      fontSize: fontSize,
      color: textColor,
      backgroundColor: textBgColor,
      fontWeight: textStyle.bold == true ? FontWeight.bold : null,
      fontStyle: textStyle.italic == true ? FontStyle.italic : null,
      decoration: textStyle.underline == true ? TextDecoration.underline : null,
    );
  }

  Color colorFromRGBO(docsV1.RgbColor foregroundColor) {
    return Color.fromRGBO(
      ((foregroundColor.red ?? 0) * 255).toInt(),
      ((foregroundColor.green ?? 0) * 255).toInt(),
      ((foregroundColor.blue ?? 0) * 255).toInt(),
      1,
    );
  }

  double _getFontSize(String styleType) {
    switch (styleType) {
      case 'TITLE':
        return 30.0;
      case 'SUBTITLE':
        return 16.0;
      case 'HEADING_1':
        return 24.0;
      case 'HEADING_2':
        return 22.0;
      case 'HEADING_3':
        return 20.0;
      case 'HEADING_4':
        return 19.0;
      case 'HEADING_5':
        return 18.0;
      case 'HEADING_6':
        return 17.0;
      default:
        return null;
    }
  }

  TextAlign _getAlignment(String alignment) {
    switch (alignment) {
      case 'START':
        return TextAlign.left;
      case 'END':
        return TextAlign.right;
      case 'CENTER':
        return TextAlign.center;
      case 'JUSTIFIED':
        return TextAlign.justify;
      default:
        return TextAlign.left;
    }
  }
}
