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
import 'dart:js' as js;
import 'ga.dart';
import 'utils.dart';


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
  updateSplashScreenText('Initializing...');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const Insider());
}

//Insider
class Insider extends StatefulWidget {
  const Insider({ super.key});
  @override
  State<Insider> createState() => _InsiderState();
}
class _InsiderState extends State<Insider> {
  final user = FirebaseAuth.instance.currentUser;
  String initialRoute = '/front_gate';
  @override
  void initState()  {
    super.initState();
    ///print('init Insider');
    if (user!=null) {
      ///print('root check - user verified....');
      if (user?.displayName!=null) {
        updateSplashScreenText('${user?.displayName} Verified..');
        ///print('verified go to Home');
        ///print(user?.displayName);
        membersController.loadingStatus.value = '${user?.displayName} verified go to Home';
        js.context.callMethod('hideSplashScreen');
        //print('set init Route to Home');
        initialRoute = '/home';
      } else {
        membersController.loadingStatus.value = 'First timer, load onBoarding...';
        ///print('First timer, load onBoarding...');
        updateSplashScreenText('${user?.displayName} first visit...');
        js.context.callMethod('hideSplashScreen');
        initialRoute = '/onboarding';
      }
    }
    else {
      ///print('root check - user either null or not verified');
      js.context.callMethod('hideSplashScreen');
      initialRoute = 'front_gate';
    }
  }
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: initialRoute,
      getPages: [
        GetPage(
            name: '/home',
            page: () => Home(user: user),
            transition: Transition.zoom
        ),
        GetPage(
            name: '/front_gate',
            page: () => FrontGate(user: user,),
            transition: Transition.zoom
        ),
        GetPage(
            name: '/onboarding',
            page: () => OnBoardingPage(user: user,),
            transition: Transition.zoom
        ),
      ],
      themeMode: ThemeMode.light,

    );
  }
}

// FrontGate
class FrontGate extends StatefulWidget {
  final User? user;
  FrontGate({  super.key, this.user});
  @override
  State<FrontGate> createState() => _FrontGateState();
}
class _FrontGateState extends State<FrontGate> {

  @override
  void initState()  {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    if (widget.user!=null) {
      return Home(user: widget.user);
     }
     else {
       return AuthFlowBuilder<EmailAuthController>(
         listener: (oldState, state, authController) async {
           //print('listen state msg:');print(state);
           if (state is SignedIn) {
             print('state signed in');
             Get.toNamed('/home');
           }
         },
         builder: (context, state, authController, _) {
           /// print('build state msg:');print(state);
           if (state is AwaitingEmailAndPassword) {
             return EmailSignInForm(authController:  authController);
           } else if (state is SigningIn) {
             return MainLoading();
           } else if (state is SigningUp) {
             return MainLoading();
           } else if (state is SignedIn) {
             print('builder signed in');
             User user = authController.auth.currentUser!;
             /// displayName acts as flag for onBoarding
             print(user.displayName);
             if (user.displayName!=null) {
               try {
                 AnalyticsEngine.userLogsIn('firebase_auth',user.displayName!);
                 /// print('logged to GA -signed_in');
               } catch(err){
                 /// print('log to GA err - signed_in:');
                 /// print(err);
               }
                // print('has ObBoarded go to Home...');
               //Get.toNamed('/home');
             }
             else {
               ///print('first time, go to onBoarding');
               AnalyticsEngine.logOnBoarding(user.email!,'start');
               Get.toNamed("/onboarding");
               //runApp(OnBoardingPage(user: user));
             }
             //Get.offAllNamed('/home');
           } else if (state is AuthFailed) {
             /// add err msg to signing, add a err param
             return EmailSignInForm(authController:  authController, errMsg: state.exception.toString());
             //return ErrorText(exception: state.exception);
           }
           return MainLoading();
         },
       );
     }
  }
}


class LabelOverrides extends DefaultLocalizations {
  const LabelOverrides();

  @override
  String get emailInputLabel => 'Enter your email';
}


