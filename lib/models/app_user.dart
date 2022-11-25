class AppUserData {
  String uid;
  String email;
  List<dynamic> savedPlaces;
  bool isAdmin;

  AppUserData({
    required this.uid,
    required this.email,
    required this.savedPlaces,
    required this.isAdmin,
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
