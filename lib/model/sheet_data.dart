class SheetData {
  String orderId;
  String referenceNumber;
  String customerBuyerPhoneNumber;
  String customerCompany;
  String shippingCustomerName;
  String shippingAddress1;
  String shippingAddress2;
  String shippingAddress3;
  String shippingTown;
  String shippingRegion;
  String shippingPostcode;
  String shippingCountry;
  String receivedDate;
  String shippingCost;
  String orderTotal;
  String currency;
  String paid;
  String status;
  String subSource;
  String shippingServiceName;
  String channelBuyerName;
  String paymentMethod;
  String sku;
  String itemTitle;
  String quantity;
  String unitCost;
  String lineTotal;
  String orderNotes;
  String onHold;
  String originalTitle;

  SheetData(
    this.orderId,
    this.referenceNumber,
    this.customerBuyerPhoneNumber,
    this.customerCompany,
    this.shippingCustomerName,
    this.shippingAddress1,
    this.shippingAddress2,
    this.shippingAddress3,
    this.shippingTown,
    this.shippingRegion,
    this.shippingPostcode,
    this.shippingCountry,
    this.receivedDate,
    this.shippingCost,
    this.orderTotal,
    this.currency,
    this.paid,
    this.status,
    this.subSource,
    this.shippingServiceName,
    this.channelBuyerName,
    this.paymentMethod,
    this.sku,
    this.itemTitle,
    this.quantity,
    this.unitCost,
    this.lineTotal,
    this.orderNotes,
    this.onHold,
    this.originalTitle,
  );

  factory SheetData.fromJson(dynamic json) {
    return SheetData(
      "${json['Order Id']}",
      "${json['Reference number']}",
      "${json['Customer buyer phone number']}",
      "${json['Customer company']}",
      "${json['Shipping customer name']}",
      "${json['Shipping address 1']}",
      "${json['Shipping address 2']}",
      "${json['Shipping address 3']}",
      "${json['Shipping town']}",
      "${json['Shipping region']}",
      "${json['Shipping postcode']}",
      "${json['Shipping country']}",
      "${json['Received date']}",
      "${json['Shipping cost']}",
      "${json['Order total']}",
      "${json['Currency']}",
      "${json['Paid']}",
      "${json['Status']}",
      "${json['SubSource']}",
      "${json['Shipping service name']}",
      "${json['Channel buyer name']}",
      "${json['Payment method']}",
      "${json['SKU']}",
      "${json['Item Title']}",
      "${json['Quantity']}",
      "${json['Unit Cost']}",
      "${json['Line total']}",
      "${json['Order Notes']}",
      "${json['On hold']}",
      "${json['Original title']}",
    );
  }
}
