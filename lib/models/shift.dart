enum Status { Working, NotAvailable, Vacation }

class Shift {
  final DateTime _start;
  final DateTime _end;
  final Status status;

  Shift(this._start, this._end, {this.status = Status.Working});

  DateTime get start {
    return this._start;
  }

  DateTime get end {
    return this._end;
  }

  Shift.fromJson(Map<String, dynamic> json)
      : _start = DateTime.parse(json['start']),
        _end = DateTime.parse(json['end']),
        status = json['status'] == "working"
            ? Status.Working
            : json['status'] == "N/A" ? Status.NotAvailable : Status.Vacation;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json;
    switch (status) {
      case Status.Working:
        json = {
          'start': _start.toString(),
          'end': _end.toString(),
          'status': "working"
        };
        break;
      case Status.NotAvailable:
        json = {
          'start': _start.toString(),
          'end': _end.toString(),
          'status': "N/A"
        };
        break;
      case Status.Vacation:
        json = {
          'start': _start.toString(),
          'end': _end.toString(),
          'status': "vacation"
        };
        break;
    }
    return json;
  }
}
