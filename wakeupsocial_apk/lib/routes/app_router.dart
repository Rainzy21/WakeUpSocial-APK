import 'package:flutter/material.dart';
import 'app_routes.dart';

// Auth
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';

// Landing
import '../features/landing/screens/landing_screen.dart';

// Main Navigation (Bottom Nav Shell)
import '../features/navigation/main_navigation.dart';

// Menu
import '../features/menu/screens/menu_screen.dart';

// Cart
import '../features/cart/screens/cart_screen.dart';

// Order
import '../features/order/screens/order_screen.dart';
import '../features/order/screens/order_detail_screen.dart';
import '../features/order/screens/order_history_screen.dart';

// Order Tracking
import '../features/order_tracking/screens/order_tracking_screen.dart';

// Profile
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/profile_detail_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';

// Help
import '../features/help/screens/privacy_policy_screen.dart';
import '../features/help/screens/help_center_screen.dart';
import '../features/help/screens/contact_us_screen.dart';

/// Generates routes for the app based on [RouteSettings].
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.landing:
        return _buildRoute(const LandingScreen());
      case AppRoutes.home:
        return _buildRoute(const MainNavigation());
      case AppRoutes.login:
        return _buildRoute(const LoginScreen());
      case AppRoutes.signUp:
        return _buildRoute(const SignUpScreen());
      case AppRoutes.menu:
        return _buildRoute(const MenuScreen());
      case AppRoutes.cart:
        return _buildRoute(const CartScreen());
      case AppRoutes.order:
        return _buildRoute(const OrderScreen());
      case AppRoutes.orderDetail:
        final orderId = settings.arguments as String;
        return _buildRoute(OrderDetailScreen(orderId: orderId));
      case AppRoutes.orderHistory:
        return _buildRoute(const OrderHistoryScreen());
      case AppRoutes.orderTracking:
        final orderId = settings.arguments as String;
        return _buildRoute(OrderTrackingScreen(orderId: orderId));
      case AppRoutes.profile:
        return _buildRoute(const ProfileScreen());
      case AppRoutes.profileDetail:
        return _buildRoute(const ProfileDetailScreen());
      case AppRoutes.editProfile:
        return _buildRoute(const EditProfileScreen());
      case AppRoutes.privacyPolicy:
        return _buildRoute(const PrivacyPolicyScreen());
      case AppRoutes.helpCenter:
        return _buildRoute(const HelpCenterScreen());
      case AppRoutes.contactUs:
        return _buildRoute(const ContactUsScreen());
      default:
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }

  static MaterialPageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}
