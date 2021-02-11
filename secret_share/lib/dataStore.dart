import 'package:shared_preferences/shared_preferences.dart';

class DataStore {
  final String key;
  DataStore({this.key});

  // set data into shared preferences
  Future<void> setData(List<String> value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(this.key, value);
  }

  // get value from shared preferences
  // return String list if exist else return empty list
  Future<List<String>> getData() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    List<String> value;
    value = pref.getStringList(this.key) ?? List<String>();
    return value;
  }

  // update data into shared preferences
  Future<void> updateData(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> newValue;
    newValue = prefs.getStringList(this.key) ?? List<String>();
    newValue.add(value);
    prefs.setStringList(this.key, newValue);
  }

  // remove data into shared preferences
  Future<void> removeData(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> newValue;
    newValue = prefs.getStringList(this.key) ?? List<String>();
    newValue.removeAt(index);
    prefs.setStringList(this.key, newValue);
  }
}