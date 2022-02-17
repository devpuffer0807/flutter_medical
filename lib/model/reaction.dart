class Reaction {
  String id;
  String name;
  String onset_date;
  String outcome;
  String seriousness;
  String duration;
  String duration_time;
  String end_date;

  Reaction();

  Reaction.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        onset_date = json['onset_date'],
        outcome = json['outcome'],
        seriousness = json['seriousness'],
        duration = json['duration'],
        duration_time = json['duration_time'],
        end_date = json['end_date'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'onset_date': onset_date,
    'outcome': outcome,
    'seriousness':seriousness,
    'duration': duration,
    'duration_time': duration_time,
    'end_date': end_date
  };
}
