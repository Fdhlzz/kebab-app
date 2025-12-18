import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 1. Import SharedPreferences

// --- UTILS ---
import 'utils/constants.dart'; // 1. Import Constants to update URL

// --- SCREENS ---
import 'screens/connection_screen.dart'; // 1. Import Connection Screen
import 'screens/address/add_address_screen.dart';
import 'screens/address/address_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/main_nav_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/order/order_screen.dart';

// --- PROVIDERS ---
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/category_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/region_provider.dart';
import 'providers/address_provider.dart';
import 'providers/order_provider.dart';

// 2. Change main() to 'async'
void main() async {
  // 3. Ensure bindings are initialized (required for async main)
  WidgetsFlutterBinding.ensureInitialized();

  // 4. LOGIC: Check for Saved IP Address
  final prefs = await SharedPreferences.getInstance();
  final savedIp = prefs.getString('server_ip');

  // 5. If IP exists, overwrite AppConstants immediately
  if (savedIp != null && savedIp.isNotEmpty) {
    AppConstants.baseUrl = 'http://$savedIp:8000';
  }

  // 6. Decide which screen to show first
  // If NO IP -> Go to ConnectionScreen
  // If IP Exists -> Go to MainNavScreen (Your default)
  String startRoute = (savedIp != null && savedIp.isNotEmpty)
      ? MainNavScreen.routeName
      : ConnectionScreen.routeName;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuth()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => RegionProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      // Pass the calculated startRoute to MyApp
      child: MyApp(initialRoute: startRoute),
    ),
  );
}

class MyApp extends StatelessWidget {
  // 7. Accept initialRoute as a parameter
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kebab App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF9F43),
          primary: const Color(0xFFFF9F43),
          secondary: const Color(0xFFFF7643),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF5F6F9),
      ),
      // 8. Use the dynamic initialRoute
      initialRoute: initialRoute,
      routes: {
        // 9. Register ConnectionScreen Route
        ConnectionScreen.routeName: (context) => const ConnectionScreen(),

        MainNavScreen.routeName: (context) => const MainNavScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        CartScreen.routeName: (context) => const CartScreen(),
        SignInScreen.routeName: (context) => const SignInScreen(),
        SignUpScreen.routeName: (context) => const SignUpScreen(),
        AddressListScreen.routeName: (ctx) => const AddressListScreen(),
        AddAddressScreen.routeName: (ctx) => const AddAddressScreen(),
        CheckoutScreen.routeName: (ctx) => const CheckoutScreen(),
        OrderScreen.routeName: (ctx) => const OrderScreen(),
      },
    );
  }
}
