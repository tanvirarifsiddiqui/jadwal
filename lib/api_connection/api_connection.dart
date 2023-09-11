class API{
  static const hostConnect = "http://192.168.0.100/api_jadwal";

  //Api jadwal
  static const hostConnectUser = "$hostConnect/user";

  //signUP user
  static const validateEmail = "$hostConnect/user/validate_email.php";
  static const signUp = "$hostConnect/user/signup.php";

  //login user
  static const login = "$hostConnect/user/login.php";
  static const userImage = "$hostConnect/images/user_images/";

  //mosque registration
  static const validateMosqueEmail = "$hostConnect/mosque/validate_email.php";
  static const registerMosque = "$hostConnect/mosque/registration.php";

  //mosque data
  static const getMosqueData = "$hostConnect/mosque/get_data.php";
  static const getSearchedMosqueData = "$hostConnect/mosque/search_mosque.php";
  static const mosqueImage = "$hostConnect/images/mosque_images/";
  static const updateMosqueTime = "$hostConnect/mosque/update_time.php";

  //signUP admin
  static const validateAdminEmail = "$hostConnect/admin/validate_email.php";
  static const validateAdminPhone = "$hostConnect/admin/validate_phone.php";
  static const signUpAdmin = "$hostConnect/admin/signup.php";

  //login admin
  static const loginAdmin = "$hostConnect/admin/login.php";
  static const adminImage = "$hostConnect/images/admin_images/";

  //Api world information
  static const hostConnectWorld = "$hostConnect/world";
  static const getCountries = "$hostConnect/world/get_countries.php";
  static const getStates = "$hostConnect/world/get_states.php";
  static const getCities = "$hostConnect/world/get_cities.php";


  //
}