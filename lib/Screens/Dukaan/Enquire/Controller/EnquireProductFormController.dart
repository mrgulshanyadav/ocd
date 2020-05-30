import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import '../Model/EnquireProductForm.dart';

/// FormController is a class which does work of saving FeedbackForm in Google Sheets using
/// HTTP GET request on Google App Script Web URL and parses response and sends result callback.
class EnquireProductFormController {
  // Callback function to give response of status of current request.
  final void Function(String) callback;

  // Google App Script Web URL.
  static const String URL = "https://script.google.com/macros/s/AKfycbxIm4H0-IgYc7U75ZJ-BaHdl6_JScatuMnQWbtZhFwJYuszbkU/exec";

  // Success Status Message
  static const STATUS_SUCCESS = "SUCCESS";

  // Default Contructor
  EnquireProductFormController(this.callback);

  /// Async function which saves feedback, parses [feedbackForm] parameters
  // and sends HTTP GET request on [URL]. On successful response, [callback] is called.
  void submitForm(EnquireProductForm feedbackForm) async {
    try {
      await http.get(
          URL + feedbackForm.toParams()
      ).then((response){
        callback(convert.jsonDecode(response.body)['status']);
      });
    } catch (e) {
      print(e);
    }
  }
}