import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:payment_app/pages/sign_in_page.dart';
import 'package:payment_app/widgets/colors.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  PageController pageController = PageController(initialPage: 0);
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scaffold(
        body: Container(
          margin: const EdgeInsets.only(top: 34),
          width: 375,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              PageView(
                controller: pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentPageIndex = index;
                  });
                },
                children: [
                  _pages(
                    0,
                    context,
                    "Next",
                    "My Notes 1",
                    "1st slide",
                    "assets/images/reading.png",
                  ),
                  _pages(
                    1,
                    context,
                    "Next",
                    "My Note 2",
                    "Second slide",
                    "assets/images/boy.png",
                  ),
                  _pages(
                    2,
                    context,
                    "Get Started",
                    "My Note 3",
                    "3rd Slide",
                    "assets/images/man.png",
                  ),
                ],
              ),
              Positioned(
                bottom: 70,
                child: DotsIndicator(
                  position: currentPageIndex,
                  dotsCount: 3,
                  mainAxisAlignment: MainAxisAlignment.center,
                  decorator: DotsDecorator(
                    color: Colors.grey,
                    activeColor: AppColors.primaryElement,
                    size: const Size.square(8),
                    activeSize: const Size(18, 8),
                    activeShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pages(int index, BuildContext context, String buttonName,
      String title, String subTitle, String imagePath) {
    return Column(
      children: [
        SizedBox(
          width: 345,
          height: 345,
          child: Image.asset(imagePath, fit: BoxFit.cover),
        ),
        Text(
          title,
          style: const TextStyle(
              color: AppColors.primaryText,
              fontSize: 24,
              fontWeight: FontWeight.normal),
        ),
        Container(
          width: 375,
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Text(
            subTitle,
            style: const TextStyle(
                color: AppColors.primarySecondaryElementText,
                fontSize: 14,
                fontWeight: FontWeight.normal),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (index < 2) {
              pageController.animateToPage(
                index + 1,
                duration: const Duration(milliseconds: 500),
                curve: Curves.decelerate,
              );
            } else {
              // Navigate to sign in page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignInPage(),
                ),
              );
            }
          },
          child: Container(
            width: 325,
            height: 50,
            margin: const EdgeInsets.only(top: 100, right: 25, left: 25),
            decoration: BoxDecoration(
              color: AppColors.primaryElement,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Text(
                buttonName,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
