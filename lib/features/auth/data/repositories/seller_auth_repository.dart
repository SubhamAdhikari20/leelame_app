// lib/features/auth/data/repositories/seller_auth_repository.dart
import 'dart:math';
import 'package:bcrypt/bcrypt.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/services/connectivity/network_info.dart';
import 'package:leelame/core/services/storage/user_session_service.dart';
import 'package:leelame/features/auth/data/datasources/local/seller_auth_local_datasource.dart';
import 'package:leelame/features/auth/data/datasources/remote/seller_auth_remote_datasource.dart';
import 'package:leelame/features/auth/data/datasources/seller_auth_datasource.dart';
import 'package:leelame/features/auth/data/models/user_api_model.dart';
import 'package:leelame/features/auth/data/models/user_hive_model.dart';
import 'package:leelame/features/auth/domain/entities/user_entity.dart';
import 'package:leelame/features/auth/domain/repositories/seller_auth_repository.dart';
import 'package:leelame/features/seller/data/models/seller_api_model.dart';
import 'package:leelame/features/seller/data/models/seller_hive_model.dart';
import 'package:leelame/features/seller/domain/entities/seller_entity.dart';

final sellerAuthRepositoryProvider = Provider<ISellerAuthRepository>((ref) {
  final sellerAuthLocalDatasource = ref.read(sellerAuthLocalDatasourceProvider);
  final sellerAuthRemoteDatasource = ref.read(
    sellerAuthRemoteDatasourceProvider,
  );
  final userSessionService = ref.read(userSessionServiceProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return SellerAuthRepository(
    sellerAuthLocalDatasource: sellerAuthLocalDatasource,
    sellerAuthRemoteDatasource: sellerAuthRemoteDatasource,
    userSessionService: userSessionService,
    networkInfo: networkInfo,
  );
});

class SellerAuthRepository implements ISellerAuthRepository {
  final ISellerAuthLocalDatasource _sellerAuthLocalDatasource;
  final ISellerAuthRemoteDatasource _sellerAuthRemoteDatasource;
  final UserSessionService _userSessionService;
  final INetworkInfo _networkInfo;

  SellerAuthRepository({
    required ISellerAuthLocalDatasource sellerAuthLocalDatasource,
    required ISellerAuthRemoteDatasource sellerAuthRemoteDatasource,
    required UserSessionService userSessionService,
    required INetworkInfo networkInfo,
  }) : _sellerAuthLocalDatasource = sellerAuthLocalDatasource,
       _sellerAuthRemoteDatasource = sellerAuthRemoteDatasource,
       _userSessionService = userSessionService,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failures, SellerEntity>> signUp(
    UserEntity userEntity,
    SellerEntity sellerEntity,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final userModel = UserApiModel.fromEntity(userEntity);
        final sellerModel = SellerApiModel.fromEntity(sellerEntity);

        final result = await _sellerAuthRemoteDatasource.signUp(
          userModel,
          sellerModel,
        );
        if (result == null) {
          return const Left(ApiFailure(message: "Failed to sign up seller!"));
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data["message"] ?? "Failed to sign up seller!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final userModel = UserHiveModel.fromEntity(userEntity);
        final sellerModel = SellerHiveModel.fromEntity(sellerEntity);

        // Check existing user
        final existingUserByEmail = await _sellerAuthLocalDatasource
            .getUserByEmail(userModel.email);

        // Check for existing contact number
        final existingSellerByContact = await _sellerAuthLocalDatasource
            .getSellerByPhoneNumber(sellerModel.phoneNumber ?? "");

        if ((existingSellerByContact != null) &&
            (existingUserByEmail?.isVerified == true)) {
          return const Left(
            LocalDatabaseFailure(message: "Phone Number already exists!"),
          );
        }

        final otp = List.generate(
          6,
          (_) => Random().nextInt(10),
        ).join().toString();

        // final hashedPassword = await FlutterBcrypt.hashPw(
        //   password: sellerEntity.password ?? "",
        //   salt: await FlutterBcrypt.salt(),
        // );

        final hashedPassword = BCrypt.hashpw(
          sellerEntity.password ?? "",
          BCrypt.gensalt(),
        );

        final expiryDate = DateTime.now().add(
          const Duration(minutes: 10),
        ); // Add 10 mins from 'now'

        UserHiveModel? newUser;
        SellerHiveModel? sellerProfile;
        bool isNewUserCreated = false;
        bool isNewProfileCreated = false;

        // Check for existing email
        if (existingUserByEmail != null) {
          if (existingUserByEmail.isVerified) {
            return const Left(
              LocalDatabaseFailure(message: "Email already registered!"),
            );
          }

          // Update existing unverified user
          newUser = await _sellerAuthLocalDatasource.updateBaseUser(
            existingUserByEmail.copyWith(
              verifyCode: otp,
              verifyCodeExpiryDate: expiryDate,
              role: userEntity.role,
              pendingOtpSend: true,
            ),
          );

          if (newUser == null) {
            return const Left(
              LocalDatabaseFailure(message: "Failed to update new user!"),
            );
          }

          // If sellerProfile does not exist for this user, create one
          sellerProfile = await _sellerAuthLocalDatasource.getSellerById(
            newUser.userId ?? "",
          );

          if (sellerProfile == null) {
            sellerProfile = await _sellerAuthLocalDatasource.createSeller(
              sellerModel,
            );

            isNewProfileCreated = true;
          } else {
            // Update if exists
            sellerProfile = await _sellerAuthLocalDatasource.updateSeller(
              existingSellerByContact!.copyWith(
                fullName: sellerModel.fullName,
                phoneNumber: sellerModel.phoneNumber,
                password: hashedPassword,
              ),
            );
          }
        } else {
          // Create new user
          newUser = await _sellerAuthLocalDatasource.createBaseUser(
            userModel.copyWith(
              email: userEntity.email,
              role: userEntity.role,
              isVerified: userEntity.isVerified,
              verifyCode: otp,
              verifyCodeExpiryDate: expiryDate,
              isPermanentlyBanned: userEntity.isPermanentlyBanned,
              pendingOtpSend: true,
            ),
          );

          if (newUser == null) {
            return const Left(
              LocalDatabaseFailure(message: "Failed to create new user!"),
            );
          }

          sellerProfile = await _sellerAuthLocalDatasource.createSeller(
            sellerModel.copyWith(
              baseUserId: newUser.userId,
              fullName: sellerEntity.fullName,
              phoneNumber: sellerEntity.phoneNumber,
              password: hashedPassword,
            ),
          );

          isNewUserCreated = true;
        }

        if (sellerProfile == null) {
          return const Left(LocalDatabaseFailure(message: "Seller not found!"));
        }

        // Queue the OTP email
        await _sellerAuthLocalDatasource.queueOtpEmail(
          toEmail: userModel.email,
          fullName: sellerModel.fullName,
          otp: otp,
          expiryDate: expiryDate,
        );

        return Right(sellerProfile.toEntity(userEntity: userEntity));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, SellerEntity>> login(
    String identifier,
    String password,
    String role,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _sellerAuthRemoteDatasource.login(
          identifier,
          password,
          role,
        );
        if (result == null) {
          return const Left(ApiFailure(message: "Failed to login seller!"));
        }

        final baseUser = result.baseUser;
        if (baseUser == null) {
          return const Left(
            ApiFailure(message: "Login Failed! Base user doesnot exist."),
          );
        }

        await _userSessionService.storeUserSession(
          userId: result.id!,
          email: baseUser.email,
          role: baseUser.role,
          fullName: result.fullName,
          phoneNumber: result.phoneNumber,
          profilePictureUrl: result.profilePictureUrl,
        );

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data["message"] ?? "Failed to login seller!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        // Email OR Phone Number
        if (role == "seller") {
          final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
          final phoneNumberRegex = RegExp(r'^[0-9]{10}$');

          final isEmailFormat = emailRegex.hasMatch(identifier);
          final isPhoneNumberFormat = phoneNumberRegex.hasMatch(identifier);

          if (!isEmailFormat && !isPhoneNumberFormat) {
            return const Left(
              LocalDatabaseFailure(
                message:
                    "Invalid identifier! Identifier must be a valid email or contact.",
              ),
            );
          }

          UserHiveModel? user;
          SellerHiveModel? sellerProfile;

          if (isEmailFormat) {
            user = await _sellerAuthLocalDatasource.getUserByEmail(identifier);
            if (user == null || user.role != role) {
              return const Left(
                LocalDatabaseFailure(
                  message:
                      "Invalid email! No seller account found with this email.",
                ),
              );
            }

            sellerProfile = await _sellerAuthLocalDatasource
                .getSellerByBaseUserId(user.userId ?? "");
            if (sellerProfile == null) {
              return const Left(
                LocalDatabaseFailure(
                  message: "Seller user not found for this base user id.",
                ),
              );
            }

            final hashedPassword = sellerProfile.password;
            if (hashedPassword == null) {
              return const Left(
                LocalDatabaseFailure(message: "Password not found for seller!"),
              );
            }

            // final isMatched = await FlutterBcrypt.verify(
            //   password: password,
            //   hash: hashedPassword,
            // );

            final isMatched = BCrypt.checkpw(password, hashedPassword);

            if (!isMatched) {
              return const Left(
                LocalDatabaseFailure(
                  message: "Invalid password! Please enter correct password.",
                ),
              );
            }

            return Right(sellerProfile.toEntity(userEntity: user.toEntity()));
          }

          // If identifier is a phone number;
          sellerProfile = await _sellerAuthLocalDatasource
              .getSellerByPhoneNumber(identifier);
          if (sellerProfile == null) {
            return const Left(
              LocalDatabaseFailure(
                message:
                    "Invalid phone number! No seller account found with this phone number.",
              ),
            );
          }

          final hashedPassword = sellerProfile.password;
          if (hashedPassword == null) {
            return const Left(
              LocalDatabaseFailure(message: "Password not found for seller!"),
            );
          }

          // final isMatched = await FlutterBcrypt.verify(
          //   password: password,
          //   hash: hashedPassword,
          // );

          final isMatched = BCrypt.checkpw(password, hashedPassword);

          if (!isMatched) {
            return const Left(
              LocalDatabaseFailure(
                message: "Invalid password! Please enter correct password.",
              ),
            );
          }

          user = await _sellerAuthLocalDatasource.getUserById(
            sellerProfile.baseUserId ?? "",
          );
          if (user == null) {
            return const Left(LocalDatabaseFailure(message: "User not found!"));
          }

          await _userSessionService.storeUserSession(
            userId: sellerProfile.sellerId!,
            email: user.email,
            role: user.role,
            fullName: sellerProfile.fullName,
            phoneNumber: sellerProfile.phoneNumber,
            profilePictureUrl: sellerProfile.profilePictureUrl,
          );

          return Right(sellerProfile.toEntity(userEntity: user.toEntity()));
        }

        return const Left(
          LocalDatabaseFailure(message: "Invalid role! Role is unknown."),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, bool>> verifyAccountRegistration(
    String email,
    String otp,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _sellerAuthRemoteDatasource
            .verifyAccountRegistration(email, otp);
        return Right(result);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data["message"] ?? "Failed to verify account!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final existingBaseUserByEmail = await _sellerAuthLocalDatasource
            .getUserByEmail(email);

        if (existingBaseUserByEmail == null) {
          return const Left(
            LocalDatabaseFailure(
              message: "Base user with this email does not exist!",
            ),
          );
        }

        if (existingBaseUserByEmail.isVerified) {
          return const Left(
            LocalDatabaseFailure(
              message: "This account is already verified! Please login.",
            ),
          );
        }

        if (existingBaseUserByEmail.verifyCode == null ||
            existingBaseUserByEmail.verifyCodeExpiryDate == null) {
          return const Left(
            LocalDatabaseFailure(
              message: "No OTP request found! Please request for a new OTP.",
            ),
          );
        }

        final expiryDate = DateTime.parse(
          existingBaseUserByEmail.verifyCodeExpiryDate.toString(),
        );
        if (DateTime.now().isAfter(expiryDate)) {
          return const Left(
            LocalDatabaseFailure(
              message: "OTP has expired! Please request for a new OTP.",
            ),
          );
        }

        if (existingBaseUserByEmail.verifyCode != otp) {
          return const Left(
            LocalDatabaseFailure(message: "Invalid OTP! Please try again."),
          );
        }

        final existingSellerByBaseUserId = await _sellerAuthLocalDatasource
            .getSellerByBaseUserId(existingBaseUserByEmail.userId ?? "");

        if (existingSellerByBaseUserId == null) {
          return const Left(
            LocalDatabaseFailure(message: "Seller with this id not found!"),
          );
        }

        final updatedUser = await _sellerAuthLocalDatasource.updateBaseUser(
          existingBaseUserByEmail.copyWith(
            isVerified: true,
            verifyCode: null,
            verifyCodeExpiryDate: null,
          ),
        );

        if (updatedUser == null) {
          return const Left(
            LocalDatabaseFailure(
              message: "Base user is not updated and not found!",
            ),
          );
        }

        return Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, bool>> logout() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _sellerAuthRemoteDatasource.logout();
        if (!result) {
          return const Left(ApiFailure(message: "Failed to logout seller!"));
        }
        await _userSessionService.clearUserSession();
        return Right(result);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data["message"] ?? "Failed to logout seller!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        await _userSessionService.clearUserSession();
        return const Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, SellerEntity>> getCurrentSeller(
    String sellerId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final seller = await _sellerAuthRemoteDatasource.getCurrentSeller(
          sellerId,
        );
        if (seller == null) {
          return const Left(
            ApiFailure(message: "Failed to get current seller!"),
          );
        }

        return Right(seller.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data["message"] ?? "Failed to get current seller!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final seller = await _sellerAuthLocalDatasource.getSellerById(sellerId);
        if (seller == null) {
          return const Left(
            LocalDatabaseFailure(message: "Failed to get current seller!"),
          );
        }

        final user = await _sellerAuthLocalDatasource.getUserById(
          seller.baseUserId ?? "",
        );
        if (user == null) {
          return const Left(
            LocalDatabaseFailure(message: "Failed to get current base user!"),
          );
        }

        return Right(seller.toEntity(userEntity: user.toEntity()));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }
}
