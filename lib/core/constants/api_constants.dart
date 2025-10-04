class ApiConstants {
  static const String baseUrl = "http://13.232.161.127:8080/api";

  static const String register = "/auth/register";
  static const String login = "/auth/login";

  static const String updateUser = "/users";
  static const String loggedInUser = "/users/current";
  static const String createOrder = '/orders';



  static const String stadiaApiKey = 'eef70c63-704f-42a5-bfdf-97387be69aa1';
  static const String stadiaTileUrl =
      'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png?api_key=$stadiaApiKey';

  static String osmSearchUrl(String query) =>
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5';

  static String osmReverseGeocodeUrl(double lat, double lon) =>
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon';

  static String osrmRouteUrl(double startLon, double startLat, double endLon, double endLat) =>
      'http://router.project-osrm.org/route/v1/driving/$startLon,$startLat;$endLon,$endLat?overview=full&geometries=geojson';
}
