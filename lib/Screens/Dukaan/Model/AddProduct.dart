class AddProduct {
  String _product_id;
  String _name;
  String _price;
  String _description;

  AddProduct(this._product_id, this._name, this._price, this._description);

  // Method to make GET parameters.
  String toParams() =>
      "?product_id=$_product_id&name=$_name&price=$_price&description=$_description";

}