import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/globals.dart';

import 'utils/constants.dart';

import 'screens/connection_screen.dart';
import 'screens/address/add_address_screen.dart';
import 'screens/address/address_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/main_nav_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/order/order_screen.dart';

import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/category_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/region_provider.dart';
import 'providers/address_provider.dart';
import 'providers/order_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedIp = prefs.getString('server_ip');

  if (savedIp != null && savedIp.isNotEmpty) {
    AppConstants.baseUrl = 'http://$savedIp:8000';
  }
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
      child: MyApp(initialRoute: startRoute),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
      initialRoute: initialRoute,
      routes: {
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
