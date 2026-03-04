import 'package:flutter/foundation.dart';

enum SaleCustomerType { mijoz, optom }

@immutable
class SaleCustomerModel {
  final int id;
  final String fullName;
  final String? phone;
  final String? address;
  final String? socialType;
  final SaleCustomerType customerType;

  const SaleCustomerModel({
    required this.id,
    required this.fullName,
    this.phone,
    this.address,
    this.socialType,
    this.customerType = SaleCustomerType.mijoz,
  });

  SaleCustomerModel copyWith({
    int? id,
    String? fullName,
    String? phone,
    String? address,
    String? socialType,
    SaleCustomerType? customerType,
  }) {
    return SaleCustomerModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      socialType: socialType ?? this.socialType,
      customerType: customerType ?? this.customerType,
    );
  }

  String get typeLabel => customerType == SaleCustomerType.mijoz ? "Mijoz" : "Optom";
}