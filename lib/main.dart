import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/dbhelper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TODO',
      theme: ThemeData.light().copyWith(
        accentColor:Colors.purple
      ),
      home: MyHomePage(),
    );
  }
}


class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final TextEditingController textEditingController = new TextEditingController();
  bool validated = true;
  String errtext =" ";
  final dbhelper = Databasehelper.instance;

  String todoedited ="";

   var myitems = List();
   List<Widget> childern = new List<Widget>();
  void addtodo() async{
    Map<String,dynamic> row ={
      Databasehelper.columnName:todoedited,
    };
    final id = await dbhelper.insert(row);
    print(id);
    Navigator.pop(context);
    setState(() {
      validated = true;
      errtext = "";
    });
  }

  Future<bool> query() async{
    myitems =[];
    childern = [];
    var allrows = await dbhelper.queryall();
    allrows.forEach((row){
      myitems.add(row.toString());
      childern.add(Card(
        elevation: 5.0,
        margin: EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 10.0
        ),
        child: Container(
          color: Colors.black12,
          padding: EdgeInsets.only(left: 10.0,right: 10.0),
          child: ListTile(
            title: new Text(row['todo'],style: TextStyle(fontSize: 18.0),),
            onLongPress: (){
             dbhelper.deletedata(row['id']);
             setState(() {

             });
            },
          ),
        ),
      ),);
    });
    return Future.value(true);
  }

  /*Widget mycart(String task){
    return Card(
      elevation: 5.0,
      margin: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 10.0
      ),
      child: Container(
       padding: EdgeInsets.all(5.0),
        child: ListTile(
          title: new Text("$task",style: TextStyle(fontSize: 18.0),),
          onLongPress: (){
            print('should get deleted');
          },
        ),
      ),
    );
  }*/

  Widget showalertdialog(){
    textEditingController.text='';
     showDialog(context: context,
        builder: (context){
       return StatefulBuilder(builder: (context,setState){
         return AlertDialog(
           shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(10.0)
           ),
           title: Text("Add Task"),
           content: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               TextField(
                 decoration: InputDecoration(
                   errorText: validated ? null : errtext
                 ),
                 controller: textEditingController ,
                 autofocus: true,
                 onChanged: (_val){
                   todoedited =_val;
                 },
                 style: TextStyle(
                   fontSize: 18.0,
                 ),
               ),
               Padding(padding: EdgeInsets.only(top: 10.0)),
               Row(
                 children: [
                   RaisedButton(
                     onPressed: (){
                     if(textEditingController.text.isEmpty)
                       {
                      setState((){
                        errtext ='can not be empty';
                        validated = false;
                      });
                       }
                     else if(textEditingController.text.length > 512){
                       setState(()
                       {
                         errtext ="To many Character";
                         validated = false;
                       });
                     }
                     else{
                       addtodo();
                     }
                     },
                     color: Colors.purple,
                     child: Text("ADD"),)
                 ],
               )

             ],
           ),
         );
       });
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        builder: (context,snap){
      if(snap.hasData == null)
        {
          return Center(
            child:  Text("No Data"),
          );
        } else{
        if(myitems.length ==0)
          {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: showalertdialog,
                  backgroundColor: Colors.purpleAccent[100],
                child: Icon(Icons.add,color: Colors.white,)
              ),
              appBar: AppBar(
                elevation: 5.0,
               backgroundColor: Colors.purpleAccent,
                centerTitle: true,
                title: new Text("My Task",style: TextStyle(color: Colors.white,fontSize: 15.0),),
                actions: [
                  IconButton(icon: Icon(Icons.search,color: Colors.white,), onPressed: (){},)
                ],
              ),
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      // stops: [0.1, 0.5, 0.7, 0.9],
                      colors: [
                        Colors.purpleAccent,
                        Colors.purple
                      ])
                ),
                child: Center(
                  child: Text("No Task Availble",style: TextStyle(fontSize: 15.0),),
                ),
              )
            );
          }
        else{
          return Scaffold(
            floatingActionButton: FloatingActionButton(
                onPressed: showalertdialog,
                backgroundColor: Colors.purpleAccent[100],
                child: Icon(Icons.add,color: Colors.white,)
            ),
            appBar: AppBar(
              elevation: 5.0,
             backgroundColor: Colors.purpleAccent,
              centerTitle: true,
              title: new Text("My Task",style: TextStyle(color: Colors.white,fontSize: 15.0),),
              actions: [
                IconButton(icon: Icon(Icons.search,color: Colors.white,), onPressed: (){},)
              ],
            ),
            body: SingleChildScrollView
              (
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                       // stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                      Colors.purpleAccent,
                          Colors.purple
                    ])
                ),
                child: Column(
                  children: childern,
                ),
              ),
            ),
          );
        }
      }
    },
      future: query(),
    );
  }
}

