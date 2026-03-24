import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olam/features/customer/domain/entity/customer_entity.dart';
import 'package:olam/features/customer/domain/usecase/get_customer_use_case.dart';
import 'package:olam/features/customer/presentation/bloc/event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final GetCustomerUseCase getCustomersUseCase;

  int currentPage = 1;
  bool hasMore = true;

  List<CustomerEntity> customers = [];

  CustomerBloc(this.getCustomersUseCase) : super(CustomerInitial()) {
    on<GetCustomersEvent>(_getCustomers);
    on<LoadMoreCustomersEvent>(_loadMoreCustomers);
  }

  Future<void> _getCustomers(
      GetCustomersEvent event,
      Emitter<CustomerState> emit,
      ) async {
    emit(CustomerLoading());

    try {
      currentPage = 1;

      final result = await getCustomersUseCase(
        q: event.q,
        qarzdorlar: event.qarzdorlar,
        sahifa: currentPage,
      );

      customers = result.mijozlar;
      hasMore = result.meta.keyingisiBor;

      emit(CustomerLoaded(
        customers: customers,
        hasMore: hasMore,
      ));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _loadMoreCustomers(
      LoadMoreCustomersEvent event,
      Emitter<CustomerState> emit,
      ) async {
    if (!hasMore) return;

    try {
      currentPage++;

      final result = await getCustomersUseCase(
        sahifa: currentPage,
      );

      customers.addAll(result.mijozlar);
      hasMore = result.meta.keyingisiBor;

      emit(CustomerLoaded(
        customers: customers,
        hasMore: hasMore,
      ));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }
}