import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:map_exam/helpers/utils.dart';
import 'package:map_exam/home_screen.dart';

import 'login_screen.dart';


void main() async {
  // Ensure Firebase is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'myFirst',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthHandler(),

    );
  }
}

class AuthHandler extends StatelessWidget {

  const AuthHandler({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) => Scaffold(
    body: StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        else if (snapshot.hasData) {
          return  const HomeScreen();
        }
        else if (snapshot.hasError) {
          return Center(child: Utils.showSnackBar("Something went wrong"),);
        }
        else {
          return const LoginScreen();
        }
      },
    ),

  );

}
