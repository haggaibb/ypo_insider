
import 'package:firebase_auth/firebase_auth.dart'
    hide PhoneAuthProvider, EmailAuthProvider;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:ypo_connect/main.dart';
import 'ctx.dart';
import 'package:get/get.dart';
import 'package:password_strength_checker/password_strength_checker.dart';

class CustomEmailSignInForm extends StatelessWidget {
  final EmailAuthController authController;
  CustomEmailSignInForm({ required this.authController, super.key});
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final controller = Get.put(Controller());

  signIn(BuildContext context) async {
    controller.loading.value=true;
    authController.setEmailAndPassword(emailCtrl.text, passwordCtrl.text);
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
                        onTap: ()  {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CustomEmailRegisterForm(authController: authController,),
                            ),
                          );
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
                                child: Text('Forgotten password??' , style: TextStyle(color: Colors.blueGrey),),
                              onTap: ()  {
                                  Navigator.of(context).pushNamedAndRemoveUntil('/forgot-password',ModalRoute. withName('/'));
                              },
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Obx(()=> Text(controller.authErrMsg.value, style: TextStyle(color: Colors.red),)),
                        ),
                        SizedBox(
                          width: 350,
                          child: ElevatedButton(
                            onPressed: () async {
                              await signIn(context);
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
  final EmailAuthController authController;
  CustomEmailRegisterForm({required this.authController, super.key});


  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final passwordCtrl2 = TextEditingController();
  final passNotifier = ValueNotifier<PasswordStrength?>(null);


  validateMembersEmail(String email) async {
    bool validated = await controller.validateMemberEmail(email);
    return validated;
  }

  sendRegistration(BuildContext context) async {
    controller.loading.value=true;
    bool emailValidated = await validateMembersEmail(emailCtrl.text);
    if (emailValidated) {
      if ((passwordCtrl.text == passwordCtrl2.text) && (passwordCtrl.text!='')) {
        var credentials =  await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailCtrl.text, password: passwordCtrl.text);
        if (credentials.user!=null) {
          await controller.onRegister(credentials.user!);
          controller.loading.value=false;
          Navigator.pushNamedAndRemoveUntil(context,'/verify-email' , ModalRoute. withName('/'));
        }
      }
      else {
        controller.loading.value=false;
        controller.authErrMsg.value = 'The password fields do not match or are empty!';
      }
    }
    else {
      controller.loading.value=false;
      controller.authErrMsg.value = 'This email is not recognized by YPO Israel!';
      print('not a valid email');
    }

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
                  child: Text('Register' , style: TextStyle(fontSize: 28),),
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
                            onChanged: (text) {
                              passNotifier.value = PasswordStrength.calculate(text: text);
                            },
                            obscureText: true,
                            controller: passwordCtrl,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Password',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            obscureText: true,
                            controller: passwordCtrl2,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Confirm Password',
                            ),
                          ),
                        ),
                        PasswordStrengthChecker(
                          strength: passNotifier,
                          //configuration: PasswordStrengthCheckerConfiguration(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Obx(()=> Text(controller.authErrMsg.value, style: TextStyle(color: Colors.red),)),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: 350,
                          child: ElevatedButton(
                            onPressed: () {
                              sendRegistration(context);
                            },
                            child: const Text('Register'),
                          ),
                        ),
                        Obx(() => controller.loading.value?LinearProgressIndicator(
                          semanticsLabel: 'Linear progress indicator',
                        ):SizedBox(height: 10,))
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