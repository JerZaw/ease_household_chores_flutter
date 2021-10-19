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
import 'package:numberpicker/numberpicker.dart';

enum EditType {typeHousePart,typeName}

class SmallJob{
  int count = 0;
  int value = 0;
  String name = '';
  String description = '';
  bool extra = false;

  _addOneCount(){count++;}
  _removeOneCount(){count--;}
  _resetCount(){count = 0;}
  _setCount(int arg_count){count = arg_count;}
  _getCount(){return count;}
  _getWholeValue(){return count*value;}
  _getName(){return name;}
  _getDescription(){return description;}
  _getValue(){return value;}
  _setExtra(){extra = true;}
  bool _ifExtra(){return extra;}

  SmallJob(this.value, this.name, [this.description = '', this.extra = false]);
}

class Person {

  String name='NO_NAME';
  String housePart='NO_PART';
  DateTime deadline = DateTime.now();
  int daysLeft=0;
  List<SmallJob> smallJobsArray = [
  SmallJob(3,'zmywarka', 'Rozładowanie i załadowanie gdy coś w zlewie + włączenie gdy pełna'),
  SmallJob(1,'zmywarka_włączenie', 'załadowanie na maksa np. ze zlewu i włączenie'),
  SmallJob(2,'ociekacz','rozładowanie ociekaczy (naczynia i sztućce)'),
  SmallJob(2,'śmieci_całe','założenie nowych worków na śmieci + wyrzucenie do śmietnika'),
  SmallJob(1,'śmieci_pół','samo założenie worków lub samo wyrzucenie'),
  SmallJob(2,'koty_jedzonko','jeden posiłek dla dwóch kotków'),
  SmallJob(2,'koty_sprzątanie','sprzątnięcie kuwet + dosypanie piasku gdy mało'),
  SmallJob(1,'papuga','wymiana jedzonka i wody papuga'),
  SmallJob(2,'zakupy_małe','inaczej: zwykłe, codzienne'),
  SmallJob(4,'zakupy_Duże','zazwyczaj w 2 os. w Lidlu, duże siaty lub samochodem')];
  DateTime lastSummary = DateTime.now();
  List<SmallJob> extraJobsArray = List.filled(1, SmallJob(999,'pom','pom', true), growable: true);

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
    person.extraJobsArray = List.filled(1, SmallJob(0,''), growable: true);
    checkBoxValue = false;
    daysBetween(person.deadline, DateTime.now());

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

      int i;
      for(i = 0; i < person.smallJobsArray.length; i++) {
        person.smallJobsArray[i]._setCount(int.parse(_data[i+4]));
      }
      person.extraJobsArray.clear();
      for(int j = i+4; j < _data.length; j+=3) {
        person.extraJobsArray.add(SmallJob(int.parse(_data[j]),_data[j + 1],_data[j + 2], true));
      }

      allJobsArray = person.smallJobsArray + person.extraJobsArray.sublist(1);
      setState(() {});

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

