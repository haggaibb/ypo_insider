import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:get/get.dart';
import 'package:ypo_connect/ctx.dart';
import 'home.dart';

class MainOnBoarding extends StatelessWidget {
  const MainOnBoarding({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );

    return MaterialApp(
      title: 'Introduction screen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const OnBoardingPage(),
    );
  }
}

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  OnBoardingPageState createState() => OnBoardingPageState();
}

class OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();
  final controller = Get.put(Controller());


  void _onIntroEnd(context) async  {
    await controller.onBoardingFinished();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const Home(title : 'YPO Israel Insider Home Page')),
    );
  }

  Widget _buildFullscreenImage() {
    return Image.asset(
      'images/welcome.png',
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
    );
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('images/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      allowImplicitScrolling: true,
      autoScrollDuration: 10000,
      infiniteAutoScroll: false,
      globalHeader: Align(
        alignment: Alignment.topRight,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, right: 16),
            child: _buildImage('logo-insider.png', 350),
          ),
        ),
      ),
      pages: [
        PageViewModel(
          title: "Welcome to YPO Israel Insider!",
          body:
          "Propelling members engagement.\n\n""Please invest 5 minutes of your time to update your profile.\n\n""We hope you enjoy the journey to discover members",
          image: _buildFullscreenImage(),
          decoration: pageDecoration.copyWith(
            contentMargin: const EdgeInsets.symmetric(horizontal: 16),
            fullScreen: true,
            bodyFlex: 2,
            imageFlex: 3,
            safeArea: 100,
          ),
        ),
        PageViewModel(
          title: "Search by Filter",
          bodyWidget: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Use filters to discover common interests.", style: bodyStyle),
            ],
          ),
          decoration: pageDecoration.copyWith(
            bodyFlex: 2,
            imageFlex: 4,
            bodyAlignment: Alignment.bottomCenter,
            imageAlignment: Alignment.topCenter,
          ),
          image: _buildImage('onboarding-filters.jpg'),
          reverse: true,
        ),
        PageViewModel(
          title: "Free Text Search",
          bodyWidget: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Use the search bar for free text search on members name and current business..", style: bodyStyle),
            ],
          ),
          decoration: pageDecoration.copyWith(
            bodyFlex: 2,
            imageFlex: 4,
            bodyAlignment: Alignment.bottomCenter,
            imageAlignment: Alignment.topCenter,
          ),
          image: _buildImage('onboarding-search.jpg'),
          reverse: true,
        ),
        PageViewModel(
          title: "Profile Page",
          bodyWidget: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("You can view all of your information in the profile page.", style: bodyStyle),
              Text("Access other members profile.", style: bodyStyle),
            ],
          ),
          decoration: pageDecoration.copyWith(
            bodyFlex: 2,
            imageFlex: 4,
            bodyAlignment: Alignment.bottomCenter,
            imageAlignment: Alignment.topCenter,
          ),
          image: _buildImage('onboarding-profile.jpg'),
          reverse: true,
        ),
        PageViewModel(
          title: "Edit Your Profile Page",
          bodyWidget: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Please take the time to enter your profile page and update it.", style: bodyStyle),
            ],
          ),
          decoration: pageDecoration.copyWith(
            bodyFlex: 2,
            imageFlex: 4,
            bodyAlignment: Alignment.bottomCenter,
            imageAlignment: Alignment.topCenter,
          ),
          image: _buildImage('onboarding-edit.jpg'),
          reverse: true,
        ),
        PageViewModel(
          title: "select filter tags to be found by",
          bodyWidget: const Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select multiple Tags.", style: bodyStyle),
              Text("Fill additional information so members can know you better.", style: bodyStyle),
            ],
          ),
          decoration: pageDecoration.copyWith(
            bodyFlex: 2,
            imageFlex: 4,
            bodyAlignment: Alignment.bottomCenter,
            imageAlignment: Alignment.topCenter,
          ),
          image: _buildImage('onboarding-edit2.jpg'),
          reverse: false,
          footer: Padding(
            padding: const EdgeInsets.only(top:20.0,right: 50,left: 50),
            child: ElevatedButton(
              onPressed: () {
                introKey.currentState?.animateScroll(0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Go To Your Profile Page Now!',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: false,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: true,
      back: const Icon(Icons.arrow_back),
      //skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}

//
// class HomePage extends StatelessWidget {
//   const HomePage({super.key});
//
//   void _onBackToIntro(context) {
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (_) => const OnBoardingPage()),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Home')),
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text("This is the screen after Introduction"),
//             const SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: () => _onBackToIntro(context),
//               child: const Text('Back to Introduction'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }