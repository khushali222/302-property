import 'package:flutter/material.dart';
import 'package:three_zero_two_property/screens/Plans/planform.dart';
import '../../widgets/appbar.dart';

void main() {
  runApp(MaterialApp(home: Plan_screen()));
}

class Plan_screen extends StatefulWidget {
  const Plan_screen({Key? key}) : super(key: key);

  @override
  State<Plan_screen> createState() => _Plan_screenState();
}

class _Plan_screenState extends State<Plan_screen> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Container(
                  height: 50.0,
                  padding: EdgeInsets.only(top: 8, left: 10),
                  width: MediaQuery.of(context).size.width * .91,
                  margin: const EdgeInsets.only(
                      bottom: 6.0), //Same as `blurRadius` i guess
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Color.fromRGBO(21, 43, 81, 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: Text(
                    "Preminum Plans",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                  ),
                ),
              ),
            ),
            Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                 height: 246,
                 width: 275,
              //  width: MediaQuery.of(context).size.width * .78,
               // height: MediaQuery.of(context).size.height * ,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    )),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 35,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(21, 43, 81, 1),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),

                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                        Image.asset("assets/icons/plan_icon.png",height: 20,),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Sliver Plan",
                            style: TextStyle(
                                color: Colors.white,
                              //  fontWeight: FontWeight.bold,
                                fontSize: 18),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("\$700/3 (Quarterly)",
                          style:TextStyle(
                            fontSize: 16,
                            color: Color.fromRGBO(21, 43, 81, 1)
                          )
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(width: 15,),
                        Icon(Icons.fiber_manual_record, size: 15),
                        SizedBox(width: 5,),
                        Expanded(
                          child: Text(
                            "Everything in Essential and Growth",
                            // Add any additional text styling as needed
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Row(
                      children: [
                        SizedBox(width: 15,),
                        Icon(Icons.fiber_manual_record, size: 15),
                        SizedBox(width: 5,),
                        Text("Account"),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Row(
                      children: [
                        SizedBox(width: 15,),
                        Icon(Icons.fiber_manual_record, size: 15),
                        SizedBox(width: 5,),
                        Text("More than 10 units of property"),
                      ],
                    ),
                    SizedBox(height: 10,),

                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>Planform()));
                      },
                      child: Center(
                        child: Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            width: 100,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(21, 43, 81, 1),
                              borderRadius: BorderRadius.circular(4)
                            ),
                            child: Center(child: Text("Get Started",style: TextStyle(
                              color: Colors.white
                            ),)),

                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5,),
                    Center(child: Text("Term Apply",style: TextStyle(
                      color: Color.fromRGBO(21, 43, 81, 1),
                      fontWeight: FontWeight.bold
                    ),))
                  ],
                ),
              ),
            ),
            SizedBox(height: 30,),
            Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 246,
                width: 275,
               // width: MediaQuery.of(context).size.width * .78,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    )),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 35,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(21, 43, 81, 1),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),

                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          Image.asset("assets/icons/free_plan.png",height: 20,),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Free Plan",
                            style: TextStyle(
                                color: Colors.white,
                                //  fontWeight: FontWeight.bold,
                                fontSize: 18),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("\$0/2 ",
                              style:TextStyle(
                                  fontSize: 16,
                                  color: Color.fromRGBO(21, 43, 81, 1)
                              )
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(width: 15,),
                        Icon(Icons.fiber_manual_record, size: 15),
                        SizedBox(width: 5,),
                        Text("14 day free trial"),
                      ],
                    ),
                    SizedBox(height: 5,),

                    SizedBox(height: 55,),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>Planform()));
                      },
                      child: Center(
                        child: Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            width: 100,
                            height: 30,
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(21, 43, 81, 1),
                                borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(child: Text("Get Started",style: TextStyle(
                                color: Colors.white
                            ),)),

                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5,),
                    Center(child: Text("Term Apply",style: TextStyle(
                        color: Color.fromRGBO(21, 43, 81, 1),
                        fontWeight: FontWeight.bold
                    ),))
                  ],
                ),
              ),
            ),
            SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }
}
