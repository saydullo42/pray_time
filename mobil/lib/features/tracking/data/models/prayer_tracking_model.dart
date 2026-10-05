/// A single day's tracked status per prayer, e.g. { "Bomdod": true, ... }.
class DailyTrackingModel {
  const DailyTrackingModel({required this.date, required this.statuses});

  final DateTime date;
  final Map<String, bool> statuses;

  int get completedCount => statuses.values.where((done) => done).length;

  factory DailyTrackingModel.fromJson(Map<String, dynamic> json) {
    final rawStatuses = json['statuses'] as Map<String, dynamic>;
    return DailyTrackingModel(
      date: DateTime.parse(json['date'] as String),
      statuses: rawStatuses.map((key, value) => MapEntry(key, value as bool)),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String().split('T').first,
        'statuses': statuses,
      };
}
