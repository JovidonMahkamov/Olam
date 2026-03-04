enum PayType { naqd, terminal, click }

extension PayTypeX on PayType {
  String get label {
    switch (this) {
      case PayType.naqd:
        return "Naqd";
      case PayType.terminal:
        return "Terminal";
      case PayType.click:
        return "Click";
    }
  }
}