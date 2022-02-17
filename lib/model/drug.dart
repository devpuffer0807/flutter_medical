class Drug{
  String id;
  String name;
  String role;
  String dose;
  String dose_unit;
  String dose_route;
  String frequency;
  String each;
  String schedule;
  String start_date;
  String action_taken;
  String action_taken_date;
  String indication;
  String manufacturer;
  String origin;

  Drug();

  Drug.fromJson(Map<String, dynamic> json)
       : id = json['id'],
        name = json['name'],
        role = json['role'],
        dose = json['dose'],
        dose_unit = json['dose_unit'],
        dose_route = json['dose_route'],
        frequency = json['frequency'],
        each = json['each'],
        schedule = json['schedule'],
        start_date = json['start_date'],
        action_taken = json['action_taken'],
        action_taken_date = json['action_taken_date'],
        indication = json['indication'],
        manufacturer = json['manufacturer'],
        origin = json['origin'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'dose': dose,
    'dose_unit': dose_unit,
    'dose_route': dose_route,
    'frequency': frequency,
    'each': each,
    'schedule': schedule,
    'start_date': start_date,
    'action_taken': action_taken,
    'action_taken_date': action_taken_date,
    'indication': indication,
    'manufacturer': manufacturer,
    'origin': origin
  };
}