// import 'package:animated_splash_screen/animated_splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:page_transition/page_transition.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: AnimatedSplashScreen(
//         splash: Icon(Icons.person),
//         pageTransitionType: PageTransitionType.scale,
//         nextScreen: HomePage()
//       ),
//     );
//   }
// }
//
// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }

import 'dart:convert';
import 'dart:ui';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum EditType {typeHousePart,typeName}

class SmallJob{
  int count = 0;
  int value = 0;
  String name = '';

  _addOneCount(){count++;}
  _removeOneCount(){count--;}
  _resetCount(){count = 0;}
  _setCount(int arg_count){count = arg_count;}
  _getCount(){return count;}
  _getWholeValue(){return count*value;}
  _getName(){return name;}

  SmallJob(this.value, [this.name = 'NONAME']);
}

class Person {

  String name='NO_NAME';
  String housePart='NO_PART';
  DateTime deadline = DateTime.now();
  int daysLeft=0;
  List<SmallJob> smallJobsArray = [SmallJob(3,'zmywarka'),SmallJob(2,'ociekacz'),SmallJob(2,'śmieci_wymiana'),
    SmallJob(1,'śmieci_wyrzucenie'),SmallJob(2,'koty_jedzonko'),SmallJob(2,'koty_sprzątanie'),SmallJob(1,'papuga'),
  SmallJob(2,'obiad_dod'),SmallJob(2,'ciasto'),SmallJob(2,'zakupy_małe'),SmallJob(4,'zakupy_Duże')];
  DateTime lastSummary = DateTime.now();

}

