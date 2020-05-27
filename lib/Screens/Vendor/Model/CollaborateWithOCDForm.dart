class CollaborateWithOCDForm {
  String _company_name;
  String _company_link;
  String _event_type;
  String _phone_number;
  String _email_id;

  CollaborateWithOCDForm(this._company_name, this._company_link, this._event_type, this._phone_number, this._email_id);

  // Method to make GET parameters.
  String toParams() =>
      "?company_name=$_company_name&company_link=$_company_link&event_type=$_event_type&phone_number=$_phone_number&email_id=$_email_id";

}