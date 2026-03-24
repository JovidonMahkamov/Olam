abstract class CustomerEvent {}

class GetCustomersEvent extends CustomerEvent {
  final String? q;
  final bool? qarzdorlar;
  final int sahifa;

  GetCustomersEvent({
    this.q,
    this.qarzdorlar,
    this.sahifa = 1,
  });
}

class LoadMoreCustomersEvent extends CustomerEvent {}