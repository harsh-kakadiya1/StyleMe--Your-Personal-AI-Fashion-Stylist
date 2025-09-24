import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/wardrobe_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/add_clothes_screen.dart';
import 'screens/make_pair_screen.dart';
import 'screens/saved_outfits_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const StyleMeApp());
}

class StyleMeApp extends StatelessWidget {
  const StyleMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WardrobeProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final textTheme = Theme.of(context).textTheme;

          return MaterialApp(
            title: 'StyleMe',
            debugShowCheckedModeBanner: false,
            theme: _buildLightTheme(textTheme),
            darkTheme: _buildDarkTheme(textTheme),
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const StyleMeHomePage(),
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme(TextTheme textTheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF7F7F7),
      primaryColor: const Color(0xFF2C3E50),
      textTheme: GoogleFonts.outfitTextTheme(textTheme).copyWith(
        displayLarge: GoogleFonts.prata(
          textStyle: textTheme.displayLarge,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2C3E50),
        ),
        headlineSmall: GoogleFonts.prata(
          textStyle: textTheme.headlineSmall,
          color: const Color(0xFF2C3E50),
        ),
        titleLarge: GoogleFonts.outfit(
          textStyle: textTheme.titleLarge,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2C3E50),
        ),
        bodyMedium: GoogleFonts.outfit(
          textStyle: textTheme.bodyMedium,
          color: const Color(0xFF34495E),
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2C3E50),
        primary: const Color(0xFF2C3E50),
        secondary: const Color(0xFFD2B48C),
        surface: Colors.white,
        background: const Color(0xFFF7F7F7),
        onBackground: const Color(0xFF2C3E50),
        error: const Color(0xFFE74C3C),
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFF7F7F7),
        foregroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.prata(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2C3E50),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF2C3E50),
        unselectedItemColor: Color(0xFFBDC3C7),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  ThemeData _buildDarkTheme(TextTheme textTheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      primaryColor: const Color(0xFF3498DB),
      textTheme: GoogleFonts.outfitTextTheme(textTheme).copyWith(
        displayLarge: GoogleFonts.prata(
          textStyle: textTheme.displayLarge,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineSmall: GoogleFonts.prata(
          textStyle: textTheme.headlineSmall,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.outfit(
          textStyle: textTheme.titleLarge,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyMedium: GoogleFonts.outfit(
          textStyle: textTheme.bodyMedium,
          color: const Color(0xFFE0E0E0),
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF3498DB),
        primary: const Color(0xFF3498DB),
        secondary: const Color(0xFFE67E22),
        surface: const Color(0xFF2C2C2C),
        background: const Color(0xFF1A1A1A),
        onBackground: Colors.white,
        onSurface: Colors.white,
        error: const Color(0xFFE74C3C),
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.prata(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF2C2C2C),
        selectedItemColor: Color(0xFF3498DB),
        unselectedItemColor: Color(0xFF7F8C8D),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}

class StyleMeHomePage extends StatefulWidget {
  const StyleMeHomePage({super.key});

  @override
  State<StyleMeHomePage> createState() => _StyleMeHomePageState();
}

class _StyleMeHomePageState extends State<StyleMeHomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize data when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WardrobeProvider>().initializeData();
    });
  }

  static const List<Widget> _widgetOptions = <Widget>[
    AddClothesScreen(),
    MakePairScreen(),
    SavedOutfitsScreen(),
    CalendarScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StyleMe')),
      body: PageTransitionSwitcher(
        transitionBuilder:
            (
              Widget child,
              Animation<double> primaryAnimation,
              Animation<double> secondaryAnimation,
            ) {
              return FadeThroughTransition(
                animation: primaryAnimation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            },
        child: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(FlutterRemix.shirt_line),
              activeIcon: Icon(FlutterRemix.shirt_fill),
              label: 'Wardrobe',
            ),
            BottomNavigationBarItem(
              icon: Icon(FlutterRemix.links_line),
              activeIcon: Icon(FlutterRemix.links_fill),
              label: 'Pair',
            ),
            BottomNavigationBarItem(
              icon: Icon(FlutterRemix.heart_3_line),
              activeIcon: Icon(FlutterRemix.heart_3_fill),
              label: 'Saved',
            ),
            BottomNavigationBarItem(
              icon: Icon(FlutterRemix.calendar_line),
              activeIcon: Icon(FlutterRemix.calendar_fill),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(FlutterRemix.user_line),
              activeIcon: Icon(FlutterRemix.user_fill),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
