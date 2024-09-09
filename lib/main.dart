import 'package:firebase_auth/firebase_auth.dart'
    hide PhoneAuthProvider, EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'firebase_options.dart';
import 'widgets.dart';
import 'auth_screens.dart';
import 'admin_pages.dart';

final actionCodeSettings = ActionCodeSettings(
  url: 'https://ypodex.web.app/',
  handleCodeInApp: true,
  //androidMinimumVersion: '1',
  //androidPackageName: 'io.flutter.plugins.firebase_ui.firebase_ui_example',
  //iOSBundleId: 'io.flutter.plugins.fireabaseUiExample',
);
final emailLinkProviderConfig = EmailLinkAuthProvider(
  actionCodeSettings: actionCodeSettings,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //runApp(TestPage());
  //runApp(AddNewMember());
  //return;
  print('@@@@@@@@@@@@@@@@@@');
  print('main');
  runApp(MainLoading());
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final user = FirebaseAuth.instance.currentUser;
  if (user!=null && user.emailVerified) {
    print('root check - user verified, go to home....');
    runApp(Home(user: user,));
  }
  else {
    print('root check - user either null or not verified');
    runApp(FrontGate(user: user));
  }
  /// TODO onboarding....
  //runApp(MainOnBoarding());
}


class FrontGate extends StatefulWidget {
  final User? user;
  FrontGate({  super.key, this.user});
  @override
  State<FrontGate> createState() => _FrontGateState();
}
class _FrontGateState extends State<FrontGate> {
  @override
  void initState()  {
    print('init FrontGate');
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return AuthFlowBuilder<EmailAuthController>(
      listener: (oldState, state, authController) async {
        print('listen state msg:');print(state);
        if (state is SignedIn) {
          print('signed in');
          // if (!authController.auth.currentUser!.emailVerified??false) {
          //   print('mail not verified, go to verification screen...');
          //   MaterialPageRoute(builder: (context) => const EmailVerificationScreen());
          // }
          // else {
          //   print('mail verified, go to Home screen...');
          //   Navigator.of(context).push(
          //     MaterialPageRoute(
          //         builder: (context) => Directionality(
          //           textDirection: TextDirection.ltr,
          //           child: Home(user: authController.auth.currentUser),
          //         )),
          //   );
          // }
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
          if (!authController.auth.currentUser!.emailVerified) {
            print('mail not verified, go to verification screen...');
            return MaterialApp(
                title: 'YPO Israel Insider - Verification',
                home: VerificationPage(user: authController.auth.currentUser!)
            );
          }
          else {
            print('mail verified, go to Home screen...');
            return Home(user: authController.auth.currentUser);
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





//
// class InsiderApp extends StatefulWidget {
//   InsiderApp({super.key});
//
//   @override
//   State<InsiderApp> createState() => _InsiderAppState();
// }
//
// class _InsiderAppState extends State<InsiderApp> {
//   String get initialRoute {
//     final user = FirebaseAuth.instance.currentUser;
//     print('################  Insider Init App ######################');
//     print('check for user....');
//     if (user!=null) {
//       //controller.currentMember.value = await controller.loadMemberByUid(user.uid);
//       if (user.displayName!=null) {
//         print('user has a display name');
//         print(user.displayName);
//         print('assume onboarding done');
//         print('goto Home');
//         return '/home';
//       }
//       else {
//         print('user does not have has a display name');
//         print('assume he did nor finish onBoarding');
//         print('goto onboarding');
//         return '/onboarding';
//       }
//       //if (user?.displayName==null) return '/onboarding';
//       return switch (user) {
//         User(emailVerified: false, email: final String _) => '/verify-email',
//         _ => '/home',
//       };
//     } else {
//       print('no user found -> goto sign-in');
//       return '/';
//     }
//
//   }
//   late ThemeMode themeMode;
//
//
//   @override
//   void initState()  {
//     print('init InsiderApp');
//     super.initState();
//     setState(() {
//       themeMode = controller.themeMode.value;
//     });
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     // final mfaAction = AuthStateChangeAction<MFARequired>(
//     //       (context, state) async {
//     //         print('state');print(state);
//     //     final nav = Navigator.of(context);
//     //
//     //     await startMFAVerification(
//     //       resolver: state.resolver,
//     //       context: context,
//     //     );
//     //     nav.pushReplacementNamed('/home');
//     //   },
//     // );
// /*
// ThemeData(
//         brightness: Brightness.light,
//         visualDensity: VisualDensity.standard,
//         useMaterial3: true,
//         inputDecorationTheme: const InputDecorationTheme(
//           border: OutlineInputBorder(),
//         ),
//         elevatedButtonTheme: ElevatedButtonThemeData(style: buttonStyle),
//         textButtonTheme: TextButtonThemeData(style: buttonStyle),
//         outlinedButtonTheme: OutlinedButtonThemeData(style: buttonStyle),
//       ),
//  */
//     return Obx( () => MaterialApp(
//       theme: InsiderTheme.lightThemeData(context),
//       darkTheme: InsiderTheme.darkThemeData(),
//       themeMode: controller.themeMode.value,
//       //theme: InsiderTheme.darkThemeData(),
//       initialRoute: initialRoute,
//       routes: {
//         '/': (context) {
//           return AuthFlowBuilder<EmailAuthController>(
//             listener: (oldState, state, authController) async {
//               //print('listen state msg:');print(state);
//               if (state is SignedIn) {
//                 print('sign in state activated');
//                 final user = FirebaseAuth.instance.currentUser;
//                 await controller.setCurrentUser(user);
//                 if (user?.emailVerified??false) {
//                   if (!controller.currentMember.value.onBoarding?['verified']) controller.onVerify(user!);
//                   //controller.loading.value =true;
//                   Navigator.of(context).pushReplacementNamed('/home');
//                 }
//                 else {
//                   controller.loading.value =false;
//                   Navigator.of(context).pushNamedAndRemoveUntil('/verify-email', ModalRoute. withName('/'));
//                 }
//               }
//             },
//             builder: (context, state, authController, _) {
//               //print('build state msg:');print(state);
//               if (state is AwaitingEmailAndPassword) {
//                 return CustomEmailSignInForm(authController:  authController);
//               } else if (state is SigningIn) {
//                 return MainLoading();
//               } else if (state is SigningUp) {
//                 return MainLoading();
//               } else if (state is AuthFailed) {
//                 print(state.exception);
//                 controller.authErrMsg.value ='Authentication Failed!';
//                 controller.loading.value =false;
//                 return CustomEmailSignInForm(authController:  authController);
//                 //return ErrorText(exception: state.exception);
//               }
//               return MainLoading();
//             },
//           );
//         },
//         '/verify-email': (context) {
//           return EmailVerificationScreen(
//             headerBuilder: headerIcon(Icons.verified),
//             sideBuilder: sideIcon(Icons.verified),
//             actionCodeSettings: actionCodeSettings,
//             actions: [
//               EmailVerifiedAction(() {
//                 controller.onVerify(user!);
//                 Navigator.pushReplacementNamed(context, '/onboarding');
//               }),
//               AuthCancelledAction((context) {
//                 FirebaseUIAuth.signOut(context: context);
//                 Navigator.pushReplacementNamed(context, '/');
//               }),
//             ],
//           );
//         },
//         '/phone': (context) {
//           return PhoneInputScreen(
//             actions: [
//               SMSCodeRequestedAction((context, action, flowKey, phone) {
//                 Navigator.of(context).pushReplacementNamed(
//                   '/sms',
//                   arguments: {
//                     'action': action,
//                     'flowKey': flowKey,
//                     'phone': phone,
//                   },
//                 );
//               }),
//             ],
//             headerBuilder: headerIcon(Icons.phone),
//             sideBuilder: sideIcon(Icons.phone),
//           );
//         },
//         '/sms': (context) {
//           final arguments = ModalRoute.of(context)?.settings.arguments
//           as Map<String, dynamic>?;
//           return SMSCodeInputScreen(
//             actions: [
//               AuthStateChangeAction<SignedIn>((context, state) {
//                 Navigator.of(context).pushReplacementNamed('/home');
//               })
//             ],
//             flowKey: arguments?['flowKey'],
//             action: arguments?['action'],
//             headerBuilder: headerIcon(Icons.sms_outlined),
//             sideBuilder: sideIcon(Icons.sms_outlined),
//           );
//         },
//         '/forgot-password': (context) {
//           final arguments = ModalRoute.of(context)?.settings.arguments
//           as Map<String, dynamic>?;
//           print(arguments);
//           return ForgotPasswordScreen(
//             auth: FirebaseAuth.instance,
//             email: arguments?['email'],
//             headerMaxExtent: 200,
//             headerBuilder: headerIcon(Icons.lock),
//             sideBuilder: sideIcon(Icons.lock),
//           );
//         },
//         '/email-link-sign-in': (context) {
//           return EmailLinkSignInScreen(
//             actions: [
//               AuthStateChangeAction<SignedIn>((context, state) {
//                 Navigator.pushReplacementNamed(context, '/');
//               }),
//             ],
//             provider: emailLinkProviderConfig,
//             headerMaxExtent: 200,
//             headerBuilder: headerIcon(Icons.link),
//             sideBuilder: sideIcon(Icons.link),
//           );
//         },
//         '/profile': (context) {
//           final platform = Theme.of(context).platform;
//           return ProfilePage(controller.currentMember.value);
//         },
//         '/home': (context) {
//           return Home(title: 'YPO Insider' , user: FirebaseAuth.instance.currentUser );
//         },
//         '/onboarding': (context) {
//           print('in onboarding');
//           return MainOnBoarding();
//         }
//       },
//       title: 'YPO Insider',
//       debugShowCheckedModeBanner: false,
//       supportedLocales: const [Locale('en')],
//       localizationsDelegates: [
//         FirebaseUILocalizations.withDefaultOverrides(const LabelOverrides()),
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         FirebaseUILocalizations.delegate,
//       ],
//     ));
//   }
// }
//

class LabelOverrides extends DefaultLocalizations {
  const LabelOverrides();

  @override
  String get emailInputLabel => 'Enter your email';
}