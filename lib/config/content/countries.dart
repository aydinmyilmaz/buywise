class Countries {
  static const List<Map<String, String>> list = [
    {'name': 'United States', 'code': 'US', 'currency': 'USD', 'symbol': r'$'},
    {'name': 'United Kingdom', 'code': 'GB', 'currency': 'GBP', 'symbol': '£'},
    {'name': 'Germany', 'code': 'DE', 'currency': 'EUR', 'symbol': '€'},
    {'name': 'France', 'code': 'FR', 'currency': 'EUR', 'symbol': '€'},
    {'name': 'Netherlands', 'code': 'NL', 'currency': 'EUR', 'symbol': '€'},
    {'name': 'Turkey', 'code': 'TR', 'currency': 'TRY', 'symbol': '₺'},
    {'name': 'Canada', 'code': 'CA', 'currency': 'CAD', 'symbol': r'$'},
    {'name': 'Australia', 'code': 'AU', 'currency': 'AUD', 'symbol': r'$'},
    {'name': 'Japan', 'code': 'JP', 'currency': 'JPY', 'symbol': '¥'},
    {'name': 'India', 'code': 'IN', 'currency': 'INR', 'symbol': '₹'},
    {'name': 'Brazil', 'code': 'BR', 'currency': 'BRL', 'symbol': r'R$'},
    {'name': 'Mexico', 'code': 'MX', 'currency': 'MXN', 'symbol': r'$'},
    {'name': 'Spain', 'code': 'ES', 'currency': 'EUR', 'symbol': '€'},
    {'name': 'Italy', 'code': 'IT', 'currency': 'EUR', 'symbol': '€'},
    {'name': 'South Korea', 'code': 'KR', 'currency': 'KRW', 'symbol': '₩'},
    {'name': 'Other', 'code': 'XX', 'currency': 'USD', 'symbol': r'$'},
  ];

  static Map<String, String>? getByCode(String code) {
    return list.firstWhere(
      (c) => c['code'] == code,
      orElse: () => list.last,
    );
  }

  static Map<String, String>? getByName(String name) {
    return list.firstWhere(
      (c) => c['name'] == name,
      orElse: () => list.last,
    );
  }
}