//DODAĆ HISTORIĘ PRAC MIESIĘCZNĄ/TYGODNIOWĄ, ekran ładowania?

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AnimatedSplashScreen
        (splash: const ImageIcon(
        AssetImage('files/logo_1.png'),
        size: 100,
        color: Colors.white,
      ),
        //pageTransitionType: PageTransitionType.scale, //Z TYM JEST BŁĄD STACK OVERFLOW ZAPYTANE
        splashIconSize: 100,
        duration: 2500,
        splashTransition: SplashTransition.fadeTransition,
        backgroundColor: const Color(0xee050565),
        nextScreen: const HomePage()
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{

  Person person = Person();
  String dniOdmiana = ' dni';
  Color deadlineTextColor = Colors.green;

  void _setInitialData(){
    person.name = "NO_NAME";
    person.housePart = "NO_PART";
    person.deadline = DateTime.now();
    person.daysLeft = 0;
    person.lastSummary = DateTime.now();

    for(int i = 0; i < person.smallJobsArray.length; i++){
      person.smallJobsArray[i]._resetCount();
    }

    setState(() {});
    _writeData();
  }

  Future<String>_getDirPath() async {
    final _dir = await getApplicationDocumentsDirectory();
    return _dir.path;
  }

  Future<void> _readData() async {
    final _dirPath = await _getDirPath();
    final _myFile = File('$_dirPath/data.txt');
    final _data = await _myFile.readAsLines(encoding: utf8);
    setState(() {
      person.name = _data[0];
      person.housePart = _data[1];
      person.deadline = DateTime.parse(_data[2]);
      person.lastSummary = DateTime.parse(_data[3]);
      person.daysLeft = daysBetween(DateTime.now(), person.deadline);


      for(int i = 0; i < person.smallJobsArray.length; i++) {
        person.smallJobsArray[i]._setCount(int.parse(_data[i+4]));
      }

      //person.zmywarka._setCount(int.parse(_data[4]));
      //person.smieci._setCount(int.parse(_data[5]));
      //person.kotyJedzenie._setCount(int.parse(_data[6]));
      //person.kotySprzatanie._setCount(int.parse(_data[7]));
    });
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    int pom = (to.difference(from).inHours / 24).round();
    if (pom==1){dniOdmiana = ' dzień'; deadlineTextColor = Colors.deepOrange;}
    else {
      dniOdmiana = ' dni';
      if(pom>2){deadlineTextColor = Colors.green;}
      else if(pom==2){deadlineTextColor = Colors.orange;}
      else {deadlineTextColor = Colors.red.shade900;}
    }
    return pom;
  }

  Future<void> _writeData() async {
    final _dirPath = await _getDirPath();

    final _myFile = File('$_dirPath/data.txt');
    // If data.txt doesn't exist, it will be created automatically

    await _myFile.writeAsString(person.name + '\n');
    await _myFile.writeAsString(person.housePart + '\n',mode: FileMode.append);
    await _myFile.writeAsString(person.deadline.toString() + '\n',mode: FileMode.append);
    await _myFile.writeAsString(person.lastSummary.toString() + '\n',mode: FileMode.append);

    for(int i = 0; i < person.smallJobsArray.length; i++) {
      await _myFile.writeAsString(person.smallJobsArray[i]._getCount().toString() + '\n',mode: FileMode.append);
    }
   // await _myFile.writeAsString(person.zmywarka._getCount().toString() + '\n',mode: FileMode.append);
    //await _myFile.writeAsString(person.smieci._getCount().toString() + '\n',mode: FileMode.append);
    //await _myFile.writeAsString(person.kotyJedzenie._getCount().toString() + '\n',mode: FileMode.append);
    //await _myFile.writeAsString(person.kotySprzatanie._getCount().toString() + '\n',mode: FileMode.append);
  }

  void _changeNameNavigate(BuildContext context) async{
    String lastdata = person.name;
    person.name = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditionPage(person.name, EditType.typeName)));
    setState(() {});
    Navigator.pop(context);
    if(person.name != lastdata) {
      Fluttertoast.showToast(
          msg: "Pomyślnie zmieniono imię",
          toastLength: Toast.LENGTH_SHORT,
      );
      _writeData();
    }
  }

  void _changeHousePartNavigate(BuildContext context) async{
    String lastdata = person.housePart;
    person.housePart = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditionPage(person.housePart, EditType.typeHousePart)));
    setState(() {});
    Navigator.pop(context);
    if(person.housePart != lastdata) {
      Fluttertoast.showToast(
        msg: "Pomyślnie zmieniono część domu",
        toastLength: Toast.LENGTH_SHORT,
      );
      _writeData();
    }
  }

  void _addSmallChoreNavigate(BuildContext context) async{
    String? newSmallChoreName = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddingPage('DODAWANIE PRACY', person)));
    //newSmallChore przyjmuje wartość wybraną w AddingPage lub null (gdy gracz wyjdzie strzałką)
    newSmallChoreName ??= 'NONAME';
    //gdy null to przyjmuje wartość NONAME

    int listIndex = person.smallJobsArray.indexWhere((element) => element.name == newSmallChoreName);
    if(listIndex != -1){
      person.smallJobsArray[listIndex]._addOneCount();
      Fluttertoast.showToast(
        msg: "Pomyślnie dodano: " + person.smallJobsArray[listIndex].name,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
      setState(() {});
      _writeData();
  }

  void _substractSmallChoreNavigate(BuildContext context) async{
    String? newSmallChoreName = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddingPage('USUWANIE PRACY', person)));
    //newSmallChore przyjmuje wartość wybraną w AddingPage lub null (gdy gracz wyjdzie strzałką)
    newSmallChoreName ??= 'NONAME';
    //gdy null to przyjmuje wartość none

    int listIndex = person.smallJobsArray.indexWhere((element) => element.name == newSmallChoreName);
    if(listIndex != -1){
      if(person.smallJobsArray[listIndex]._getCount()>0) {
        person.smallJobsArray[listIndex]._removeOneCount();
        Fluttertoast.showToast(
          msg: "Pomyślnie usunięto: " + person.smallJobsArray[listIndex].name,
          toastLength: Toast.LENGTH_SHORT,
        );
      }
      else{
        Fluttertoast.showToast(
          msg: 'OSIĄGNIĘTO ILOŚĆ MINIMALNĄ',
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    }
    setState(() {});
    _writeData();
  }

  void _summaryPageNavigate(BuildContext context) async{
    int points = _countPoints();
    bool ifReset = false;
    ifReset = await Navigator.push(context, MaterialPageRoute(builder: (context) => SummaryPage(points,person.lastSummary)));
    if(ifReset){
      for(int i = 0; i < person.smallJobsArray.length; i++){
        person.smallJobsArray[i]._resetCount();
      }
      setState(() {});
      _writeData();
    }

  }

  int _countPoints(){
    int points = 0;
    for(int i = 0; i < person.smallJobsArray.length; i++){
      points= (points+person.smallJobsArray[i]._getWholeValue()) as int;
      //trzeba rzutować na inta, bo dart zamienia inty w num więc nie wie czy to nie doouble np
    };
    return points;
  }

  Future _pickDate(BuildContext context) async {

    DateTime initialDate;
    if(person.deadline.isBefore(DateTime.now())){
      initialDate = DateTime.now();
    }
    else {
      initialDate = person.deadline;
    }

    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: initialDate.add(const Duration(days: 30)),
    );

    if(newDate != null){
      if(newDate != initialDate) {
        person.deadline = newDate;
        person.daysLeft = daysBetween(DateTime.now(), person.deadline);
        setState(() {});
        Fluttertoast.showToast(
          msg: "Pomyślnie zmieniono deadline",
          toastLength: Toast.LENGTH_SHORT,
        );
        _writeData();
      }
      else{
        Fluttertoast.showToast(
          msg: "Wybrałeś tę samą datę co poprzednio",
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    }
    Navigator.pop(context);
  }

  Future<void> _dataCleanDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('OSTRZEŻENIE!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.redAccent.shade700,),)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:const [
              Text('Czy na pewno chcesz usunąć wszystkie dane?',textAlign: TextAlign.center,),
              SizedBox(height: 15),
              Text('TA OPERACJA JEST NIEODWRACALNA'),
          ]
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('NIE'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('TAK'),
              onPressed: () {
                _setInitialData();
                Navigator.of(context).pop();
                Navigator.pop(context);
                Fluttertoast.showToast(
                  msg: "Twoje dane zostały usunięte",
                  toastLength: Toast.LENGTH_SHORT,
                );
              },
            ),
          ],
        );
      },
    );
  }

  _HomePageState(){
    _readData();
  }

  String deadlineText(){
    if(person.daysLeft >=0) {
      return person.daysLeft.toString() + dniOdmiana;
    }
    else
      {return 'PRZEKROCZONO';}
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
              'GŁÓWNE INFORMACJE',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xee050565),
          ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(
                height: 88,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color(0xee2d2dd7),
                  ),
                  child: Text(
                      'Edytuj Twoje Dane',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white
                    ),
                  ),
                ),
              ),
              ListTile(
                title: const Text('Imię i nazwisko'),
                onTap: () {
                  _changeNameNavigate(context);
                },
              ),
              ListTile(
                title: const Text('Część domu do sprzątnięcia'),
                onTap: () {
                  _changeHousePartNavigate(context);
                },
              ),
              ListTile(
                title: const Text('Nowy deadline'),
                onTap: () {
                  _pickDate(context);
                },
              ),
              ListTile(
                title: Text(
                  'WYCZYŚĆ WSZYSTKIE DANE',
                  style: TextStyle(
                    color: Colors.redAccent.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  _dataCleanDialog();
                },
              ),
            ],
          )
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(30,40,30,40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                  'IMIĘ i NAZWISKO'
              ),
              const SizedBox(height: 10),
              Text(
                  person.name,
                style: const TextStyle(
                  fontSize: 25,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                  'CZĘŚĆ DOMU DO SPRZĄTNIĘCIA'
              ),
              const SizedBox(height: 10),
              Text(
                person.housePart,
                style: const TextStyle(
                  fontSize: 25,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                  'DEADLINE'
              ),
              const SizedBox(height: 10),
              Text(
                deadlineText(),
                style: TextStyle(
                  fontSize: 30,
                  color: deadlineTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                  'MAŁE PRACE ZROBIONE W TYM TYGODNIU'
              ),
              const SizedBox(height: 10),
              Container(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 500),
                child: ListView.builder(
                  itemCount: person.smallJobsArray.length,
                  itemBuilder: (context, index){
                    return ListTile(
                      visualDensity:VisualDensity(horizontal: 0, vertical: -4),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            person.smallJobsArray[index]._getName(),
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            person.smallJobsArray[index]._getCount().toString(),
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: (){_summaryPageNavigate(context);},
                  child: Text(
                    'PODSUMOWANIE',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.view_list,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.remove),
              backgroundColor: const Color(0xf02295f2),
              foregroundColor: Colors.white,
              label: 'Usuń pracę',
              onTap: (){_substractSmallChoreNavigate(context);},
            ),
            SpeedDialChild(
              child: const Icon(Icons.add),
              backgroundColor: const Color(0xf02295f2),
              foregroundColor: Colors.white,
              label: 'Dodaj pracę',
              onTap: (){_addSmallChoreNavigate(context);},
            ),
          ],
        )
      );
    }
  }

