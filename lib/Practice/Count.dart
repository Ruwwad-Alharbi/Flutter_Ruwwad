import 'package:flutter/material.dart';
import 'package:ws2022_app/Practice/Ruuwad.dart';

void main(){
 runApp(const count());
}
class count extends StatelessWidget{
  const count({super.key});
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'count app',
      theme : ThemeData(primaryColor: Colors.blue),
      home: const countApp(),
    );
  }
  }
class countApp extends StatefulWidget{
  const countApp({super.key});
  @override
  State<countApp> createState() => _countApp();
}
class _countApp extends State<countApp>{
  int counter = 0;


  void increaseCounter() {
    setState((){
      counter++;
    });



}
void decreaseCounter(){
  setState((){
    counter--;
  });
}
void resetCounter(){
    setState((){
      counter = 0;
    });
}

Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title:Text("counter app"),
            centerTitle: true,
        backgroundColor:Colors.blue , foregroundColor:Colors.white,



      ),

body: Center(child:Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

  const SizedBox(height:40),
  IconButton(onPressed: ((){
    setState(() {
      increaseCounter();
    });
  }), icon: const Icon(Icons.add, size: 50)),
  IconButton(onPressed: ((){
    setState(() {
      decreaseCounter();
    });
  }), icon: const Icon(Icons.minimize, size: 50)),
  IconButton(onPressed: ((){
    setState(() {
      resetCounter();
    });
  }), icon: const Icon(Icons.lock_reset, size: 50)),

SizedBox(height:40),
Text('$counter',style:counter == 10 ? TextStyle(color: Colors.red) : TextStyle(color: Colors.black))
],



)),

  );
          }

}