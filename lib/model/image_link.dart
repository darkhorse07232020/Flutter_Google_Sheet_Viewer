class SheetData {
  String sku;
  String image;
  String isMain;
  String uploadDate;

  SheetData(
    this.sku,
    this.image,
    this.isMain,
    this.uploadDate,
  );

  factory SheetData.fromJson(dynamic json) {
    return SheetData(
      "${json['SKU']}",
      "${json['Image']}",
      "${json['IsMain']}",
      "${json['UploadDate']}",
    );
  }
}
