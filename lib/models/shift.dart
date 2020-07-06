class Shift {
  final DateTime _start;
  final DateTime _end;

  Shift(this._start, this._end);

  DateTime get start {
    return this._start;
  }

  DateTime get end {
    return this._end;
  }

  Shift.fromJson(Map<String, dynamic> json)
      : _start = DateTime.parse(json['start']),
        _end = DateTime.parse(json['end']);

  Map<String, dynamic> toJson() => {
        'start': _start.toString(),
        'end': _end.toString(),
      };
}