    for(int i = 0; i < person.extraJobsArray.length; i++) {
      await _myFile.writeAsString(person.extraJobsArray[i]._getValue().toString() + '\n',mode: FileMode.append);
      await _myFile.writeAsString(person.extraJobsArray[i]._getName() + '\n',mode: FileMode.append);
      await _myFile.writeAsString(person.extraJobsArray[i]._getDescription() + '\n',mode: FileMode.append);
    }
  }

  void _changeNameNavigate(BuildContext context) async{
    String? lastData = person.name;
    String? newData = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditionPage(person.name, EditType.typeName)));
    newData ??= lastData;
    setState(() {});
    Navigator.pop(context);
    if(newData != lastData) {
      Fluttertoast.showToast(
          msg: "Pomyślnie zmieniono imię",
          toastLength: Toast.LENGTH_SHORT,
      );
      person.name = newData;
      _writeData();
      setState(() {});
    }
  }

  void _changeHousePartNavigate(BuildContext context) async{
    String? lastData = person.housePart;
    String? newData = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditionPage(person.housePart, EditType.typeHousePart)));
    newData ??= lastData;
    Navigator.pop(context);
    if(newData != lastData) {
      checkBoxValue = false;
      person.housePart = newData;
      setState(() {});
      Fluttertoast.showToast(
        msg: "Pomyślnie zmieniono część domu",
        toastLength: Toast.LENGTH_SHORT,
      );
      _writeData();
    }
  }

  void _addSmallChoreNavigate(BuildContext context) async{
    String? newSmallChoreName = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddingPage('DODAWANIE PRACY', person, 'smalljob')));
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
    String? newSmallChoreName = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddingPage('USUWANIE PRACY', person, 'smalljob')));
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

  void _deleteExtraJobPageNavigate(BuildContext context) async{
    String? newExtraJobName = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddingPage('USUWANIE DOD. PRACY', person, 'extrajob')));
    //newExtraJobName przyjmuje wartość wybraną w AddingPage lub null (gdy gracz wyjdzie strzałką)
    newExtraJobName ??= 'NONAME';
    //gdy null to przyjmuje wartość NONAME

    int listIndex = person.extraJobsArray.indexWhere((element) => element.name == newExtraJobName);
    if(listIndex != -1){
        Fluttertoast.showToast(
          msg: "Pomyślnie usunięto: " + person.extraJobsArray[listIndex].name,
          toastLength: Toast.LENGTH_SHORT,
        );
        person.extraJobsArray.removeAt(listIndex);
    }
    allJobsArray = person.smallJobsArray + person.extraJobsArray.sublist(1);
    setState(() {});
    _writeData();
  }

  void _summaryPageNavigate(BuildContext context) async{
    int points = _countPoints();
    bool? ifReset = await Navigator.push(context, MaterialPageRoute(builder: (context) => SummaryPage(points,person.lastSummary)));
    ifReset ??= false; //jeżeli ifReset=null to ifReset=false
    if(ifReset){
      for(int i = 0; i < person.smallJobsArray.length; i++){
        person.smallJobsArray[i]._resetCount();
      }
      person.extraJobsArray = List.filled(1, SmallJob(999,'pom','pom', true), growable: true);
      allJobsArray = person.smallJobsArray + person.extraJobsArray.sublist(1);
      setState(() {});
      _writeData();
    }

  }

  void _descriptionPageNavigate(BuildContext context, int jobIndex) async{
    await Navigator.push(context, MaterialPageRoute(builder: (context) => DescriptionPage(allJobsArray[jobIndex])));
  }

  void _AddExtraJobPageNavigate(BuildContext context) async{
    SmallJob? extraJob = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddExtraJobPage()));
    if(extraJob != null){
      extraJob._setExtra();
      extraJob._addOneCount();
      person.extraJobsArray.add(extraJob);
      allJobsArray = person.smallJobsArray + person.extraJobsArray.sublist(1);
      setState(() {});
      _writeData();
    }
  }

  int _countPoints(){
    int points = 0;
    for(int i = 0; i < allJobsArray.length; i++){
      points= (points+allJobsArray[i]._getWholeValue()) as int;
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
        checkBoxValue = false;
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
    if(checkBoxValue == false) {
      if (person.daysLeft >= 0) {
        return person.daysLeft.toString() + dniOdmiana;
      }
      else {
        return 'PRZEKROCZONO';
      }
    }
    else{
      return 'WYKONANO';
    }
  }

  Color deadlineColor(){
    if(checkBoxValue == false){
      return deadlineTextColor;
    }
    else{
      return Colors.green;
    }
  }

  late List<SmallJob> allJobsArray = person.smallJobsArray + person.extraJobsArray.sublist(1);

  Container _ListTileContainer1(int index){
    if(allJobsArray[index]._ifExtra()){
      return Container(
        child: Row(
          children: [
            Icon(Icons.star, color: Color(0xffCBA72D),),
            SizedBox(width: 2),
          ],
        ),
      );
    }
    else{
      return Container();
    }
  }

  Container _ListTileContainer2(int index){
    if(allJobsArray[index]._ifExtra()){
      return Container(
        child: Row(
          children: [
            Icon(Icons.star, color: Color(0xffCBA72D),),
          ],
        ),
      );
    }
    else{
      return Container(
        child: Text(
          allJobsArray[index]._getCount().toString(),
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
      );
    }
  }

  bool? checkBoxValue = false;

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
              DrawerHeader(
                //padding: EdgeInsets.zero,
                margin: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: Color(0xee2d2dd7),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      'Edytuj Twoje Dane',
                    style: TextStyle(
                      fontSize: 22,
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
          child: SingleChildScrollView(
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
                Row(
                  children: [
                    const Text(
                        'DEADLINE'
                    ),
                    SizedBox(width: 5),
                    Container(
                      constraints: BoxConstraints(maxHeight: 30, maxWidth: 30),
                      child: Transform.scale(
                        scale: 1.3,
                        child: Checkbox(
                            splashRadius: 20,
                            value: checkBoxValue,
                            activeColor: Colors.green,
                            onChanged: (bool? newValue){
                              setState(() {
                                checkBoxValue = newValue;
                              });
                              },
                            ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  deadlineText(),
                  style: TextStyle(
                    fontSize: 30,
                    color: deadlineColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                        'MAŁE PRACE ZROBIONE W TYM TYGODNIU'
                    ),
                    SizedBox(width: 5),
                    Container(
                      constraints: BoxConstraints(maxHeight: 30, maxWidth: 30),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.lightBlue,
                      ),
                      child: IconButton(
                          iconSize: 14,
                          color: Colors.white,
                          onPressed: (){},
                          icon: Icon(const IconData(983750, fontFamily: 'MaterialIcons')),
                        tooltip: 'Zarządzaj dodatkowymi pracami',
                      ),
                    )
                  ],
                ),
                Container(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 500),
                  child: ListView.builder(
                    itemCount: allJobsArray.length,
                    itemBuilder: (context, index){
                      return ListTile(
                        onTap: (){_descriptionPageNavigate(context, index);},
                        visualDensity:VisualDensity(horizontal: 0, vertical: -4),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _ListTileContainer1(index),
                                Text(
                                  allJobsArray[index]._getName(),
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                    const IconData(61736, fontFamily: 'MaterialIcons'),
                                    size: 15,
                                  ),
                              ],
                            ),
                            _ListTileContainer2(index),
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
            SpeedDialChild(
              child: const Icon(const IconData(59123, fontFamily: 'MaterialIcons')),
              backgroundColor: const Color(0xf02295f2),
              foregroundColor: Colors.white,
              label: 'Usuń dodatkową pracę',
              onTap: (){_deleteExtraJobPageNavigate(context);},
            ),
            SpeedDialChild(
              child: const Icon(const IconData(59122, fontFamily: 'MaterialIcons')),
              backgroundColor: const Color(0xf02295f2),
              foregroundColor: Colors.white,
              label: 'Dodatkowa praca',
              onTap: (){_AddExtraJobPageNavigate(context);},
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
  const AddingPage(this.dodawanieCzyOdejmowanie, this.person, this.smallOrExtra, {Key? key}) : super(key: key);

  final String smallOrExtra;
  final String dodawanieCzyOdejmowanie;
  final Person person;

  @override
  _AddingPageState createState() => _AddingPageState();
}

class _AddingPageState extends State<AddingPage>{

  ListView _jobTypeDependingContainer(String jobType){
    if(jobType == 'smalljob'){
      return ListView.builder(
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
      );
    }
    else if (jobType == 'extrajob'){
      return ListView.builder(
        itemCount: widget.person.extraJobsArray.length - 1,
        itemBuilder: (context, index){
          return Container(
            color: Colors.amber[400 + index%2 * 100],
            child: ListTile(
              visualDensity:VisualDensity(horizontal: 0, vertical: -1.5),
              title: Center(
                child: Text(
                  widget.person.extraJobsArray[index+1]._getName(),
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              onTap: () {Navigator.pop(context,widget.person.extraJobsArray[index+1].name);},
            ),
          );
        },
      );
    }
    else{
      return ListView(
          children: [Container(child:Text('!!ERROR!!'))]
      );
    }
  }

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
              child: _jobTypeDependingContainer(widget.smallOrExtra),
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

class DescriptionPage extends StatefulWidget {

  final SmallJob job;
  DescriptionPage(this.job, {Key? key}) : super(key: key);

  @override
  _DescriptionPageState createState() => _DescriptionPageState();
}

class _DescriptionPageState extends State<DescriptionPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'OPIS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10),
            Icon(const IconData(63510, fontFamily: 'MaterialIcons')),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xee050565),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30,40,30,40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  color: Colors.amber,
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Text(
                    'PRACA',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Text(
                  widget.job.name,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3),
            Row(
              children: [
                Container(
                  color: Colors.amber,
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Text(
                    'WARTOŚĆ PUNKTOWA',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Text(
                  widget.job.value.toString(),
                  style: TextStyle(
                      fontSize: 20
                  ),
                ),
              ],
            ),
            SizedBox(height: 3),
            Container(
              constraints: BoxConstraints(minWidth: double.infinity),
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              color: Colors.lightBlueAccent,
              //alignment: ,
              child: Text(
                widget.job._getDescription(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
            SizedBox(height: 25),
            ElevatedButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: const Text('WRÓĆ')
            )
          ],
        ),
      ),
    );
  }
}

class AddExtraJobPage extends StatefulWidget {
  const AddExtraJobPage({Key? key}) : super(key: key);

  @override
  _AddExtraJobPageState createState() => _AddExtraJobPageState();
}

class _AddExtraJobPageState extends State<AddExtraJobPage> {

  TextEditingController nameController = TextEditingController(
      text: '');

  TextEditingController descriptionController = TextEditingController(
      text: '');

  int newJobValue = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PRACA EKSTRA',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xee050565),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30,40,30,40),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Podaj informacje dotyczące dodatkowej pracy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'NAZWA'),
              ),
              const SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.text,
                maxLines: null,
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'OPIS'),
              ),
              const SizedBox(height: 20),
              Text(
                  'Wartość punktowa:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                  )
              ),
              NumberPicker(
                  minValue: 1,
                  maxValue: 10,
                  value: newJobValue,
                  onChanged: (value) => setState(() => newJobValue = value),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: const Text('WRÓĆ')
                  ),
                  ElevatedButton(
                      onPressed: (){
                        Navigator.pop(context, SmallJob(newJobValue, nameController.text, descriptionController.text));
                      },
                      child: const Text('ZAPISZ')
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}