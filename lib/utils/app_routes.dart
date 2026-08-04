import 'package:flutter/material.dart';

import '../models/pet.dart';
import '../pages/appointments/new_appointment_page.dart';
import '../pages/appointments/service_details_page.dart';
import '../pages/auth/forgot_password_page.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/home/main_shell.dart';
import '../pages/pets/pet_details_page.dart';
import '../pages/pets/pet_form_page.dart';
import '../pages/profile/change_password_page.dart';
import '../pages/profile/edit_profile_page.dart';
import '../pages/splash_page.dart';

/// Nomes de rota e fábrica central de navegação.
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/recuperar-senha';
  static const String main = '/app';
  static const String petForm = '/pets/formulario';
  static const String petDetails = '/pets/detalhes';
  static const String newAppointment = '/agendamentos/novo';
  static const String serviceDetails = '/servicos/detalhes';
  static const String editProfile = '/perfil/editar';
  static const String changePassword = '/perfil/senha';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final Object? args = settings.arguments;
    switch (settings.name) {
      case splash:
        return _route(const SplashPage(), settings);
      case login:
        return _route(const LoginPage(), settings);
      case register:
        return _route(const RegisterPage(), settings);
      case forgotPassword:
        return _route(const ForgotPasswordPage(), settings);
      case main:
        return _route(
          MainShell(initialIndex: args is int ? args : 0),
          settings,
        );
      case petForm:
        return _route(PetFormPage(pet: args is Pet ? args : null), settings);
      case petDetails:
        return _route(PetDetailsPage(petId: args! as String), settings);
      case newAppointment:
        return _route(
          NewAppointmentPage(initialPetId: args is String ? args : null),
          settings,
        );
      case serviceDetails:
        return _route(
          ServiceDetailsPage(args: args! as ServiceDetailsArgs),
          settings,
        );
      case editProfile:
        return _route(const EditProfilePage(), settings);
      case changePassword:
        return _route(const ChangePasswordPage(), settings);
      default:
        return null;
    }
  }

  static MaterialPageRoute<dynamic> _route(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<dynamic>(
      builder: (BuildContext context) => page,
      settings: settings,
    );
  }
}
