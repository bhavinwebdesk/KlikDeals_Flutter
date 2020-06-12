import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:vendor/ApiBloc/ApiBloc_state.dart';
import 'package:vendor/ApiBloc/repositories/ApiBloc_repository.dart';
import 'package:vendor/ChangePassword/ChangePasswordState.dart';
import 'package:vendor/LoginScreen/LoginStates.dart';
import 'package:vendor/commons/AppExceptions.dart';

@immutable
abstract class ApiBlocEvent extends Equatable {}

class TokenGenerateEvent extends ApiBlocEvent {
  final String token;

  TokenGenerateEvent(this.token);

  @override
  List<Object> get props => [token];
}

class ReloadEvent extends ApiBlocEvent {
  final bool isReload;

  ReloadEvent(this.isReload);

  @override
  List<Object> get props => [isReload];
}

class LoginEvent extends ApiBlocEvent {
  final String email;
  final String pass;

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["email"] = email;
    map["password"] = pass;

    return map;
  }

  LoginEvent(this.email, this.pass);

  @override
  List<Object> get props => [this.email, this.pass];
}

class CouponListEvent extends ApiBlocEvent {
  final int perPage;
  final String action;
  final int currentPage;

  CouponListEvent(
    this.perPage,
    this.action,
    this.currentPage,
  );

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["per_page"] = perPage;
    if (action != null && action.isNotEmpty) {
      map["action"] = action;
    }
    map["page"] = currentPage;
    return map;
  }

  List<Object> get props => [this.perPage, this.action];
}

class CouponDeleteEvent extends ApiBlocEvent {
  final String couponId;

  CouponDeleteEvent(this.couponId);

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = couponId;
    return map;
  }

  List<Object> get props => [this.couponId];
}

class GetProfileEvent extends ApiBlocEvent {
  GetProfileEvent();

  List<Object> get props => [null];
}

class AddCouponEvent extends ApiBlocEvent {
  final String couponCodeValue;
  final String startDateValue;
  final String endDateValue;
  final String descValue;
  final File image;
  final bool isSelected;

  AddCouponEvent(this.couponCodeValue, this.startDateValue, this.endDateValue,
      this.descValue, this.image, this.isSelected);

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["coupon_code"] = couponCodeValue;
    map["start_date"] = startDateValue;
    map["end_date"] = endDateValue;
    map["description"] = descValue;
    map["is_repeat"] = isSelected ? "1" : "0";

    return map;
  }

  List<Object> get props => [
        this.couponCodeValue,
        this.startDateValue,
        this.endDateValue,
        this.descValue,
        this.image
      ];
}

class EditCouponEvent extends ApiBlocEvent {
  final String couponCodeValue;
  final String startDateValue;
  final String endDateValue;
  final String descValue;
  final String id;
  final File image;
  final bool isSelected;

  EditCouponEvent(this.couponCodeValue, this.startDateValue, this.endDateValue,
      this.descValue, this.id, this.image, this.isSelected);

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["coupon_code"] = couponCodeValue;
    map["start_date"] = startDateValue;
    map["end_date"] = endDateValue;
    map["description"] = descValue;
    map["id"] = id;
    map["is_repeat"] = isSelected ? "1" : "0";

    return map;
  }

  List<Object> get props => [
        this.couponCodeValue,
        this.startDateValue,
        this.endDateValue,
        this.descValue,
        this.id,
        this.image
      ];
}

class UpdateProfileEvent extends ApiBlocEvent {
  final String name;
  final String address;
  final String mapLat;
  final String mapLog;
  final String phoneNumber;
  final String email;
  final String website;
  final String about;
  final File logo;
  final File banner;

  UpdateProfileEvent(
      this.name,
      this.address,
      this.mapLat,
      this.mapLog,
      this.phoneNumber,
      this.email,
      this.website,
      this.about,
      this.logo,
      this.banner);

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["name"] = name;
    map["address"] = address;
    map["map_lat"] = mapLat;
    map["map_log"] = mapLog;
    map["phone_number"] = phoneNumber;
    map["email"] = email;
    map["website"] = website;
    map["about"] = about;

    return map;
  }

  //if(website!=null && website.trim().isNotEmpty )

  List<Object> get props => [
        this.name,
        this.address,
        this.mapLat,
        this.mapLog,
        this.phoneNumber,
        this.email,
        this.website,
        this.about,
        this.logo,
        this.banner
      ];
}

class ResetPasswordEvent extends ApiBlocEvent {
  final String emailAddress;

  ResetPasswordEvent(this.emailAddress);

  @override
  List<Object> get props => [emailAddress];

  Stream<ApiBlocState> getProcessAsync(
      ApiBlocRepository playerRepository) async* {
    yield ApiFetchingState();
    try {
      final response = await playerRepository.resetPassword(toMap());
      if (response.status) {
        yield PasswordSuccessState(response);
      } else {
        yield PasswordErrorState(response);
      }
    } on NoInternetException catch (_) {
      print("No Internet exception");
      yield NoInternetState(true);
    } on RetryErrorException catch (_) {
      print("Retry error exception");
      yield NoInternetState(false);
    } catch (e, s) {
      print("error $e");
      print("stacktrace $s");
      yield ApiErrorState();
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["email"] = emailAddress;
    return map;
  }
}
class ChangePasswordEvent extends ApiBlocEvent {
  final String oldPassword;
  final String newPassword;

  ChangePasswordEvent(this.oldPassword, this.newPassword);

  @override
  List<Object> get props => [oldPassword,newPassword];

  Stream<ApiBlocState> getProcessAsync(
      ApiBlocRepository playerRepository) async* {
    yield ApiFetchingState();
    try {
      final response = await playerRepository.changePassword(toMap());
      if (response.status) {
        yield ChangePasswordSuccessState(response);
      } else {
        yield ChangePasswordErrorState(response);
      }
    } on NoInternetException catch (_) {
      print("No Internet exception");
      yield NoInternetState(true);
    } on RetryErrorException catch (_) {
      print("Retry error exception");
      yield NoInternetState(false);
    } catch (e, s) {
      print("error $e");
      print("stacktrace $s");
      yield ApiErrorState();
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["old_password"] = oldPassword;
    map["new_password"] = newPassword;
    return map;
  }
}