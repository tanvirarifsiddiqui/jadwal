class API{
  static const hostConnect = "http://172.17.7.207/api_jadwal";

  //Api jadwal
  static const hostConnectUser = "$hostConnect/user";

  //signUP user
  static const validateEmail = "$hostConnect/user/validate_email.php";
  static const signUp = "$hostConnect/user/signup.php";

  //login user
  static const login = "$hostConnect/user/login.php";

  //user operation
  static const userImage = "$hostConnect/images/user_images/";
  static const getConnectionStatus = "$hostConnect/user/user_operation/get_connection.php";
  static const setConnectionStatus = "$hostConnect/user/user_operation/set_connection.php";
  static const setUserHomeMosqueOrder = "$hostConnect/user/user_operation/user_home_mosque_order.php";
  static const getSearchedMosqueData = "$hostConnect/mosque/search_mosque.php";
  static const getUserHomeMosqueData = "$hostConnect/mosque/user_home_mosque.php";
  static const storeUserToken = "$hostConnect/user/store_user_token.php";
  static const deleteUserToken = "$hostConnect/user/delete_user_token.php";
  static const fetchAdminToken = "$hostConnect/admin/fetch_admin_tokens.php";
  static const getNotifications = "$hostConnect/user/get_notifications.php";

  //announcements
  static const getAnnouncements = "$hostConnect/announcements/get_announcements.php";
  static const sendAnnouncements = "$hostConnect/announcements/send_announcement.php";
  static const getUserChatMosqueData = "$hostConnect/announcements/get_user_chat_Mosque_data.php";

  //mosque registration
  static const validateMosqueEmail = "$hostConnect/mosque/validate_email.php";
  static const registerMosque = "$hostConnect/mosque/registration.php";

  //mosque data
  static const getMosqueData = "$hostConnect/mosque/get_data.php";
  static const getMosqueDataById = "$hostConnect/mosque/get_data_by_id.php";

  //admin operation
  static const mosqueImage = "$hostConnect/images/mosque_images/";
  static const updateMosqueTime = "$hostConnect/mosque/update_time.php";
  static const storeAdminToken = "$hostConnect/admin/store_admin_token.php";
  static const deleteAdminToken = "$hostConnect/admin/delete_admin_token.php";
  static const fetchUserToken = "$hostConnect/user/fetch_user_tokens.php";
  static const getAdminNotifications = "$hostConnect/admin/get_admin_notifications.php";

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