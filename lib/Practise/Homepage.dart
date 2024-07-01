import 'package:flutter/material.dart';
import 'package:three_zero_two_property/Practise/service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Apiservice apiservice = Apiservice();
  @override
  void initState() {
    // TODO: implement initState
    apiservice.fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: apiservice.fetchData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, int index) {
                        return ListTile(
                          title: Text('${snapshot.data![index].title}'),
                          trailing: Text('${snapshot.data![index].body}'),
                        );
                      });
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
              }
              return Center(child: CircularProgressIndicator());
            }));
  }
}
