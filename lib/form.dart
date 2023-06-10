// Define a custom Form widget.
import 'package:flutter/material.dart';

class FormPengajuan extends StatefulWidget {
  @override
  FormPengajuanState createState() {
    return FormPengajuanState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class FormPengajuanState extends State<FormPengajuan> {
  final _formKey = GlobalKey<FormState>();
  DateTime now = new DateTime.now();
  TextEditingController dateTxtContFrom = TextEditingController();
  TextEditingController dateTxtContTo = TextEditingController();
  DateTime startDate, endDate;

  dateTimeRangePicker() async {
    DateTimeRange picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDateRange: DateTimeRange(
        end: DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day + 3),
        start: DateTime.now(),
      ),
    );
    setState(() {
      dateTxtContFrom.text =
          "${picked.start.year}-${picked.start.month}-${picked.start.day}";
      dateTxtContTo.text =
          "${picked.end.year}-${picked.end.month}-${picked.end.day}";
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // Build a Form widget using the _formKey created above.
    return Form(
        key: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: size.width,
                child: Row(
                  children: [
                    SizedBox(
                      width: size.width * 0.45,
                      child: TextFormField(
                        keyboardType: TextInputType.datetime,
                        controller: dateTxtContFrom,
                        readOnly: true,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.date_range),
                          labelText: 'Dari tanggal',
                          hintText: 'Cari',
                        ),
                        onTap: () => dateTimeRangePicker(),
                      ),
                    ),
                    // SizedBox(width: 10),
                    SizedBox(
                      width: size.width * 0.45,
                      child: TextFormField(
                        keyboardType: TextInputType.datetime,
                        controller: dateTxtContTo,
                        readOnly: true,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.date_range),
                          labelText: 'Hingga tanggal',
                          hintText: 'Cari',
                        ),
                        onTap: () => dateTimeRangePicker(),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text('Lampirkan Foto Dokumen Pendukung (Minimal 1)'),
              SizedBox(height: 10),
              Expanded(
                  child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 30,
                      primary: false,
                      children: [
                    Card(
                        child: TextButton.icon(
                            label: Text('Pilih Foto'),
                            icon: Icon(Icons.photo),
                            onPressed: () {})),
                    Card(
                        child: TextButton.icon(
                            label: Text('Pilih Foto'),
                            icon: Icon(Icons.photo),
                            onPressed: () {})),
                    Card(
                        child: TextButton.icon(
                            label: Text('Pilih Foto'),
                            icon: Icon(Icons.photo),
                            onPressed: () {})),
                    Card(
                        child: TextButton.icon(
                            label: Text('Pilih Foto'),
                            icon: Icon(Icons.photo),
                            onPressed: () {})),
                  ])),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: null
                    //  () {
                    //   // Validate returns true if the form is valid, otherwise false.
                    //   if (_formKey.currentState.validate()) {
                    //     // If the form is valid, display a snackbar. In the real world,
                    //     // you'd often call a server or save the information in a database.

                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //         SnackBar(content: Text('Processing Data')));
                    //   }
                    // }
                    ,
                    child: Text('SIMPAN (FITUR BELUM TERSEDIA)'),
                  ))
            ]));
  }
}
