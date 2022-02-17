// https://github.com/Afonsocraposo/save-sharedpreferences/blob/master/lib/demo.dart
class Profile {
  String name;
  String phone;
  String city;
  String email;
  String org;
  String profession;

  Profile();

  Profile.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        phone = json['phone'],
        city = json['city'],
        email = json['email'],
        org = json['org'],
        profession = json['profession'];

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'city': city,
    'email': email,
    'org': org,
    'profession': profession
  };
}