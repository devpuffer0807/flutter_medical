
import 'package:iraqpvc/model/drug.dart';

class DrugList {
  List<Drug> list = new List<Drug>();
  List<String> images = new List<String>();

  add(Drug drug){
    this.list.add(drug);
  }

  remove(int index){
    this.list.removeAt(index);
  }

  addImages(String path){
    this.images.add(path);
  }

  DrugList();

  DrugList.fromJson(Map<String, dynamic> json) {
    //log("drugs: " + json['drugs'].toString());
    if (json['drugs'] != null) {
      list = new List<Drug>();
      json['drugs'].forEach((v) {
        list.add(Drug.fromJson(v));
      });
    }
    //log("drug images: " + json['images'].toString());
    json['images'].forEach((v) {
      images.add(v);
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.list != null) {
      data['drugs'] = this.list.map((v) => v.toJson()).toList();
    }
    data['images'] = this.images;
    return data;
  }
}
