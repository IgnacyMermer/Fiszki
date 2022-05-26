import 'package:Fiszki/ActualList.dart';
import 'package:Fiszki/Database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'Word.dart';

class ShowList extends StatefulWidget {
  @override
  _ShowListState createState() => _ShowListState();
}


class _ShowListState extends State<ShowList> {

  DatabaseHelper databaseHelper = new DatabaseHelper();

  bool polishLanguage=false;
  List<Word> listOfWords=  new List();

  @override
  Widget build(BuildContext context) {

    if(listOfWords.length==0){
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
                        (BuildContext context)=>alertAddNewWordlist(context)
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
                    children: listOfWords.map((word)=>

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

                                    Expanded(child: FlatButton(
                                      child: Text(polishLanguage?word.polish:word.english,style: TextStyle(fontSize: 25)), color: Colors.transparent,
                                      onPressed: (){
                                        showDialog(context: context, builder:
                                            (BuildContext context)=>alertShowAnotherLanguageVersion(word.polish, word.english)
                                        );
                                      },)),

                                    IconButton(icon: Icon(Icons.remove_circle, size: 30), color: Colors.white, onPressed: (){
                                      databaseHelper.deleteItem(word.id, ActualList.actualListName);
                                      getItems();
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

  Widget alertAddNewWordlist(BuildContext context){
    String polish, english;

    final formKey = GlobalKey<FormState>();

    return new AlertDialog(
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 40),
            Text('Dodaj nową listę', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 22)),
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
                        hintText: 'Angielski',
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
                        english = val.toString();
                      }),
                      validator: (val)=>val.isEmpty? 'Podaj słowo' :null,
                    )),
                ),
                SizedBox(width: 10),
              ],
            ),
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
                        hintText: 'Polski',
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
                        polish = val.toString();
                      }),
                      validator: (val)=>val.isEmpty? 'Podaj polski' :null,
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
                        addWord(english, polish);
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


  Widget alertShowAnotherLanguageVersion(String polish, String english){
    return AlertDialog(
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Język polski:\t\t"+polish, style: TextStyle(fontSize: 20)),
            Text("Język angielski:\t\t"+english, style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }

  Future<bool> onBackPressed(){
    Navigator.pop(context);
  }

  void getItems(){

    final Future<Database> dbFuture = databaseHelper.initialiseDatabase(ActualList.actualListName);

    dbFuture.then((database) {
      //print(ActualList.actualListName);
      Future<List<Word>> itemsListFuture = databaseHelper.getItemsList(ActualList.actualListName);
      itemsListFuture.then((itemList){
        setState(() {
          listOfWords = itemList;
        });
      });
    });
  }

  void addWord(String english, String polish){

    Word word = new Word(english: english, polish: polish, id: listOfWords.length!=0?listOfWords[listOfWords.length-1].id+1:0);
    print(word);

    databaseHelper.insertItem(word, ActualList.actualListName);

    getItems();
  }

}
