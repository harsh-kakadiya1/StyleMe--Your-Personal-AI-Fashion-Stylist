# StyleMe - Your Personal AI Fashion Stylist

StyleMe is a comprehensive Flutter-based mobile application designed to be your personal fashion assistant. It helps you digitize your wardrobe, create stylish outfit combinations, and manage your fashion choices with an intuitive and modern interface. Perfect for fashion enthusiasts who want to organize their closet and elevate their style game.

## Features

### Core Features (Fully Implemented)
- **Smart Wardrobe Management:** 
  - Add clothing items with camera or gallery photos
  - Categorize items (Top wear, Bottom wear) with detailed types
  - Search and filter through your wardrobe
  - Auto-save images to local storage
  
- **Outfit Creation & Pairing:**
  - Interactive swipe-based outfit pairing system
  - Mix and match tops and bottoms from your collection
  - Visual preview of outfit combinations
  - Save favorite outfit combinations
  
- **Smart Storage & Organization:**
  - Persistent local storage using SharedPreferences
  - Automatic data loading and synchronization
  - Clean outfit management with delete functionality
  - Invalid outfit auto-cleanup
  
- **Modern UI/UX:**
  - Beautiful Material Design 3 interface
  - Dark and light theme support
  - Smooth PageView navigation with animations
  - Responsive grid layouts and card designs
  - Custom color schemes and typography

### Upcoming Features
- **AI-Powered Outfit Suggestions:** Smart recommendations based on your wardrobe
- **Weekly Outfit Planner:** Plan your looks for the week ahead
- **Style Inspiration:** Discover new trends and fashion ideas

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed on your system:

