import 'package:Fiszki/ActualList.dart';
import 'package:Fiszki/Database.dart';
import 'package:Fiszki/ShowList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'Word.dart';



class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}



class _MainScreenState extends State<MainScreen> {

  DatabaseHelper databaseHelper = new DatabaseHelper();

  bool polishLanguage=false;
  List<Word> listOfLists=  new List();

  @override
  Widget build(BuildContext context) {
    if(listOfLists.length==0){
      getItems();
    }

    return Scaffold(
      appBar: AppBar(

      ),
      body: WillPopScope(
        onWillPop: onBackPressed,

        child: Container(
          child: ListView(
            children: [

              SizedBox(height: 20),

              RaisedButton(
                child: Text("Dodaj słowo"),
                onPressed: (){
                  setState(() {
                    showDialog(context: context, builder:
                        (BuildContext context)=>alertAddPlaylist(context)
                    );
                  });
                },
              ),

              SizedBox(height: 30),

              CupertinoSwitch(
                activeColor: Colors.blueGrey[800],
                value: polishLanguage,

                onChanged: (pom){
                  polishLanguage = pom;
                },
              ),

              SizedBox(height: 30),

              Container(
                height: 480,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blueGrey[600],

                ),
                child:ListView( shrinkWrap: true, scrollDirection: Axis.vertical,
                  children: listOfLists.map((word)=>

                      Padding(

                        padding: EdgeInsets.all(10),
                        child:Container(
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[800],
                            borderRadius: BorderRadius.circular(10),
                          ),

                          child:Row(
                            children: [

                              SizedBox(width: 30),

                              Expanded(
                                child: FlatButton(
                                  child: Text(word.english,style: TextStyle(fontSize: 25)), color: Colors.transparent,
                                  onPressed: (){

                                    ActualList.actualListName = word.english;
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ShowList()));
                                  }
                                )
                              ),

                              IconButton(icon: Icon(Icons.remove_circle, size: 30), color: Colors.white, onPressed: (){
                                databaseHelper.deleteItem(word.id, word.english);
                              }),

                              SizedBox(width: 30),

                            ],
                          )
                        )
                      ),

                  ).toList(),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget alertAddPlaylist(BuildContext context){
    String name;

    final formKey = GlobalKey<FormState>();

    return new AlertDialog(
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 40),
            Text('Dodaj nową playlistę', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 22)),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Container(
                    padding: EdgeInsets.only(left: 15,right: 15),
                    width:260,
                    child:TextFormField(
                      style: TextStyle(fontSize: 18,color: Colors.black),
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Nazwa',
                        hintStyle: TextStyle(color: Colors.grey[700]),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white,width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green[900], width: 2.0),
                        ),
                      ),
                      textAlign: TextAlign.center,
                      onChanged: (val) => setState((){
                        name = val.toString();
                      }),
                      validator: (val)=>val.isEmpty? 'Podaj nazwę' :null,
                    )),
                ),
                SizedBox(width: 10),
              ],
            ),
            SizedBox(height: 20),
            ButtonBar(
              alignment: MainAxisAlignment.end,
              children: [
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  textColor: Colors.cyan,
                  child: Text('Zamknij'),
                ),
                FlatButton(
                  onPressed: () {
                    if(formKey.currentState.validate()) {
                      setState(() {
                        addList(name);
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  textColor: Colors.cyan,
                  child: Text('Dodaj'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> onBackPressed(){

  }

  void getItems(){

    final Future<Database> dbFuture = databaseHelper.initialiseDatabase("myLists");

    dbFuture.then((database) {
      Future<List<Word>> itemsListFuture = databaseHelper.getItemsList("myLists");
      itemsListFuture.then((itemList){
        setState(() {
          listOfLists = itemList;
        });
      });
    });
  }

  void addList(String name){

    Word word = new Word(english: name, polish: "", id: listOfLists.length!=0?listOfLists[listOfLists.length-1].id+1:0);

    databaseHelper.insertItem(word, "myLists");
  }
}
