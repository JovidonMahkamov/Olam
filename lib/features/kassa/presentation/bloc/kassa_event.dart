abstract class KassaEvent {
  const KassaEvent();
}

class GetKassalarE extends KassaEvent {
  const GetKassalarE();
}

class GetBugungiSotuvlarE extends KassaEvent {
  const GetBugungiSotuvlarE();
}

class GetQarzdorMijozlarE extends KassaEvent {
  const GetQarzdorMijozlarE();
}

class AddKirimE extends KassaEvent {
  final int kassaId;
  final int mijozId;
  final double summaUsd;
  final bool smsYuborildi;
  final String? izoh;

  const AddKirimE({
    required this.kassaId,
    required this.mijozId,
    required this.summaUsd,
    required this.smsYuborildi,
    this.izoh,
  });
}

class UpdateMijozQarzE extends KassaEvent {
  final int mijozId;
  final double yangiQarz;
  const UpdateMijozQarzE({required this.mijozId, required this.yangiQarz});
}