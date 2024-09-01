import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Color seedColor = Colors.blue.shade50;

class InsiderTheme {
  static ThemeData lightThemeData(BuildContext context) {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: GoogleFonts.openSans().fontFamily,
      colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          background: Colors.white
      ),
      //hoverColor:  Colors.green.shade200,
      dividerColor: Colors.indigoAccent,
      scaffoldBackgroundColor: Colors.blue[50],
      /// Icon theme
      iconTheme: const IconThemeData(
          color: Colors.white,
          fill: 0.0,
          opacity: 1.0,
          // size: 40,
          weight: 100,
          opticalSize: 20,

          /// Optical sizes range from 20dp to 48dp. we can maintain
          /// the stroke width common while resizing or on increase of the icon size
          grade: 0 // (For light and dart themes) To make strokes heavier and more emphasized, use positive value grade, such as when representing an active icon state.
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: Colors.blue.shade50,
        //scrimColor: Colors.transparent,
        shadowColor: Colors.black,
        elevation: 20,
        //surfaceTintColor: Colors.blue,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(150),
          side: BorderSide(color: Colors.indigo, width: 5)
        )
      ),
      /// Card Theme
      cardTheme: CardTheme(color: Colors.white ?? Colors.green.shade50, margin: const EdgeInsets.all(16), shadowColor: Colors.indigo, elevation: 5, surfaceTintColor: Colors.indigoAccent),
      //listTileTheme: ListTileThemeData(tileColor: Colors.red),
      /// Text Theme data
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.nunito(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        titleMedium: GoogleFonts.kanit(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        titleSmall: GoogleFonts.kanit(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        bodyMedium: GoogleFonts.dmSans(
          color: Colors.black,
        ),
      ),
      appBarTheme: AppBarTheme(color: seedColor, shadowColor: Colors.indigo, elevation: 5, foregroundColor: Colors.black),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              elevation: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
                if (states.contains(MaterialState.hovered)) {
                  return 5.0;
                } else {
                  return 3.0;
                }
              }),
              backgroundColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
                if (states.contains(MaterialState.hovered)) {
                  return Colors.white;
                } else {
                  return Colors.green;
                }
              }),
              shadowColor: MaterialStateProperty.all<Color>(Colors.lightGreenAccent),
              textStyle: MaterialStateProperty.all(GoogleFonts.prompt(fontWeight: FontWeight.w600)),
              foregroundColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
                if (states.contains(MaterialState.hovered)) {
                  return Colors.green;
                } else {
                  return Colors.white;
                }
              }))),
      textButtonTheme: TextButtonThemeData(style: ButtonStyle(shadowColor: MaterialStateProperty.all<Color>(Colors.lightGreenAccent), foregroundColor: MaterialStateProperty.all(Colors.white))),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 5,
        useIndicator: true,
        indicatorColor: Colors.orange.shade100,
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        // labelType: NavigationRailLabelType.selected,
        selectedIconTheme: const IconThemeData(
          color: Colors.orange,
          weight: 100,
        ),
        selectedLabelTextStyle: GoogleFonts.robotoSlab(color: Colors.orange.shade500, fontWeight: FontWeight.bold),
        unselectedLabelTextStyle: GoogleFonts.robotoSlab(color: Colors.green.shade500),
      ),
      dialogTheme: const DialogTheme(iconColor: Colors.orange),
      snackBarTheme: SnackBarThemeData(backgroundColor: Colors.black, contentTextStyle: Theme.of(context).textTheme.titleMedium?.apply(color: Colors.white)),
      bannerTheme: MaterialBannerThemeData(backgroundColor: Colors.red, contentTextStyle: Theme.of(context).textTheme.titleMedium?.apply(color: Colors.white), padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8), leadingPadding: const EdgeInsets.all(0), elevation: 5),
      dataTableTheme: DataTableThemeData(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        dataRowColor: MaterialStateProperty.resolveWith(
              (states) {
            if (states.contains(MaterialState.hovered)) {
              return Colors.green;
            } else {
              return Colors.white;
            }
          },
        ),
        headingTextStyle: GoogleFonts.aBeeZee(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        dataTextStyle: GoogleFonts.abhayaLibre(
          color: Colors.black,
        ),
        headingRowColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.hovered)) {
            return Colors.green;
          } else {
            return Colors.blueAccent.withOpacity(0.5);
          }
        },
        ),
      ),

      dropdownMenuTheme: const DropdownMenuThemeData(
          textStyle: TextStyle(fontWeight: FontWeight.w100)
      ),

      useMaterial3: true,
    );
  }
