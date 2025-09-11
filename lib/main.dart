import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
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
    return ChangeNotifierProvider(
      create: (context) => WardrobeProvider(),
      child: MaterialApp(
        title: 'Style Me',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          useMaterial3: true,
          textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: Colors.grey[50],
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
  int _selectedIndex = 2; // Start with the "Add clothes" tab selected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'STYLE ME',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
      ),
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
        child: _buildBody(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          elevation: 8,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.style, size: _selectedIndex == 0 ? 28 : 24),
              label: 'Make Pair',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.auto_awesome,
                size: _selectedIndex == 1 ? 28 : 24,
              ),
              label: 'AI Suggestions',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_a_photo,
                  color: Colors.white,
                  size: _selectedIndex == 2 ? 32 : 28,
                ),
              ),
              label: 'Add Clothes',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.calendar_month,
                size: _selectedIndex == 3 ? 28 : 24,
              ),
              label: 'Weekly Planner',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checkroom, size: _selectedIndex == 4 ? 28 : 24),
              label: 'Saved Outfits',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const MakePairScreen();
      case 2:
        return const AddClothesScreen();
      case 4:
        return const SavedOutfitsScreen();
      default:
        return _buildPlaceholder(
          icon: _selectedIndex == 1 ? Icons.auto_awesome : Icons.calendar_month,
          title: _selectedIndex == 1 ? 'AI Suggestions' : 'Weekly Planner',
          subtitle: 'This feature is coming soon!',
        );
    }
  }

  Widget _buildPlaceholder({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      key: ValueKey(title),
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              subtitle,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
