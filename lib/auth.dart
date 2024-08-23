
import 'package:firebase_auth/firebase_auth.dart'
    hide PhoneAuthProvider, EmailAuthProvider;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/widgets.dart';
import 'ctx.dart';
import 'package:get/get.dart';


class CustomEmailSignInForm extends StatelessWidget {
  final EmailAuthController controller;
  CustomEmailSignInForm({ required this.controller, super.key});
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body:
      Column(
        children: [
          Image.network(width: 120,height: 120, 'assets/images/logo.png'),
          Text('YPO Insider' , style: TextStyle(fontSize: 36),),
          SizedBox(height: 55,),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text('Sign in' , style: TextStyle(fontSize: 28),),
                ),
                Padding(
                  padding: const EdgeInsets.only(left:18.0 ,right: 18.0, top: 8.0, bottom: 0),
                  child: Text('Welcome to YPO Israel Insdier! Please sign in to continue..' , style: TextStyle(fontSize: 14),),
                ),
                Padding(
                  padding: const EdgeInsets.only(left:18.0 ,right: 18.0, top: 8.0, bottom: 20),
                  child: Row(
                    children: [
                      Text('Dont have an account yet?' , style: TextStyle(fontSize: 14),),
                      GestureDetector(
                        onTap: ()  {
                          print('register...');
                          CustomEmailRegisterForm();
                        },
                          child: Text(' Register' , style: TextStyle(fontSize: 14 ,color: Colors.blue),)
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Container(
                    width: 350,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: emailCtrl,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your email',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            obscureText: true,
                            controller: passwordCtrl,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Password',
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                                child: Text('Forgotten password?' , style: TextStyle(color: Colors.blueGrey),),
                              onTap: () => {},
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: 350,
                          child: ElevatedButton(
                            onPressed: () {
                              controller.setEmailAndPassword(
                                emailCtrl.text,
                                passwordCtrl.text,
                              );
                            },
                            child: const Text('Sign in'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class CustomEmailRegisterForm extends StatelessWidget {
  final controller = Get.put(Controller());
  //final EmailAuthController authController;
  CustomEmailRegisterForm({ super.key});


  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  sendRegistration() {
    print ('reg');
    //authController.setEmailAndPassword(emailCtrl.text, passwordCtrl.text);
    print('done');
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body:
      Column(
        children: [
          Image.network(width: 120,height: 120, 'assets/images/logo.png'),
          Text('YPO Insider' , style: TextStyle(fontSize: 36),),
          SizedBox(height: 55,),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text('Sign in' , style: TextStyle(fontSize: 28),),
                ),
                Padding(
                  padding: const EdgeInsets.only(left:18.0 ,right: 18.0, top: 8.0, bottom: 0),
                  child: Text('Welcome to YPO Israel Insdier! Please sign in to continue..' , style: TextStyle(fontSize: 14),),
                ),
                Padding(
                  padding: const EdgeInsets.only(left:18.0 ,right: 18.0, top: 8.0, bottom: 20),
                  child: Row(
                    children: [
                      Text('Dont have an account yet?' , style: TextStyle(fontSize: 14),),
                      GestureDetector(
                          onTap: () => {
                            sendRegistration()
                          },
                          child: Text(' Register' , style: TextStyle(fontSize: 14 ,color: Colors.blue),)
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Container(
                    width: 350,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: emailCtrl,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your email',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            obscureText: true,
                            controller: passwordCtrl,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Password',
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              child: Text('Forgotten password?' , style: TextStyle(color: Colors.blueGrey),),
                              onTap: () => {},
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: 350,
                          child: ElevatedButton(
                            onPressed: () {
                            },
                            child: const Text('Sign in'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}