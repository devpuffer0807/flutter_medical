
import 'package:iraqpvc/model/reaction.dart';
class Reactions {
  List<Reaction> list = new List<Reaction>();
  List<String> images = new List<String>();

  add(Reaction reaction){
    this.list.add(reaction);
  }

  remove(int index){
    this.list.removeAt(index);
  }

  addImages(String path){
    this.images.add(path);
  }

  Reactions();

  Reactions.fromJson(Map<String, dynamic> json) {
    //log("json: " + json['reactions'].toString());
    if (json['reactions'] != null) {
      list = new List<Reaction>();
      json['reactions'].forEach((v) {
        list.add(new Reaction.fromJson(v));
      });
    }
    //log("images: " + json['images'].toString());
    json['images'].forEach((v) {
      images.add(v);
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.list != null) {
      data['reactions'] = this.list.map((v) => v.toJson()).toList();
    }
    data['images'] = this.images;
    return data;
  }
}