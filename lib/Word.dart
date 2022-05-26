
class Word{
  String english, polish;
  int id;

  Word({String english, polish, id}){
    this.english = english;
    this.polish = polish;
    this.id = id;
  }

  Map<String, dynamic> toMap(){
    var map = Map<String, dynamic>();
    map["englishWord"] = english;
    map["polishWord"] = polish;
    map["id"] = id;

    return map;
  }

  Word.fromMap(Map<String, dynamic> map){
    this.id = map["id"];
    this.english = map["englishWord"];
    this.polish = map["polishWord"];
  }

}