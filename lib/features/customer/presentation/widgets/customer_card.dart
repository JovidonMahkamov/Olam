import 'package:flutter/material.dart';
import 'package:olam/features/customer/domain/entity/customer_entity.dart';

class CustomerCard extends StatelessWidget {
  final CustomerEntity customer;

  const CustomerCard({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: Colors.orange,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// NAME
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                customer.fish??"",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                customer.turi,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              )
            ],
          ),

          const SizedBox(height: 10),

          /// PHONE
          Row(
            children: [
              const Icon(Icons.phone, color: Colors.orange),
              const SizedBox(width: 8),
              Text(customer.telefon??""),
            ],
          ),

          const SizedBox(height: 8),

          /// ADDRESS
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.orange),
              const SizedBox(width: 8),
              Text(customer.manzil??""),
            ],
          ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  "${customer.qarzdorlik} \$",
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          ]
      ),
    );
  }
}