import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/shift.dart';
import '../providers/employee.dart';
import '../screens/shift_maker_screen.dart';
import '../util/date_functions.dart';

class EmployeeTimeItem extends StatelessWidget {
  final DateTime _selectedDate;
  final DateFormat df;

  EmployeeTimeItem(this._selectedDate, this.df);
  @override
  Widget build(BuildContext context) {
    final emp = Provider.of<Employee>(context);
    Shift shift;
    try {
      shift = emp.shifts
          .where((sh) => compareDates(sh.start, _selectedDate))
          .toList()[0];
    } catch (_) {
      shift = null;
    }
    return Card(
      elevation: 5,
      child: ListTile(
        title: Text("${emp.firstName} ${emp.lastName}"),
        subtitle: Text(shift == null
            ? "OFF WORK"
            : shift.status == Status.NotAvailable
                ? "N/A"
                : shift.status == Status.Vacation
                    ? "Vacation"
                    : df.format(shift.start) +
                        " - " +
                        df.format(shift.end) +
                        " " +
                        DateFormat.EEEE().format(shift.end)),
        trailing: IconButton(
            icon: Icon(Icons.schedule),
            color: Color(emp.color),
            onPressed: () async {
              final value = await Navigator.of(context)
                  .pushNamed(ShiftMakerScreen.ROUTE_NAME, arguments: {
                'id': emp.id,
                'date': _selectedDate,
                'timeFormat': df
              });

              await emp.update(value);
            }),
      ),
    );
  }
}
