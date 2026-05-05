
import 'package:olam/features/customer/domain/entity/customer_entity.dart';

class CustomerModel extends CustomerEntity {
  CustomerModel({
    required super.id,
     super.fish,
    required super.turi,
     super.telefon,
     super.manzil,
    required super.qarzdorlik,
    required super.faol,
    required super.yaratilgan,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      fish: json['fish'],
      turi: json['turi'],
      telefon: json['telefon'],
      manzil: json['manzil'],
      qarzdorlik: json['qarzdorlik'],
      faol: json['faol'],
      yaratilgan: json['yaratilgan'],
    );
  }
}