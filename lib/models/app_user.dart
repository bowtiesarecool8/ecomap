class AppUserData {
  String uid;
  String email;
  String username;
  String profileImageURL;
  List<dynamic> savedPlaces;
  bool isAdmin;
  DateTime lastLogin;

  AppUserData({
    required this.uid,
    required this.email,
    required this.username,
    required this.profileImageURL,
    required this.savedPlaces,
    required this.isAdmin,
    required this.lastLogin,
  });

  bool isSaved(String placeId) {
    return savedPlaces.contains(placeId);
  }

  void savePlace(String placeId) {
    savedPlaces.add(placeId);
  }

  void unsavePlace(String placeId) {
    savedPlaces.remove(placeId);
  }
}
