import 'package:firebase_auth/firebase_auth.dart'
    hide PhoneAuthProvider, EmailAuthProvider;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:password_strength_checker/password_strength_checker.dart';
import 'dart:html' as html;
import 'members_controller.dart';
import 'dart:async';
import 'onboarding.dart';


class EmailSignInForm extends StatelessWidget {
  final EmailAuthController authController;
  final String errMsg;
  EmailSignInForm({required this.authController, super.key, this.errMsg = ''});
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  signIn(BuildContext context) async {
    authController.setEmailAndPassword(emailCtrl.text, passwordCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        //theme: InsiderTheme.lightThemeData(context),
        //darkTheme: InsiderTheme.darkThemeData(),
        themeMode: ThemeMode.light,
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Image.network('assets/images/logo-landscape.png', width: 300,),
                  ),
                  Image.network(scale: 2, 'assets/images/logo-insider.png', width: 150,),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(18.0),
                          child: Text(
                            'Sign in',
                            style:  TextStyle(fontSize: 28),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(
                              left: 18.0, right: 18.0, top: 8.0, bottom: 0),
                          child: Text(
                            'Welcome to YPO Israel Insdier! sign in to continue..',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 18.0, right: 18.0, top: 8.0, bottom: 20),
                          child: Row(
                            children: [
                              Text(
                                'Dont have an account yet?',
                                style: TextStyle(fontSize: 14),
                              ),
                              GestureDetector(
                                  onTap: () {
                                    Get.to(EmailRegisterForm(
                                        authController: authController));
                                  },
                                  child: const Text(
                                    ' Register',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.blue),
                                  )),
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
                                    decoration: const InputDecoration(
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
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Password',
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      child: const Text(
                                        'Forgotten password??',
                                        style: TextStyle(color: Colors.blueGrey),
                                      ),
                                      onTap: () {
                                        Get.to(
                                            ForgotPasswordScreen(
                                            auth: authController.auth,
                                              email: emailCtrl.text,
                                              resizeToAvoidBottomInset: true,
                                            ));
                                      },
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      errMsg != ''
                                          ? const Text(
                                              'Authentication Failed!',
                                              style: TextStyle(color: Colors.red),
                                            )
                                          : const SizedBox(
                                              width: 1,
                                            ),
                                      Text(
                                        errMsg,
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 350,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await signIn(context);
                                    },
                                    child: Text('Sign in', style: TextStyle(fontSize: 18, color: Get.isDarkMode? Colors.blue: Colors.black),),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class EmailRegisterForm extends StatefulWidget {
  final EmailAuthController authController;
  EmailRegisterForm({required this.authController, super.key});

  @override
  State<EmailRegisterForm> createState() => _EmailRegisterFormState();
}

class _EmailRegisterFormState extends State<EmailRegisterForm> {
  final controller = Get.put(MembersController());
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final passwordCtrl2 = TextEditingController();
  final passNotifier = ValueNotifier<PasswordStrength?>(null);
  String errMsg ='';

  validateMembersEmail(String email) async {
    bool validated = await controller.validateMemberEmail(email);
    return validated;
  }

  sendRegistration(BuildContext context) async {
    controller.loading.value = true;
    bool emailValidated = await validateMembersEmail(emailCtrl.text);
    if (emailValidated) {
      if ((passwordCtrl.text == passwordCtrl2.text) &&
          (passwordCtrl.text != '')) {
        try {
          var credentials = await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: emailCtrl.text, password: passwordCtrl.text);
          if (credentials.user != null) {
            await controller.onRegister(credentials.user!);
            controller.loading.value = false;
            Get.to(() => const EmailVerificationScreen());
          }
        } on FirebaseAuthException catch  (e) {
          setState(() {
            controller.loading.value = false;
            controller.authErrMsg.value = e.message??'error code#0';
            errMsg = e.message??'error code#0';
          });
        }

      } else {
        controller.loading.value = false;
        controller.authErrMsg.value =
            'The password fields do not match or are empty!';
      }
    } else {
      controller.loading.value = false;
      controller.authErrMsg.value =
          'This email is not recognized by YPO Israel!';
      print('not a valid email');
    }
  }

  @override
  void initState() {
    super.initState();
    print('init reg');

    print('init reg end');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Image.network('assets/images/logo-landscape.png', width: 300,),
            ),
            Image.network('assets/images/logo-insider.png', width: 150,),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10, top: 0),
                    child: Text(
                      'Register',
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(
                        left: 18.0, right: 18.0, top: 8.0, bottom: 0),
                    child: Text(
                      'Please register using the email address associated with your YPO account. Password should be at least 6 characters long, an indicator will show you the strength of your password, you can submit weak passwords although that is not recommended!',
                      style: TextStyle(fontSize: 14),
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
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter your email',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              onChanged: (text) {
                                passNotifier.value =
                                    PasswordStrength.calculate(text: text);
                              },
                              obscureText: true,
                              controller: passwordCtrl,
                              decoration: const InputDecoration(
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
                              decoration: const InputDecoration(
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
                            child: Obx(() => Text(
                                  controller.authErrMsg.value,
                                  style: TextStyle(color: Colors.red),
                                )),
                          ),
                          const SizedBox(
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
                          Obx(() => controller.loading.value
                              ? LinearProgressIndicator(
                                  semanticsLabel: 'Linear progress indicator',
                                )
                              : SizedBox(
                                  height: 10,
                                )),
                          Padding(
                            padding: const EdgeInsets.only(top: 18.0),
                            child: SizedBox(
                              width: 350,
                              child: TextButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: const Text('Go Back'),
                              ),
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
      ),
    );
  }
}

// class VerificationPage extends StatelessWidget {
//   final User user;
//   //final controller = Get.put(MembersController());
//   const VerificationPage({super.key, required this.user});
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(MembersController());
//     return EmailVerificationScreen(
//       actions: [
//         EmailVerifiedAction(() {
//           Get.to(OnBoardingPage(user: user));
//           controller.onVerify(user);
//           runApp(Home(user: user));
//           //Navigator.pushReplacementNamed(context, '/onboarding');
//         }),
//         AuthCancelledAction((context) {
//           FirebaseUIAuth.signOut(context: context);
//           Get.to(FrontGate());
//         }),
//       ],
//     );
//   }
// }

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({ super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isEmailVerified = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    print('init Verification screen');
    FirebaseAuth.instance.currentUser?.sendEmailVerification();
    timer = Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified());
  }

  checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      // analytics.logSignUp(
      //   signUpMethod: "Firebase_Auth",
      //   parameters: {
      //     "user": FirebaseAuth.instance.currentUser!.email!,
      //     "status" : "email verified"
      //   },
      // );
      Get.to(() => OnBoardingPage(user: FirebaseAuth.instance.currentUser));
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Email Successfully Verified")));

      timer?.cancel();
    }
  }

  @override
  void dispose() {
// TODO: implement dispose
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 35),
              const SizedBox(height: 30),
              const Center(
                child: Text(
                  'Check your \n Email',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Center(
                  child: Text(
                    'We have sent you a Email on ${FirebaseAuth.instance.currentUser?.email}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets
                    .symmetric(horizontal: 32.0),
                child: Center(
                  child: Text(
                    'Verifying email....',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 57),
              Padding(
                padding: const EdgeInsets
                    .symmetric(horizontal: 32.0),
                child: ElevatedButton(
                  child: const Text('Resend'),
                  onPressed: () {
                    try {
                      FirebaseAuth.instance.currentUser
                          ?.sendEmailVerification();
                    } catch (e) {
                      debugPrint('$e');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class Goodbye extends StatelessWidget {

  const Goodbye({super.key, });

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 3000), () {
      html.window.open('https://ypodex.web.app/', '_self');
    });
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network('assets/images/logo-insider.png'),
          Text('Goodbye', style : TextStyle(fontSize: 24, color: Colors.blue.shade900)),
        ],
      ),
    );
  }
}
