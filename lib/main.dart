import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/wardrobe_provider.dart';
import 'screens/add_clothes_screen.dart';
import 'screens/make_pair_screen.dart';
import 'screens/saved_outfits_screen.dart';

void main() {
  runApp(const StyleMeApp());
}

class StyleMeApp extends StatelessWidget {
  const StyleMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ChangeNotifierProvider(
      create: (context) => WardrobeProvider(),
      child: MaterialApp(
        title: 'StyleMe',
        theme: ThemeData(
          useMaterial3: true,
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
            background: const Color(0xFFF7F7F7),
            onBackground: const Color(0xFF2C3E50),
            error: const Color(0xFFE74C3C),
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
        ),
        home: const StyleMeHomePage(),
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

  static const List<Widget> _widgetOptions = <Widget>[
    AddClothesScreen(),
    MakePairScreen(),
    SavedOutfitsScreen(),
    Center(child: Text('Coming Soon')),
    Center(child: Text('Coming Soon')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StyleMe'),
      ),
      body: PageTransitionSwitcher(
        transitionBuilder: (
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
        child: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey[200]!, width: 1.0),
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
              icon: Icon(FlutterRemix.magic_line),
              activeIcon: Icon(FlutterRemix.magic_fill),
              label: 'Suggest',
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
