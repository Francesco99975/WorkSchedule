import 'dart:io';
import 'package:ext_storage/ext_storage.dart';
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
    var totalHours = _emps.fold(
        0.0,
        (prev, emp) =>
            prev + emp.getWeekHours(checkWeek.toString().contains('next')));

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
                  pw.Center(
                      child: pw.Text("Employee",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ...week.map((e) {
                    return pw.Center(
                        child: pw.Text(DateFormat("E d/MM").format(e),
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.center));
                  }),
                  pw.Center(
                      child: pw.Text("Hours",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.center))
                ]),
                pw.TableRow(children: [
                  pw.Text(""),
                  ...week.map((e) {
                    if (e.weekday == 7) {
                      return pw.Center(
                          child: pw.Text("TOT",
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.center));
                    } else {
                      return pw.Text("");
                    }
                  }),
                  pw.Center(
                      child: pw.Text("$totalHours",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.center)),
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
                          ? sh.status == Status.NotAvailable
                              ? pw.Center(
                                  child: pw.Text("N/A",
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold),
                                      textAlign: pw.TextAlign.center))
                              : sh.status == Status.Vacation
                                  ? pw.Center(
                                      child: pw.Text("VACATION",
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold),
                                          textAlign: pw.TextAlign.center))
                                  : pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.center,
                                      children: [
                                          pw.Text(
                                              df.format(sh.start.toLocal()) +
                                                  " - "),
                                          pw.Text(df.format(sh.end.toLocal())),
                                        ])
                          : pw.Text("");
                    }).toList(),
                    pw.Center(
                        child: pw.Text(
                            "${emp.getWeekHours(checkWeek.toString().contains('next'))}",
                            textAlign: pw.TextAlign.center)),
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
      Directory appDocDir = Directory(
          await ExtStorage.getExternalStoragePublicDirectory(
              ExtStorage.DIRECTORY_DOCUMENTS));
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
