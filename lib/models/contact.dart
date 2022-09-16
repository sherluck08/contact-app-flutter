class Contact extends Comparable {
  final int id;
  final String name;
  final int phoneNumber;

  Contact({
    required this.id,
    required this.name,
    required this.phoneNumber,
  });

  Contact.fromRow(Map<String, Object?> row)
      : id = row['ID'] as int,
        name = row['NAME'] as String,
        phoneNumber = row['PHONE_NUMBER'] as int;

  @override
  int compareTo(covariant Contact other) => id.compareTo(other.id);

  @override
  bool operator ==(covariant Contact other) => id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Person, id=$id, name=$name, phone=$phoneNumber';
}
