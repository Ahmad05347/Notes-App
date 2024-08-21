import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payment_app/widgets/colors.dart';

AppBar buildAppbar(String type) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(
        1,
      ),
      child: Container(
        color: Colors.grey.withOpacity(
          0.5,
        ),
        height: 1,
      ),
    ),
    title: Text(
      type,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
    ),
  );
}

Widget mainIcon(bool iconType) {
  return Padding(
    padding: const EdgeInsets.only(
      top: 60,
      bottom: 40,
    ),
    child: Icon(
      iconType == true
          ? FluentIcons.notebook_32_regular
          : FluentIcons.person_add_32_regular,
      size: 40,
    ),
  );
}

Widget reuseableText(String text, bool isColor) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      color: isColor == false ? Colors.grey.shade500 : Colors.white,
    ),
  );
}

Widget buildTextField(String textType, String hintText, IconData iconName,
    void Function(String value)? function) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    width: 325,
    height: 50,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.all(
        Radius.circular(16),
      ),
      border: Border.all(color: AppColors.primaryFourElementText),
    ),
    child: Row(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 17),
          width: 16,
          height: 16,
          child: Icon(
            iconName,
          ),
        ),
        SizedBox(
          width: 270,
          height: 50,
          child: TextFormField(
            onChanged: (value) => function!(value),
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: hintText,
              border: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
              disabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
              hintStyle: const TextStyle(
                color: AppColors.primarySecondaryElementText,
              ),
            ),
            style: const TextStyle(
              color: AppColors.primaryText,
              fontFamily: "Avenir",
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            autocorrect: false,
            obscureText: textType == "password" ? true : false,
          ),
        ),
      ],
    ),
  );
}

Widget forgetPassword() {
  return SizedBox(
    width: 260,
    height: 44,
    child: GestureDetector(
      onTap: () {},
      child: Text(
        "Forgot Password?",
        style: GoogleFonts.poppins(
          color: Colors.black,
          decoration: TextDecoration.underline,
          fontSize: 12,
          decorationColor: Colors.blue,
        ),
      ),
    ),
  );
}

Widget loginAndRegButton(
    String buttonName, String textType, void Function()? function) {
  return GestureDetector(
    onTap: function,
    child: Container(
      // margin: EdgeInsets.only(left: 25.w, right: 25.w),
      margin: EdgeInsets.only(top: textType == "login" ? 40 : 10),
      width: 325.w,
      height: 50.h,
      decoration: BoxDecoration(
        border: Border.all(
            color: textType == "login"
                ? Colors.transparent
                : AppColors.primaryFourElementText),
        borderRadius: BorderRadius.circular(16),
        color: textType == "register" ? Colors.white : AppColors.primaryElement,
        boxShadow: [
          BoxShadow(
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
            color: Colors.grey.withOpacity(0.1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          buttonName,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: textType == "register" ? Colors.black : Colors.white),
        ),
      ),
    ),
  );
}
