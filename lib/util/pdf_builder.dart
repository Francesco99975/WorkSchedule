import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/shift.dart';
import '../providers/employee.dart';
import '../providers/settings.dart';
import 'date_functions.dart';

class PDFBuilder {
  final List<Employee> _emps;
  final String _dept;
  final BuildContext ctx;

  PDFBuilder(this._emps, this._dept, this.ctx);

  pw.Document createPDF(List<DateTime> week, Function checkWeek) {
    final timeFormat = Provider.of<Settings>(ctx, listen: false).timeFormat;
    DateFormat df = timeFormat ? DateFormat.Hm() : DateFormat.jm();
    var pdf = pw.Document();

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(32),
      build: (context) {
        return pw.Column(children: [
          pw.Text(
            "$_dept Schedule: " +
                DateFormat.yMMMMEEEEd().format(week[0]) +
                " - " +
                DateFormat.yMMMMEEEEd().format(week[6]),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 26),
          ),
          pw.SizedBox(height: 30),
          pw.Table(
              border: pw.TableBorder(color: PdfColor.fromInt(0)),
              children: [
                pw.TableRow(children: [
                  pw.Text("$_dept",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                ], verticalAlignment: pw.TableCellVerticalAlignment.middle),
                pw.TableRow(children: [
                  pw.Text("Employee",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ...week.map((e) {
                    return pw.Text(DateFormat("E d/MM").format(e),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center);
                  })
                ]),
                ..._emps.map((emp) {
                  var index = 0;
                  var shifts = emp.shifts
                      .where((sh) => checkWeek(sh.start))
                      .toList()
                        ..sort((a, b) => a.start.compareTo(b.start));
                  print(emp.firstName);
                  print("Shifts: ${shifts.length}");
                  return pw.TableRow(children: [
                    pw.Text("${emp.lastName}, ${emp.firstName}"),
                    ...week.map((day) {
                      Shift sh;
                      try {
                        sh = shifts[index];
                        print("Index: $index");
                        print("Day: ${day.weekday}");
                        if (compareDates(sh.start, day))
                          index++;
                        else
                          sh = null;
                      } catch (_) {
                        sh = null;
                      }
                      print(sh);
                      return sh != null
                          ? pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                  pw.Text(
                                      df.format(sh.start.toLocal()) + " - "),
                                  pw.Text(df.format(sh.end.toLocal())),
                                ])
                          : pw.Text("");
                    }).toList()
                  ]);
                }).toList()
              ])
        ]);
      },
    ));

    return pdf;
  }

  Future<void> savePdf(pw.Document pdf, DateTime startWeek) async {
    if (await Permission.storage.request().isGranted) {
      Directory appDocDir = Directory("/storage/emulated/0");
      var dirExists = await appDocDir.exists();
      if (Platform.isAndroid && dirExists) {
        Directory appStorage = Directory(appDocDir.path + "/work_schedule");
        var storeExists = await appStorage.exists();
        if (!storeExists) {
          await appStorage.create();
        }

        String appDocPath = appStorage.path;

        print(appDocPath);

        File file = File(
            "$appDocPath/${_dept.toLowerCase()}-schedule_${startWeek.day}${startWeek.month}${startWeek.year}.pdf");
        await file.writeAsBytes(pdf.save());
      }
    }
  }
}
