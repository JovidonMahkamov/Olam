class CustomerModel {
  final String id;
  final String name;
  final String? phone;
  final String? address;
  final String roleText; // "Mijoz"

  const CustomerModel({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.roleText = "Mijoz",
  });
}