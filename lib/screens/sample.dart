import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiStepForm(),
    );
  }
}

class MultiStepForm extends StatefulWidget {
  @override
  _MultiStepFormState createState() => _MultiStepFormState();
}

class _MultiStepFormState extends State<MultiStepForm> {
  int _currentStep = 0;

  final List<Widget> _forms = [
    AboutYouForm(),
    CustomizeTrialForm(),
    FinalForm(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customized Horizontal Stepper'),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StepIndicator(
                current_step: _currentStep,
              ),
            ]
          ),
          SizedBox(height: 20),
          Expanded(
            child: _forms[_currentStep],
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _currentStep != 0
                  ? ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                      child: Text('Back'),
                    )
                  : Container(),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (_currentStep < _forms.length - 1) {
                      _currentStep++;
                    } else {
                      // Handle submission
                      // You can also validate inputs here
                    }
                  });
                },
                child: _currentStep == _forms.length - 1
                    ? Text('Submit')
                    : Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StepIndicator extends StatelessWidget {
  bool isActive = true;
  int current_step  =-1;
  StepIndicator({required this.current_step});
  int stepNumber = 0;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: current_step == 0 ? Colors.black : Colors.grey,
          ),
          child: Center(
            child: Text(
              "1",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 2,),
        Container(
          width: 80,
          height: 2,
          color: Colors.grey,
        ),
        SizedBox(width: 2,),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: current_step == 1 ? Colors.blue : Colors.grey,
          ),
          child: Center(
            child: Text(
              "2",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 2,),
        SizedBox(width: 2,),
        Container(
          width: 80,
          height: 2,
          color: Colors.grey,
        ),
        SizedBox(width: 2,),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: current_step == 2? Colors.blue : Colors.grey,
          ),
          child: Center(
            child: Text(
              "3",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AboutYouForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text('About You Form'),
    );
  }
}

class CustomizeTrialForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text('Customize Trial Form'),
    );
  }
}

class FinalForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text('Final Form'),
    );
  }
}
