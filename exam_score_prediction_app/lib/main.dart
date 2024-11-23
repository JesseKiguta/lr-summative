import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exam Score Prediction App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PredictionScreen(),
    );
  }
}

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _inputData = {};

  // Utility to build input fields
  Widget _buildInputField(String label, String key,
      {TextInputType type = TextInputType.number}) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      keyboardType: type,
      onSaved: (value) => _inputData[key] = int.parse(value!),
      validator: (value) => value!.isEmpty ? 'This field is required' : null,
    );
  }

  // Function to submit the form and make a prediction
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      print("Form validation failed");
      return; // Form is invalid
    }

    _formKey.currentState!.save();
    print("Form data: $_inputData");

    final url =
        Uri.parse("https://exam-score-prediction-api.onrender.com/predict");
    final headers = {"Content-Type": "application/json"};
    final body = json.encode(_inputData);

    try {
      print("Request body: $body"); // Debugging: Verify payload

      final response = await http.post(url, headers: headers, body: body);
      print("API response: ${response.body}"); // Debugging: Print response

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extract the prediction value from the list
        final predictionList = data['prediction'];
        if (predictionList is List && predictionList.isNotEmpty) {
          final prediction =
              predictionList[0]; // Get the first value in the list
          _showResultDialog(prediction.toString()); // Convert it to a string
        } else {
          _showErrorDialog("Invalid prediction format from API");
        }
      } else {
        _showErrorDialog("Error: ${response.statusCode} - ${response.body}");
      }
    } catch (error) {
      print("Request error: $error"); // Debugging: Print error details
      _showErrorDialog("An error occurred: $error");
    }
  }

  // Show prediction result in a dialog
  void _showResultDialog(String prediction) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Prediction Result"),
        content: Text("Predicted Score: $prediction"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Show error in a dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Score Prediction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField("Hours Studied", "Hours_Studied"),
                _buildInputField("Attendance", "Attendance"),
                _buildInputField("Sleep Hours", "Sleep_Hours"),
                _buildInputField("Previous Scores", "Previous_Scores"),
                _buildInputField("Tutoring Sessions", "Tutoring_Sessions"),
                _buildInputField("Physical Activity", "Physical_Activity"),
                _buildInputField(
                    "Parental Involvement (Low)", "Parental_Involvement_Low"),
                _buildInputField("Parental Involvement (Medium)",
                    "Parental_Involvement_Medium"),
                _buildInputField(
                    "Access to Resources (Low)", "Access_to_Resources_Low"),
                _buildInputField("Access to Resources (Medium)",
                    "Access_to_Resources_Medium"),
                _buildInputField("Extracurricular Activities (Yes)",
                    "Extracurricular_Activities_Yes"),
                _buildInputField(
                    "Motivation Level (Low)", "Motivation_Level_Low"),
                _buildInputField(
                    "Motivation Level (Medium)", "Motivation_Level_Medium"),
                _buildInputField(
                    "Internet Access (Yes)", "Internet_Access_Yes"),
                _buildInputField("Family Income (Low)", "Family_Income_Low"),
                _buildInputField(
                    "Family Income (Medium)", "Family_Income_Medium"),
                _buildInputField(
                    "Teacher Quality (Low)", "Teacher_Quality_Low"),
                _buildInputField(
                    "Teacher Quality (Medium)", "Teacher_Quality_Medium"),
                _buildInputField("School Type (Public)", "School_Type_Public"),
                _buildInputField(
                    "Peer Influence (Neutral)", "Peer_Influence_Neutral"),
                _buildInputField(
                    "Peer Influence (Positive)", "Peer_Influence_Positive"),
                _buildInputField(
                    "Learning Disabilities (Yes)", "Learning_Disabilities_Yes"),
                _buildInputField("Parental Education (High School)",
                    "Parental_Education_Level_High_School"),
                _buildInputField("Parental Education (Postgraduate)",
                    "Parental_Education_Level_Postgraduate"),
                _buildInputField("Distance from Home (Moderate)",
                    "Distance_from_Home_Moderate"),
                _buildInputField(
                    "Distance from Home (Near)", "Distance_from_Home_Near"),
                _buildInputField("Gender (Male)", "Gender_Male"),
                const SizedBox(height: 24.0),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text("Predict"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
