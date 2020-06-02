import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import '../Model/AddService.dart';

/// FormController is a class which does work of saving FeedbackForm in Google Sheets using
/// HTTP GET request on Google App Script Web URL and parses response and sends result callback.
class AddServiceController {
  // Callback function to give response of status of current request.
  final void Function(String) callback;

  // Google App Script Web URL.
  static const String URL = "https://script.google.com/macros/s/AKfycbz8NSReQV46LHfjQAzzaEEbN9-Lf_O9ywkHYrCEIBTLteGswmER/exec";

  // Success Status Message
  static const STATUS_SUCCESS = "SUCCESS";

  // Default Contructor
  AddServiceController(this.callback);

  /// Async function which saves feedback, parses [feedbackForm] parameters
  // and sends HTTP GET request on [URL]. On successful response, [callback] is called.
  void submitForm(AddService feedbackForm) async {
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