import 'dart:developer';

import 'package:dio/dio.dart';

import '../utils/widgets/custom_snackbar.dart';

class ErrorHandlers {
  static void allErrorHandler(error) {
    if (error is TypeError) {
      log('Check your code for type error : ${error.stackTrace}');
      return;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        showSnackBar('Connection timed out');
        break;

      case DioExceptionType.connectionError:
        showSnackBar('Connection error');
        break;

      case DioExceptionType.cancel:
        log('Request cancelled');
        break;

      case DioExceptionType.badResponse:
        _serverErrorHandler(error.response!);
        break;

      case DioExceptionType.badCertificate:
        log('Bad certificate');
        break;

      case DioExceptionType.unknown:
        if (error.message!.contains('SocketException')) {
          showSnackBar('Check your internet connection');
          break;
        } else {
          showSnackBar('Something went wrong');
          break;
        }

      default:
        _serverErrorHandler(error.response!);
    }
  }

  static void _serverErrorHandler(Response response) {
    log('Server related Error caught ::::::: ${response.toString()}');

    if (response.data != null) {
      log('llhhhhhhh');
      try {
        showSnackBar(response.data['message'].toString());
      } catch (e) {
        showSnackBar('Seems something happened. ');
      }
    } else {
      showSnackBar('Seems something happened');
    }

    switch (response.statusCode) {
      case 400:
      case 401:

      // case 403:
      // case 404:
      case 500:
      default:
    }
  }
}
