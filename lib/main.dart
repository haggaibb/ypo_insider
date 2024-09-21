import 'package:firebase_auth/firebase_auth.dart'
    hide PhoneAuthProvider, EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/material.dart';
import 'package:ypo_connect/onboarding.dart';
import 'home.dart';
import 'firebase_options.dart';
import 'widgets.dart';
import 'auth_screens.dart';
import 'package:get/get.dart';
import 'members_controller.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:js' as js;

final actionCodeSettings = ActionCodeSettings(
  url: 'https://ypodex.web.app/',
  handleCodeInApp: true,
  //androidMinimumVersion: '1',
);
final emailLinkProviderConfig = EmailLinkAuthProvider(
  actionCodeSettings: actionCodeSettings,
);
final membersController = Get.put(MembersController());



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final user = FirebaseAuth.instance.currentUser;
  print('@@@@@@@@@@@@@@@@@@');
  print('main');
  runApp(MainLoading());
  if (user!=null && user.emailVerified) {
    print('root check - user verified....');
    if (user.displayName!=null) {
      membersController.loadingStatus.value = '${user.displayName} verified go to Home';
      runApp(Home(user: user,));
    } else {
      membersController.loadingStatus.value = 'First timer, load onBoarding...';
      print('run app');
      js.context.callMethod('hideSplashScreen');
      runApp(OnBoardingPage(user: user));
    }
  }
  else {
    print('root check - user either null or not verified');
    js.context.callMethod('hideSplashScreen');
    runApp(FrontGate(user: user));
  }

}


class FrontGate extends StatefulWidget {
  final User? user;
  FrontGate({  super.key, this.user});
  @override
  State<FrontGate> createState() => _FrontGateState();
}
class _FrontGateState extends State<FrontGate> {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState()  {
    print('init FrontGate');
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return AuthFlowBuilder<EmailAuthController>(
      listener: (oldState, state, authController) async {
        //print('listen state msg:');print(state);
        if (state is SignedIn) {
          //print('signed in');
          }
      },
      builder: (context, state, authController, _) {
        print('build state msg:');print(state);
        if (state is AwaitingEmailAndPassword) {
          return EmailSignInForm(authController:  authController);
        } else if (state is SigningIn) {
          return MainLoading();
        } else if (state is SigningUp) {
          return MainLoading();
        } else if (state is SignedIn) {
          print('signed in');
          User user = authController.auth.currentUser!;
          if (user.displayName!=null) {
            try {
              analytics.logEvent(
                  name: 'signed_in',
                  parameters: <String, Object> {
                    'user': user.displayName!
                  }
              );
              print('logged to GA -signed_in');
            } catch(err){
              print('log to GA err - signed_in:');
              print(err);
            }
             print('has ObBoarded go to Home...');
              runApp(Home(user: user,));
          } else {
              print('first time, go to onBoarding');
              analytics.logEvent(
                name: "on_boarding",
                parameters: {
                  "user": user.email!,
                  "status" : "begin"
                },
              );
              runApp(OnBoardingPage(user: user));
          }
          //return Home(user: authController.auth.currentUser,);
        } else if (state is AuthFailed) {
          print(state.exception);
          /// add errmsg to signin, add a err parm
          return EmailSignInForm(authController:  authController, errMsg: state.exception.toString());
          //return ErrorText(exception: state.exception);
        }
        return MainLoading();
      },
    );
  }
}


class LabelOverrides extends DefaultLocalizations {
  const LabelOverrides();

  @override
  String get emailInputLabel => 'Enter your email';
}


