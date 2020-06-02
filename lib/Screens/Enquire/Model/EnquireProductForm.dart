class EnquireProductForm {
  String _name;
  String _email_id;
  String _phone_number;
  String _company_name;
  String _product_id;

  EnquireProductForm(this._name, this._email_id, this._phone_number, this._company_name, this._product_id);

  // Method to make GET parameters.
  String toParams() =>
      "?name=$_name&email_id=$_email_id&phone_number=$_phone_number&company_name=$_company_name&product_id=$_product_id";

}