///
  ///
  ///
  ///
  /// Darko mode
  static ThemeData darkThemeData() {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.openSans().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: Color(4294703871),
        primary: Color(4294703871),
        surfaceTint: Color(4289382399),
        onPrimary: Color(4278190080),
        primaryContainer: Color(4289842175),
        onPrimaryContainer: Color(4278190080),
        secondary: Color(4294703871),
        onSecondary: Color(4278190080),
        secondaryContainer: Color(4290956256),
        onSecondaryContainer: Color(4278190080),
        tertiary: Color(4294965754),
        onTertiary: Color(4278190080),
        tertiaryContainer: Color(4292985061),
        onTertiaryContainer: Color(4278190080),
        error: Color(4294965753),
        onError: Color(4278190080),
        errorContainer: Color(4294949553),
        onErrorContainer: Color(4278190080),
        surface: Color(4279309080),
        onSurface: Color(4294967295),
        onSurfaceVariant: Color(4294703871),
        outline: Color(4291349204),
        outlineVariant: Color(4291349204),
        shadow: Color(4278190080),
        scrim: Color(4278190080),
        inverseSurface: Color(4293059305),
        inversePrimary: Color(4278200665),
      ),
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.nunito(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleMedium: GoogleFonts.kanit(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        titleSmall: GoogleFonts.kanit(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        bodyMedium: GoogleFonts.dmSans(
          color: Colors.white,
        ),
      ),
      drawerTheme: DrawerThemeData(
        //backgroundColor: Colors.red,
          scrimColor: Colors.transparent,
          //shadowColor: Colors.blue,
          elevation: 10,
          //surfaceTintColor: Colors.indigoAccent,
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(150),
              side: BorderSide(color: Colors.white, width: 5)
          )
/*
RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: BorderSide(color: Colors.indigoAccent, width: 1)),
 */
      ),
      dividerTheme: DividerThemeData(
        color: Colors.black,
        thickness: 0
      ),
      cardTheme: CardTheme(
          color: Colors.blueGrey.shade700 ,
          margin: const EdgeInsets.all(16),
          shadowColor: seedColor,
          elevation: 5,
          surfaceTintColor: Colors.black
      ),
      hoverColor:  Colors.green.shade200,
      dividerColor: Colors.indigoAccent,
      appBarTheme: const AppBarTheme(
        //backgroundColor: ,
          elevation: 5
      ),
      //scaffoldBackgroundColor: Colors.blue[50],
      /// Icon theme
      iconTheme: const IconThemeData(
          color: Colors.greenAccent,
          fill: 0.0,
          opacity: 1.0,
          // size: 40,
          weight: 100,
          opticalSize: 20,

          /// Optical sizes range from 20dp to 48dp. we can maintain
          /// the stroke width common while resizing or on increase of the icon size
          grade: 0 // (For light and dart themes) To make strokes heavier and more emphasized, use positive value grade, such as when representing an active icon state.
      ),
      // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    );
  }
















  static ColorScheme darkScheme() {
    return ColorScheme(
      background: Colors.black87,
      brightness: Brightness.dark,
      primary: Color(4289382399),
      surfaceTint: Color(4289382399),
      onPrimary: Color(4278857823),
      primaryContainer: Color(4280829815),
      onPrimaryContainer: Color(4292273151),
      onBackground: seedColor,
      secondary: Color(4290692828),
      onSecondary: Color(4280824129),
      secondaryContainer: Color(4282271577),
      onSecondaryContainer: Color(4292535033),
      tertiary: Color(4292721888),
      onTertiary: Color(4282329156),
      tertiaryContainer: Color(4283907676),
      onTertiaryContainer: Color(4294629629),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      surface: Color(4279309080),
      onSurface: Color(4293059305),
      onSurfaceVariant: Color(4291086032),
      outline: Color(4287533209),
      outlineVariant: Color(4282664782),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4293059305),
      inversePrimary: Color(4282474385),

    );
  }

  static ThemeData dark() {
    return theme(darkScheme());
  }
}
ThemeData theme(ColorScheme colorScheme) => ThemeData(
  useMaterial3: true,
  brightness: colorScheme.brightness,
  colorScheme: colorScheme,
  // textTheme: textTheme.apply(
  //   bodyColor: colorScheme.onSurface,
  //   displayColor: colorScheme.onSurface,
  // ),
  scaffoldBackgroundColor: colorScheme.background,
  canvasColor: colorScheme.surface,
);


