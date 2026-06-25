import 'package:flutter/material.dart';

void main() async {
runApp(const myApp());
}
class myApp extends StatelessWidget{
  const myApp({super.key});
  @override
  Widget build(BuildContext context) {
  return MaterialApp(
    title: 'ruwwads app',
    theme : ThemeData(primaryColor: Colors.red),
    home: const Screen(),
  );
  }
}
class Screen extends StatefulWidget{
  const Screen({super.key});
  @override
State<Screen> createState() => _Screen();
  }

class _Screen extends State<Screen>{
TextEditingController _nameController = TextEditingController();
TextEditingController _SecondnameController = TextEditingController();
TextEditingController _ThirdnameController = TextEditingController();
String display = '';
@override
 Widget build(BuildContext context){
   return Scaffold(
     appBar:AppBar(
       title:Text("Welcome to my app"),
       centerTitle: true,
       backgroundColor:Colors.blue , foregroundColor:Colors.white,
     ),
  body:Center(child: Column(crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Padding(padding: EdgeInsets.all(11)),
     TextField(
      controller:_nameController,
      decoration: InputDecoration(hintText:"enter your first name",border: OutlineInputBorder(borderRadius:BorderRadius.circular(20)),labelText: 'First Name',),
    ),
   const SizedBox(height:30),
    TextField(
      controller:_SecondnameController,
      decoration: InputDecoration(hintText:"enter your Second name",border: OutlineInputBorder(borderRadius:BorderRadius.circular(20)),labelText: 'Second Name'),
    ), const SizedBox(height:30),
      TextField(
        controller:_ThirdnameController,
        decoration: InputDecoration(hintText:"enter your Third name",border: OutlineInputBorder(borderRadius:BorderRadius.circular(20)),labelText: 'Third Name'),

        ),
    const SizedBox(height:40),
    ElevatedButton(
      onPressed: (){
        setState(()
        {
          display = _nameController.text +" "+ _SecondnameController.text +" "+ _ThirdnameController.text;
        });
      },
      child:Text('show names'),
    ),
    const SizedBox(height:30),
    Text(
      display.isEmpty ? 'your names will apper here': display),


  ],
      ),
  ),

   );

  }


 }

