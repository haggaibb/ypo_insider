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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  //
  // FirebaseUIAuth.configureProviders([
  //   EmailAuthProvider(),
  // ]);
  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    EmailLinkAuthProvider(
      actionCodeSettings: ActionCodeSettings(
        url: 'https://ypodex.web.app/',
        handleCodeInApp: true,
      ),
    ),
    // ... other providers
  ]);
  runApp(const FirebaseAuthUIExample());
}

// Overrides a label for en locale
// To add localization for a custom language follow the guide here:
// https://flutter.dev/docs/development/accessibility-and-localization/internationalization#an-alternative-class-for-the-apps-localized-resources
class LabelOverrides extends DefaultLocalizations {
  const LabelOverrides();

  @override
  String get emailInputLabel => 'Enter your email';
}

class FirebaseAuthUIExample extends StatelessWidget {
  const FirebaseAuthUIExample({super.key});

  String get initialRoute {
    final user = FirebaseAuth.instance.currentUser;
    print(user);
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

    final mfaAction = AuthStateChangeAction<MFARequired>(
          (context, state) async {
            print('state');print(state);
        final nav = Navigator.of(context);

        await startMFAVerification(
          resolver: state.resolver,
          context: context,
        );
        nav.pushReplacementNamed('/home');
      },
    );

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
          var myAuth = AuthFlowBuilder<EmailAuthController>(
            listener: (oldState, state, controller) {
              if (state is SignedIn) {
                Navigator.of(context).pushReplacementNamed('/home');
              }
            },
            builder: (context, state, controller, _) {
              print(state);
              if (state is AwaitingEmailAndPassword) {
                return CustomEmailSignInForm(controller:  controller);
              } else if (state is SigningIn) {
                print('Signing In');
                return Text('Signing In');
              } else if (state is AuthFailed) {
                // FlutterFireUIWidget that shows a human-readable error message.
                return Text('Auth Failed!');
                return ErrorText(exception: state.exception);
              }
              return Text('No Auth Satte');
            },
          );
          return AuthFlowBuilder<EmailAuthController>(
            listener: (oldState, state, controller) {
              if (state is SignedIn) {
                Navigator.of(context).pushReplacementNamed('/home');
              }
            },
            builder: (context, state, controller, _) {
              print(state);
              if (state is AwaitingEmailAndPassword) {
                return CustomEmailSignInForm(controller:  controller);
              } else if (state is SigningIn) {
                print('Signing In');
                return Text('Signing In');
              } else if (state is AuthFailed) {
                // FlutterFireUIWidget that shows a human-readable error message.
                return Text('Auth Failed!');
                return ErrorText(exception: state.exception);
              }
              return Text('No Auth Satte');
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

          return ForgotPasswordScreen(
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
          return ProfileScreen(
            avatar: Center(child: ProfilePic(controller.currentMember.value.profileImage??'',false)),
            children: [
              Text('test'),
              Text('here')
            ],
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () { Navigator.pop(context);Navigator.pop(context);},
              ),
            ),
            actions: [
              SignedOutAction((context) {
                Navigator.pushReplacementNamed(context, '/');
              }),
              mfaAction,
            ],
            actionCodeSettings: actionCodeSettings,
            showMFATile: kIsWeb ||
                platform == TargetPlatform.iOS ||
                platform == TargetPlatform.android,
            showUnlinkConfirmationDialog: true,
            showDeleteConfirmationDialog: true,
          );
        },
        '/home': (context) { return Home(title: 'YPO Insider' , user: FirebaseAuth.instance.currentUser );}
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

class MyLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext) {
    return Scaffold(
      body: Row(
        children: [
          Text('my widget'),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FirebaseUIActions(
              actions: [
                AuthStateChangeAction<SignedIn>((context, state) {
                  if (!state.user!.emailVerified) {
                    Navigator.pushNamed(context, '/verify-email');
                  } else {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                }),
              ],
              child: Column(
                children: [

                  SizedBox(
                    width: 200,
                    height: 400,
                    child: LoginView(
                      action: AuthAction.signUp,
                      providers: FirebaseUIAuth.providersFor(
                        FirebaseAuth.instance.app,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}