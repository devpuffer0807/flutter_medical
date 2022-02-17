// https://github.com/Afonsocraposo/save-sharedpreferences/blob/master/lib/demo.dart
class Patient {
  String name;
  String gender;
  String age;
  String age_option;
  String weight;
  String height;
  String medical_notes;

  Patient();

  Patient.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        gender = json['gender'],
        age = json['age'],
        age_option = json['age_option'],
        weight = json['weight'],
        height = json['height'],
        medical_notes = json['medical_notes'];

  Map<String, dynamic> toJson() => {
    'name': name,
    'gender': gender,
    'age': age,
    'age_option': age_option,
    'weight': weight,
    'height': height,
    'medical_notes': medical_notes
  };
}