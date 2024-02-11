class Act {
  final String image;
  final String title;
  final String category;
  final String location;
  final int min_participants;
  final int price;
  String? id;

  Act({
    required this.image,
    required this.title,
    required this.category,
    required this.location,
    required this.min_participants,
    required this.price,
    this.id, // Allow id to be nullable in the constructor
  });

  // Factory constructor to create Act object from map
  factory Act.fromMap(Map<String, dynamic> map) {
    return Act(
      title: map['title'],
      image: map['image'],
      location: map['location'],
      price: map['price'],
      category: map['category'],
      min_participants: map['min_participants'],
    );
  }

  String? get getId => id;

  void setId(String? newId) {
    id = newId;
  }
}

