class User {
  int user_id;
  String user_name;
  String user_image;
  String user_age;
  String user_country;
  String user_state;
  String user_city;
  String user_address;
  String user_email;
  String user_password;


  User(
      this.user_id,
      this.user_name,
      this.user_image,
      this.user_age,
      this.user_country,
      this.user_state,
      this.user_city,
      this.user_address,
      this.user_email,
      this.user_password,
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
      int.parse(json["user_id"]),
      json["user_name"],
      json["user_image"],
      json["user_age"],
      json["user_country"],
      json["user_state"],
      json["user_city"],
      json["user_address"],
      json["user_email"],
      json["user_password"],

  );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['user_id'] = user_id.toString();
    data['user_name'] = user_name;
    data['user_image'] = user_image;
    data['user_age'] = user_age.toString();
    data['user_country'] = user_country;
    data['user_state'] = user_state;
    data['user_city'] = user_city;
    data['user_address'] = user_address;
    data['user_email'] = user_email;
    data['user_password'] = user_password;
    return data;
  }
}

