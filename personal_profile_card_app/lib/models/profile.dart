class Profile {
  int? id;
  String name;
  String profession;
  String contact;
  String? imagePath; // path to profile image

  Profile({
    this.id,
    required this.name,
    required this.profession,
    required this.contact,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'profession': profession,
      'contact': contact,
      'imagePath': imagePath,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      name: map['name'],
      profession: map['profession'],
      contact: map['contact'],
      imagePath: map['imagePath'],
    );
  }
}
