import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:olam/features/customer/presentation/bloc/event.dart';

import '../bloc/customer_bloc.dart';
import '../bloc/customer_state.dart';
import '../widgets/customer_card.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {

  @override
  void initState() {
    super.initState();

    context.read<CustomerBloc>().add(
      GetCustomersEvent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios_new,color: Colors.white,)),
        toolbarHeight: 88,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFFB96D00),
                Color(0xFFD8921A),
                Color(0xFFE0A52C),
                Color(0xFFC97D08),
              ],
            ),
          ),
        ),
        titleSpacing: 0,
        title: Text("Mijozlar",style: TextStyle(fontSize: 20.sp,fontWeight: FontWeight.bold,color: Colors.white),),centerTitle: true,
      ),
      body: Column(
        children: [

          /// SEARCH
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Qidiruv",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (value) {
                context.read<CustomerBloc>().add(
                  GetCustomersEvent(q: value),
                );
              },
            ),
          ),

          /// LIST
          Expanded(
            child: BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {

                if (state is CustomerLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is CustomerLoaded) {
                  return ListView.builder(
                    itemCount: state.customers.length,
                    itemBuilder: (context, index) {

                      final customer = state.customers[index];

                      return CustomerCard(customer: customer);
                    },
                  );
                }

                if (state is CustomerError) {
                  return Center(
                    child: Text(state.message),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}