- **Flutter SDK** (3.8.1 or later): [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (included with Flutter)
- **Android Studio** or **VS Code** with Flutter extensions
- **Android SDK** for Android development
- **Xcode** for iOS development (macOS only)

### Installation & Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/harsh-kakadiya1/StyleMe--Your-Personal-AI-Fashion-Stylist.git
   ```

2. **Navigate to the project directory**
   ```bash
   cd StyleMe--Your-Personal-AI-Fashion-Stylist
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Verify Flutter installation**
   ```bash
   flutter doctor
   ```

5. **Run the application**
   ```bash
   # For debug mode
   flutter run
   
   # For release mode
   flutter run --release
   ```

6. **Build APK (Optional)**
   ```bash
   flutter build apk --release
   ```

### App Structure

The app consists of 5 main screens accessible via bottom navigation:

1. **Wardrobe** - Add and manage your clothing items
2. **Pair** - Create outfit combinations by pairing tops and bottoms  
3. **Saved** - View and manage your saved outfit combinations
4. **AI Style** - AI-powered outfit suggestions (Coming Soon)
5. **Profile** - User settings and theme preferences

## Technology Stack

### Framework & Language
- **[Flutter](https://flutter.dev/)** `^3.8.1` - Cross-platform UI toolkit for building natively compiled applications
- **[Dart](https://dart.dev/)** - Programming language optimized for building UI

### Dependencies
- **[Provider](https://pub.dev/packages/provider)** `^6.1.1` - State management solution
- **[SharedPreferences](https://pub.dev/packages/shared_preferences)** `^2.2.2` - Local data persistence
- **[ImagePicker](https://pub.dev/packages/image_picker)** `^1.0.7` - Camera and gallery image selection
- **[PathProvider](https://pub.dev/packages/path_provider)** `^2.1.2` - Access to commonly used locations on filesystem
- **[GoogleFonts](https://pub.dev/packages/google_fonts)** `^6.2.1` - Custom typography with Google Fonts
- **[FlutterRemix](https://pub.dev/packages/flutter_remix)** `^0.0.3` - Beautiful icon library
- **[Animations](https://pub.dev/packages/animations)** `^2.0.11` - Smooth page transitions

### Architecture & Patterns
- **Provider Pattern** - For scalable state management
- **Repository Pattern** - For data handling and persistence
- **Component-Based Architecture** - Reusable UI components
- **Material Design 3** - Modern, accessible UI guidelines

### Data Management
- **Local Storage** - SharedPreferences for user data and settings
- **File System** - Local image storage for clothing photos
- **JSON Serialization** - Structured data persistence

## Technical Implementation

### App Architecture
```
lib/
├── main.dart                       # App entry point and navigation
├── models/                         # Data models
│   └── clothing_item.dart          # ClothingItem and OutfitCombination
├── providers/                      # State management
│   ├── wardrobe_provider.dart      # Wardrobe and outfit logic
│   └── theme_provider.dart         # Theme management
├── screens/                        # UI screens
│   ├── add_clothes_screen.dart     # Wardrobe management
│   ├── make_pair_screen.dart       # Outfit creation
│   ├── saved_outfits_screen.dart   # Saved combinations
│   └── profile_screen.dart         # Settings and profile
└── widgets/                        # Reusable components
    └── image_display_widget.dart   # Image handling
```

### UI Components
- **PageView Navigation** - Smooth page transitions with PageController
- **Custom Cards** - Elevated cards with rounded corners and shadows
- **Grid Layouts** - Responsive grid display for clothing items
- **Swipe Gestures** - Intuitive swipe-based outfit browsing
- **Modal Dialogs** - Confirmation dialogs and selection sheets

### Data Flow
1. **Image Capture** → Camera/Gallery → Local Storage → Display
2. **Item Creation** → Form Input → ClothingItem Model → SharedPreferences
3. **Outfit Pairing** → Item Selection → OutfitCombination → Persistent Storage
4. **State Management** → Provider Pattern → UI Updates → Data Sync

## Screenshots

| Wardrobe Screen | Outfit Pairing | Saved Outfits | Profile Settings |
|---|---|---|---|
| ![Screenshot_20250928_195757](https://github.com/user-attachments/assets/aa68668b-df34-45bf-8f35-bd67af078d34) | ![Screenshot_20250928_195812](https://github.com/user-attachments/assets/8bbefb0f-e471-401f-8875-b806f93f3bd5) | ![Screenshot_20250928_195840](https://github.com/user-attachments/assets/8142fc37-9724-477c-8784-cd8404c2563a) | ![Screenshot_20250928_195905](https://github.com/user-attachments/assets/92f11ac3-8598-421f-a96c-661d82489dff) |

## Key Features Explained

### Wardrobe Management
- **Add Items**: Take photos or select from gallery
- **Smart Categorization**: Automatic sorting by tops and bottoms
- **Search & Filter**: Find specific items quickly
- **Item Details**: View category, type, and date added

### Outfit Pairing
- **Swipe Interface**: Intuitive left/right swipe to browse items
- **Visual Preview**: See how tops and bottoms look together
- **Save Combinations**: Keep your favorite outfit pairings
- **Item Counter**: Track which items you're viewing

### Saved Outfits
- **Grid View**: Clean visual layout of saved combinations
- **Quick Delete**: Remove unwanted outfit combinations
- **Date Tracking**: See when outfits were created
- **Smart Validation**: Auto-remove invalid combinations

## Contributing

We welcome contributions from the community! Here's how you can help:

### Bug Reports
1. Check existing issues first
2. Create detailed bug reports with steps to reproduce
3. Include screenshots if applicable

### Feature Requests
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter/Dart best practices
- Use meaningful commit messages
- Add comments for complex logic
- Test your changes thoroughly
- Update documentation as needed

## Future Roadmap

### AI Features (In Development)
- **Smart Outfit Suggestions**: AI-powered recommendations based on your wardrobe
- **Weather Integration**: Outfit suggestions based on weather conditions  
- **Color Coordination**: Advanced color matching algorithms
- **Style Analysis**: Personal style insights and recommendations

### Enhanced Features
- **Social Sharing**: Share your outfits with friends
- **Wardrobe Analytics**: Insights into your clothing usage
- **Shopping Integration**: Suggest items to complete outfits
- **Outfit Planning**: Calendar-based outfit scheduling

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Authors & Contributors

- **[Harsh Kakadiya](https://github.com/harsh-kakadiya1)**
- **[Krish](https://github.com/Krish-kunjadiya)**

## Contact & Support

- **Repository**: [StyleMe--Your-Personal-AI-Fashion-Stylist](https://github.com/harsh-kakadiya1/StyleMe--Your-Personal-AI-Fashion-Stylist)
- **Issues**: [Report a Bug](https://github.com/harsh-kakadiya1/StyleMe--Your-Personal-AI-Fashion-Stylist/issues)
- **Discussions**: [Feature Requests](https://github.com/harsh-kakadiya1/StyleMe--Your-Personal-AI-Fashion-Stylist/discussions)

## Acknowledgments

- Flutter team for the amazing framework
- Material Design team for the design guidelines
- Google Fonts for beautiful typography
- RemixIcon for the comprehensive icon library
- The open-source community for inspiration and support

---

<div align="center">

**⭐ Star this repository if you found it helpful!**

*Cooked by Krish and Harsh*

</div>
