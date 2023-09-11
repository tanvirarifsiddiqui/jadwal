class Admin{
  int admin_id;
  String admin_name;
  String admin_image;
  String admin_age;
  String admin_country;
  String admin_state;
  String admin_city;
  String admin_email;
  String admin_phone;
  String admin_address;
  String admin_password;
  int mosque_id;

  Admin(
      this.admin_id,
      this.admin_name,
      this.admin_image,
      this.admin_age,
      this.admin_country,
      this.admin_state,
      this.admin_city,
      this.admin_email,
      this.admin_phone,
      this.admin_address,
      this.admin_password,
      this.mosque_id
      );

  factory Admin.fromJson( Map<String,dynamic> json)=> Admin(
      int.parse(json["admin_id"]),
      json["admin_name"],
      json["admin_image"],
      json["admin_age"],
      json["admin_country"],
      json["admin_state"],
      json["admin_city"],
      json["admin_email"],
      json["admin_phone"],
      json["admin_address"],
      json["admin_password"],
      int.parse(json["mosque_id"])
  );

  Map<String,dynamic> toJson() =>{
    'admin_id' : admin_id.toString(),
    'admin_name' : admin_name,
    'admin_image' : admin_image,
    'admin_age' : admin_age.toString(),
    'admin_country' : admin_country,
    'admin_state' : admin_state,
    'admin_city' : admin_city,
    'admin_email' : admin_email,
    'admin_phone' : admin_phone,
    'admin_address' : admin_address,
    'admin_password' : admin_password,
    'mosque_id' : mosque_id.toString(),
  };
}