import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_boilerplate_hng11/services/dio_provider.dart';
import 'package:flutter_boilerplate_hng11/services/service_locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/company_user.dart';
import '../../services/response_model.dart';
import '../../utils/error/error.dart';

class AuthApi {
  //Inject the DioProvider Dependency
  DioProvider dioProvider = locator<DioProvider>();

  /// Ensure you call updateAccessToken after login and registration success.

  Future<ResponseModel?> registerSingleUser({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    String? adminSecret,
  }) async {
    try {
      final response = await dioProvider.post(
        '/auth/register',
        data: {
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'password': password,
          'admin_secret': adminSecret ?? "123",
        },
      );
      return response;
    } catch (e) {
      debugPrint('Error during registration: ${e.toString()}');
      return null;
    }
  }

  // forgot password api
  Future<ResponseModel?> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await dioProvider.post(
        '/auth/forgot-password',
        data: {
          'email': email,
        },
      );
      return response;
    } catch (e) {
      debugPrint('Error: ${e.toString()}');
      return null;
    }
  }

  // reset password api
  Future<ResponseModel?> resetPassword({
    required String email,
    required String otp,
    required String newpassword,
  }) async {
    try {
      final response = await dioProvider.patchUpdate(
        "/auth/password-reset",
        data: {
          'email': email,
          'token': otp,
          'new_Password': newpassword,
        },
      );
      return response;
    } catch (e) {
      debugPrint('Error In Resetting password: ${e.toString()}');
      return null;
    }
  }

  Future<ResponseModel?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dioProvider.post('auth/login', data: {
        'email': email,
        'password': password,
      });
      if (response != null && response.data != null) {
        String accessToken = response.data['access_token'];
        dioProvider.updateAccessToken(accessToken);
      }
      return response;
    } catch (e) {
      debugPrint('Error during login: ${e.toString()}');
      return null;
    }
  }

  // google sign in

  Future<ResponseModel> googleSignIn() async {
    try {
      final googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/userinfo.profile',
        ],
      );

      final googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;

        log('ID Token: ${googleAuth.idToken}');

        ResponseModel response = await dioProvider.post(
          'https://staging.api-nestjs.boilerplate.hng.tech/api/v1/auth/google?mobile=true',
          data: {
            'id_token': googleAuth.idToken,
          },
        );
        log(response.message!);

        log(response.accessToken!);

        if (response.message == 'Authentication successful') {
          log('Access Token: ${response.accessToken}');
          // Update the access token if needed
          dioProvider.updateAccessToken(response.accessToken ?? '');
        }

        return response;
      } else {
        throw Exception('Google sign-in failed');
      }
    } catch (e) {
      debugPrint('Error during Google sign-in: $e');
      rethrow; // Optional: Re-throw the error to handle it further up the call stack
    }
  }

  // Future<ResponseModel> googleSignin() async {
  //   try {
  //     final googlesignIn = GoogleSignIn(scopes: [
  //       'email',
  //       'https://www.googleapis.com/auth/userinfo.profile'
  //     ]);
  //     final googleUser = await googlesignIn.signIn();
  //     if (googleUser != null) {
  //       final googleAuth = await googleUser.authentication;

  //       log('id_token ${googleAuth.idToken!}');

  //       ResponseModel response = await dioProvider.post(
  //         'https://staging.api-nestjs.boilerplate.hng.tech/api/v1/auth/google?mobile=true',
  //         data: {"id_token": googleAuth.idToken},
  //       );
  //       // print('This is the response message ${response.statusCode}');

  //       if (response.message == 'Authentication successful') {
  //         print(response.accessToken);
  //         // dioProvider.updateAccessToken(response ?? '');
  //       }
  //       return response;
  //     }
  //   } catch (e) {
  //     debugPrint('Error during google signIn: ${e.toString()}');
  //   }
  // }
}

//Keep in mind that an organisation/company is generated for every user upon successful sign up.
Future<Company> registerCompany(Company company) async {
  DioProvider dioProvider = locator<DioProvider>();
  // An authenticated user is required for this request to be completed based on the api.
  // TODO: Remove access token in place of currently signed user's token.
  dioProvider.updateAccessToken(
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImFmMjdhMjBhLWJjMjMtNDI5NS05ZWM5LTA1MDM1ZGMyZmYzZCIsInN1YiI6ImFmMjdhMjBhLWJjMjMtNDI5NS05ZWM5LTA1MDM1ZGMyZmYzZCIsImVtYWlsIjoiamF5b2tlbG9sYTM0MUBnbWFpbC5jb20iLCJpYXQiOjE3MjM1NDUxODYsImV4cCI6MTcyMzU2Njc4Nn0.2fesL140kBGWTxooNycLbqZoFNULSRWUcXUXmLynOEc');
  var registeredCompany = Company.initial();
  try {
    var response = await dioProvider.post(
      'https://staging.api-nestjs.boilerplate.hng.tech/api/v1/organisations',
      data: company.toMap(),
    );
    registeredCompany = Company.fromMap(response.data['data']);
  } on DioException catch (e) {
    throw ApiError(message: e.message!);
  }

  return registeredCompany;
}
