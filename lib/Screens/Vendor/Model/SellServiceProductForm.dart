class SellServiceProductForm {
  String _company_name;
  String _company_link;
  String _product_service_name;
  String _cost;
  String _phone_number;
  String _email_id;

  SellServiceProductForm(this._company_name, this._company_link, this._product_service_name, this._cost, this._phone_number, this._email_id);

  // Method to make GET parameters.
  String toParams() =>
      "?company_name=$_company_name&company_link=$_company_link&product_service_name=$_product_service_name&cost=$_cost&phone_number=$_phone_number&email_id=$_email_id";

}