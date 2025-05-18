class AddressModel {
  final int? id;
  final String name;
  final String phoneCode;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String pincode;
  final String city;
  final String state;
  final String country;
  final String countryCode;
  final String? landmark;

  AddressModel({
    this.id,
    required this.name,
    required this.phoneCode,
    required this.phone,
    required this.addressLine1,
    required this.addressLine2,
    required this.pincode,
    required this.city,
    required this.state,
    required this.country,
    required this.countryCode,
    this.landmark,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      name: json['name'],
      phoneCode: json['phone_code'],
      phone: json['phone'],
      addressLine1: json['address_line1'],
      addressLine2: json['address_line2'],
      pincode: json['pincode'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      countryCode: json['country_code'],
      landmark: json['landmark'],
    );
  }

  Map<String, String> toJson() {
    final Map<String, String> data = {};

    if (id != null) data['id'] = id.toString();
    data['name'] = name;
    data['phone_code'] = phoneCode;
    data['phone'] = phone;
    data['address_line1'] = addressLine1;
    data['address_line2'] = addressLine2;
    data['pincode'] = pincode;
    data['city'] = city;
    data['state'] = state;
    data['country'] = country;
    data['country_code'] = countryCode;
    if (landmark != null) data['landmark'] = landmark!;

    return data;
  }
}
