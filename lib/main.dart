// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart'
    hide PhoneAuthProvider, EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'home.dart';
import 'decorations.dart';
import 'firebase_options.dart';
import 'ctx.dart';
import 'package:get/get.dart';
import 'widgets.dart';
import 'auth.dart';
import 'profile_page.dart';


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
final controller = Get.put(Controller());
final User? user = FirebaseAuth.instance.currentUser;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(FirebaseAuthUIExample());
}

class LabelOverrides extends DefaultLocalizations {
  const LabelOverrides();

  @override
  String get emailInputLabel => 'Enter your email';
}

class FirebaseAuthUIExample extends StatelessWidget {
  FirebaseAuthUIExample({super.key});
  String get initialRoute {
    final user = FirebaseAuth.instance.currentUser;
    return switch (user) {
      null => '/',
      User(emailVerified: false, email: final String _) => '/verify-email',
      _ => '/home',
    };
  }

  @override
  Widget build(BuildContext context) {

    final buttonStyle = ButtonStyle(
      padding: MaterialStateProperty.all(const EdgeInsets.all(12)),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    // final mfaAction = AuthStateChangeAction<MFARequired>(
    //       (context, state) async {
    //         print('state');print(state);
    //     final nav = Navigator.of(context);
    //
    //     await startMFAVerification(
    //       resolver: state.resolver,
    //       context: context,
    //     );
    //     nav.pushReplacementNamed('/home');
    //   },
    // );

    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        visualDensity: VisualDensity.standard,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(style: buttonStyle),
        textButtonTheme: TextButtonThemeData(style: buttonStyle),
        outlinedButtonTheme: OutlinedButtonThemeData(style: buttonStyle),
      ),
      initialRoute: initialRoute,
      routes: {
        '/': (context) {
          return AuthFlowBuilder<EmailAuthController>(
            listener: (oldState, state, authController) async {
              //print('listen state msg:');print(state);
              if (state is SignedIn) {
                final user = FirebaseAuth.instance.currentUser;
                await controller.setCurrentUser(user);
                if (user?.emailVerified??false) {
                  if (!controller.currentMember.value.onBoarding?['verified']) controller.onVerify(user!);
                  controller.loading.value =false;
                  Navigator.of(context).pushReplacementNamed('/home');
                }
                else {
                  controller.loading.value =false;
                  Navigator.of(context).pushNamedAndRemoveUntil('/verify-email', ModalRoute. withName('/'));
                }
              }
            },
            builder: (context, state, authController, _) {
              //print('build state msg:');print(state);
              if (state is AwaitingEmailAndPassword) {
                return CustomEmailSignInForm(authController:  authController);
              } else if (state is SigningIn) {
                return MainLoading();
              } else if (state is SigningUp) {
                return MainLoading();
              } else if (state is AuthFailed) {
                print(state.exception);
                // FlutterFireUIWidget that shows a human-readable error message.
                controller.authErrMsg.value ='Authentication Failed!';
                //controller.loading.value =false;
                return CustomEmailSignInForm(authController:  authController);
                //return ErrorText(exception: state.exception);
              }
              return MainLoading();
            },
          );
        },
        '/verify-email': (context) {
          return EmailVerificationScreen(
            headerBuilder: headerIcon(Icons.verified),
            sideBuilder: sideIcon(Icons.verified),
            actionCodeSettings: actionCodeSettings,
            actions: [
              EmailVerifiedAction(() {
                controller.onVerify(user!);
                Navigator.pushReplacementNamed(context, '/home');
              }),
              AuthCancelledAction((context) {
                FirebaseUIAuth.signOut(context: context);
                Navigator.pushReplacementNamed(context, '/');
              }),
            ],
          );
        },
        '/phone': (context) {
          return PhoneInputScreen(
            actions: [
              SMSCodeRequestedAction((context, action, flowKey, phone) {
                Navigator.of(context).pushReplacementNamed(
                  '/sms',
                  arguments: {
                    'action': action,
                    'flowKey': flowKey,
                    'phone': phone,
                  },
                );
              }),
            ],
            headerBuilder: headerIcon(Icons.phone),
            sideBuilder: sideIcon(Icons.phone),
          );
        },
        '/sms': (context) {
          final arguments = ModalRoute.of(context)?.settings.arguments
          as Map<String, dynamic>?;
          return SMSCodeInputScreen(
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                Navigator.of(context).pushReplacementNamed('/home');
              })
            ],
            flowKey: arguments?['flowKey'],
            action: arguments?['action'],
            headerBuilder: headerIcon(Icons.sms_outlined),
            sideBuilder: sideIcon(Icons.sms_outlined),
          );
        },
        '/forgot-password': (context) {
          final arguments = ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?;
          print(arguments);
          return ForgotPasswordScreen(
            auth: FirebaseAuth.instance,
            email: arguments?['email'],
            headerMaxExtent: 200,
            headerBuilder: headerIcon(Icons.lock),
            sideBuilder: sideIcon(Icons.lock),
          );
        },
        '/email-link-sign-in': (context) {
          return EmailLinkSignInScreen(
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                Navigator.pushReplacementNamed(context, '/');
              }),
            ],
            provider: emailLinkProviderConfig,
            headerMaxExtent: 200,
            headerBuilder: headerIcon(Icons.link),
            sideBuilder: sideIcon(Icons.link),
          );
        },
        '/profile': (context) {
          final platform = Theme.of(context).platform;
          return ProfilePage(controller.currentMember.value);
        },
        '/home': (context) {
          return Home(title: 'YPO Insider' , user: FirebaseAuth.instance.currentUser );
        }
      },
      title: 'YPO Insider',
      debugShowCheckedModeBanner: false,
      supportedLocales: const [Locale('en')],
      localizationsDelegates: [
        FirebaseUILocalizations.withDefaultOverrides(const LabelOverrides()),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FirebaseUILocalizations.delegate,
      ],
    );
  }
}