class SummaryPage extends StatefulWidget {
  final int points;
  final DateTime lastSummary;
  const SummaryPage(this.points, this.lastSummary, {Key? key}) : super(key: key);

  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {

  late String punktyOdmiana;

  void _punktyOdmiana(){
    if (widget.points == 1) {punktyOdmiana = " punkt.";}
    else if (widget.points == 12 || widget.points == 13 || widget.points == 14){punktyOdmiana = " punktów.";}
    else if (widget.points.toString().endsWith('2') || widget.points.toString().endsWith('3')
    || widget.points.toString().endsWith('4')) {punktyOdmiana = " punkty.";}
    else {punktyOdmiana = " punktów.";}
  }

  Future<void> _smallJobsCleanDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('OSTRZEŻENIE!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.redAccent.shade700,),)),
          content: Column(
              mainAxisSize: MainAxisSize.min,
              children:const [
                Text('Czy na pewno chcesz usunąć wszystkie małe prace?',textAlign: TextAlign.center,),
                SizedBox(height: 15),
                Text('TA OPERACJA JEST NIEODWRACALNA'),
              ]
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('NIE'),
              onPressed: () {
                Navigator.of(context).pop();
                //Navigator.pop(context,false);
              },
            ),
            TextButton(
              child: const Text('TAK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context,true);
                Fluttertoast.showToast(
                  msg: "Twoje prace zostały usunięte",
                  toastLength: Toast.LENGTH_SHORT,
                );
              },
            ),
          ],
        );
      },
    );
  }

  String _monthCheck(int month){
    if  (month < 10){
      return  '0' + month.toString();
    }
    else{
      return  month.toString();
    }
  }

  @override
  initState(){
    super.initState();
    _punktyOdmiana();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PODSUMOWANIE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xee050565),
        //automaticallyImplyLeading: false //do znikania strzałki cofającej
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30,40,30,40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text('Dzisiaj jest:'),
                Text(DateTime.now().day.toString() + '.' +
                    _monthCheck(DateTime.now().month) + '.' +
                    DateTime.now().year.toString()),
                SizedBox(height:10),
                Text('Ostatnie czyszczenie zrobiono:'),
                Text(widget.lastSummary.day.toString() + '.' +
                      _monthCheck(widget.lastSummary.month) + '.' +
                      widget.lastSummary.year.toString()),
              ],
            ),
            Column(
              children: [
                Text(
                    'Gratulacje!',
                  style: TextStyle(fontSize: 25),
                ),
                const SizedBox(height: 20),
                Text(
                    'Zdobyłeś: ' + widget.points.toString() + punktyOdmiana,
                    style: TextStyle(fontSize: 20)
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ElevatedButton(
                    onPressed: (){
                      Navigator.pop(context, false);
                    },
                    child: const Text('TYLKO WRÓĆ')
                ),
                ElevatedButton(
                    onPressed: (){
                      _smallJobsCleanDialog();
                    },
                    child: const Text('WYCZYŚĆ PRACE'),
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.red.shade700)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class AddingPage extends StatefulWidget {
  const AddingPage(this.dodawanieCzyOdejmowanie, this.person, {Key? key}) : super(key: key);

  final String dodawanieCzyOdejmowanie;
  final Person person;

  @override
  _AddingPageState createState() => _AddingPageState();
}

class _AddingPageState extends State<AddingPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.dodawanieCzyOdejmowanie,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xee050565),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30,30,30,40),
        child: Column(
          children: [
            const Center(
              child: Text(
                'Wybierz pracę',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 300, maxWidth: MediaQuery.of(context).size.width - 150),
              child: ListView.builder(
                itemCount: widget.person.smallJobsArray.length,
                itemBuilder: (context, index){
                  return Container(
                    color: Colors.amber[400 + index%2 * 100],
                    child: ListTile(
                      visualDensity:VisualDensity(horizontal: 0, vertical: -1.5),
                      title: Center(
                        child: Text(
                          widget.person.smallJobsArray[index]._getName(),
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      onTap: () {Navigator.pop(context,widget.person.smallJobsArray[index].name);},
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    child: const Text('WRÓĆ'),
                    onPressed: (){
                      Navigator.pop(context, 'NONAME');
                    }
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}

class EditionPage extends StatefulWidget {
  final String lastData;
  final EditType editType;
  const EditionPage(this.lastData, this.editType, {Key? key}) : super(key: key);

  @override
  _EditionPageState createState() => _EditionPageState();
}

class _EditionPageState extends State<EditionPage> {

  late final TextEditingController _controller = TextEditingController(
      text: widget.lastData);

  String _textFieldLabel(){
    if(widget.editType == EditType.typeName){
      return 'Zmień swoje imię';
    }
    else {
      return 'Zmień swoją część domu';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EDYCJA',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xee050565),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30,40,30,40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: _textFieldLabel()),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: (){
                      Navigator.pop(context, widget.lastData);
                    },
                    child: const Text('WRÓĆ')
                ),
                ElevatedButton(
                    onPressed: (){
                      Navigator.pop(context, _controller.text);
                    },
                    child: const Text('ZAPISZ')
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
