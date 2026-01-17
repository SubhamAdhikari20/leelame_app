// lib/features/auth/data/repositories/buyer_auth_repository.dart
import 'dart:math';
import 'package:bcrypt/bcrypt.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/services/connectivity/network_info.dart';
import 'package:leelame/core/services/storage/user_session_service.dart';
import 'package:leelame/features/auth/data/datasources/buyer_auth_datasource.dart';
import 'package:leelame/features/auth/data/datasources/local/buyer_auth_local_datasource.dart';
import 'package:leelame/features/auth/data/datasources/remote/buyer_auth_remote_datasource.dart';
import 'package:leelame/features/auth/data/models/user_api_model.dart';
import 'package:leelame/features/auth/data/models/user_hive_model.dart';
import 'package:leelame/features/auth/domain/entities/user_entity.dart';
import 'package:leelame/features/auth/domain/repositories/buyer_auth_repository.dart';
import 'package:leelame/features/buyer/data/models/buyer_api_model.dart';
import 'package:leelame/features/buyer/data/models/buyer_hive_model.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';

final buyerAuthRepositoryProvider = Provider<IBuyerAuthRepository>((ref) {
  final buyerAuthLocalDatasource = ref.read(buyerAuthLocalDatasourceProvider);
  final buyerAuthRemoteDatasource = ref.read(buyerAuthRemoteDatasourceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return BuyerAuthRepository(
    buyerAuthLocalDatasource: buyerAuthLocalDatasource,
    buyerAuthRemoteDatasource: buyerAuthRemoteDatasource,
    userSessionService: userSessionService,
    networkInfo: networkInfo,
  );
});

class BuyerAuthRepository implements IBuyerAuthRepository {
  final IBuyerAuthLocalDatasource _buyerAuthLocalDatasource;
  final IBuyerAuthRemoteDatasource _buyerAuthRemoteDatasource;
  final UserSessionService _userSessionService;
  final INetworkInfo _networkInfo;

  BuyerAuthRepository({
    required IBuyerAuthLocalDatasource buyerAuthLocalDatasource,
    required IBuyerAuthRemoteDatasource buyerAuthRemoteDatasource,
    required UserSessionService userSessionService,
    required INetworkInfo networkInfo,
  }) : _buyerAuthLocalDatasource = buyerAuthLocalDatasource,
       _buyerAuthRemoteDatasource = buyerAuthRemoteDatasource,
       _userSessionService = userSessionService,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failures, BuyerEntity>> signUp(
    UserEntity userEntity,
    BuyerEntity buyerEntity,
  ) async {
    // Check for internet connection
    if (await _networkInfo.isConnected) {
      try {
        final userModel = UserApiModel.fromEntity(userEntity);
        final buyerModel = BuyerApiModel.fromEntity(buyerEntity);

        final result = await _buyerAuthRemoteDatasource.signUp(
          userModel,
          buyerModel,
        );
        if (result == null) {
          return const Left(ApiFailure(message: "Failed to sign up buyer!"));
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data["message"] ?? "Failed to sign up buyer!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final userModel = UserHiveModel.fromEntity(userEntity);
        final buyerModel = BuyerHiveModel.fromEntity(buyerEntity);

        // Check existing user
        final existingUserByEmail = await _buyerAuthLocalDatasource
            .getUserByEmail(userModel.email);

        // Check for existing username
        final existingBuyerByUsername = await _buyerAuthLocalDatasource
            .getBuyerByUsername(buyerModel.username ?? "");

        if ((existingBuyerByUsername != null) &&
            (existingUserByEmail?.isVerified == true)) {
          return const Left(
            LocalDatabaseFailure(message: "Username already exists!"),
          );
        }

        // Check for existing contact number
        final existingBuyerByContact = await _buyerAuthLocalDatasource
            .getBuyerByPhoneNumber(buyerModel.phoneNumber ?? "");

        if ((existingBuyerByContact != null) &&
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
        //   password: buyerEntity.password ?? "",
        //   salt: await FlutterBcrypt.salt(),
        // );

        final hashedPassword = BCrypt.hashpw(
          buyerEntity.password ?? "",
          BCrypt.gensalt(),
        );

        final expiryDate = DateTime.now().add(
          const Duration(minutes: 10),
        ); // Add 10 mins from 'now'

        UserHiveModel? newUser;
        BuyerHiveModel? buyerProfile;
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
          newUser = await _buyerAuthLocalDatasource.updateBaseUser(
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

          // If buyerProfile does not exist for this user, create one
          buyerProfile = await _buyerAuthLocalDatasource.getBuyerById(
            newUser.userId ?? "",
          );

          if (buyerProfile == null) {
            buyerProfile = await _buyerAuthLocalDatasource.createBuyer(
              buyerModel,
            );

            isNewProfileCreated = true;
          } else {
            // Update if exists
            buyerProfile = await _buyerAuthLocalDatasource.updateBuyer(
              existingBuyerByUsername!.copyWith(
                fullName: buyerModel.fullName,
                username: buyerModel.username,
                phoneNumber: buyerModel.phoneNumber,
                password: hashedPassword,
                termsAccepted: buyerModel.termsAccepted,
              ),
            );
          }
        } else {
          // Create new user
          newUser = await _buyerAuthLocalDatasource.createBaseUser(
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

          buyerProfile = await _buyerAuthLocalDatasource.createBuyer(
            buyerModel.copyWith(
              userId: newUser.userId,
              fullName: buyerEntity.fullName,
              username: buyerEntity.username,
              phoneNumber: buyerEntity.phoneNumber,
              password: hashedPassword,
              termsAccepted: buyerEntity.termsAccepted,
            ),
          );

          isNewUserCreated = true;
        }

        if (buyerProfile == null) {
          return const Left(LocalDatabaseFailure(message: "Buyer not found!"));
        }

        // Queue the OTP email
        await _buyerAuthLocalDatasource.queueOtpEmail(
          toEmail: userModel.email,
          fullName: buyerModel.fullName,
          otp: otp,
          expiryDate: expiryDate,
        );

        return Right(buyerProfile.toEntity(userEntity: userEntity));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, BuyerEntity>> login(
    String identifier,
    String password,
    String role,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _buyerAuthRemoteDatasource.login(
          identifier,
          password,
          role,
        );
        if (result == null) {
          return const Left(ApiFailure(message: "Failed to login buyer!"));
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data["message"] ?? "Failed to login buyer!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        // Email OR Username
        if (role == "buyer") {
          final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
          final usernameRegex = RegExp(r'^[a-zA-Z0-9_.]{3,20}$');

          final isEmailFormat = emailRegex.hasMatch(identifier);
          final isUsernameFormat = usernameRegex.hasMatch(identifier);

          if (!isEmailFormat && !isUsernameFormat) {
            return const Left(
              LocalDatabaseFailure(
                message:
                    "Invalid identifier! Identifier must be a valid username or email.",
              ),
            );
          }

          UserHiveModel? user;
          BuyerHiveModel? buyerProfile;

          if (isEmailFormat) {
            user = await _buyerAuthLocalDatasource.getUserByEmail(identifier);
            if (user == null || user.role != role) {
              return const Left(
                LocalDatabaseFailure(
                  message:
                      "Invalid email! No buyer account found with this email.",
                ),
              );
            }

            buyerProfile = await _buyerAuthLocalDatasource.getBuyerByBaseUserId(
              user.userId ?? "",
            );
            if (buyerProfile == null) {
              return const Left(
                LocalDatabaseFailure(
                  message: "Buyer user not found for this base user id.",
                ),
              );
            }

            final hashedPassword = buyerProfile.password;
            if (hashedPassword == null) {
              return const Left(
                LocalDatabaseFailure(message: "Password not found for buyer!"),
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

            return Right(buyerProfile.toEntity(userEntity: user.toEntity()));
          }

          // If identifier is a username;
          buyerProfile = await _buyerAuthLocalDatasource.getBuyerByUsername(
            identifier,
          );
          if (buyerProfile == null) {
            return const Left(
              LocalDatabaseFailure(
                message:
                    "Invalid username! No buyer account found with this username.",
              ),
            );
          }

          final hashedPassword = buyerProfile.password;
          if (hashedPassword == null) {
            return const Left(
              LocalDatabaseFailure(message: "Password not found for buyer!"),
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

          user = await _buyerAuthLocalDatasource.getUserById(
            buyerProfile.userId ?? "",
          );
          if (user == null) {
            return const Left(LocalDatabaseFailure(message: "User not found!"));
          }

          await _userSessionService.storeUserSession(
            userId: buyerProfile.buyerId!,
            email: user.email,
            role: user.role,
            fullName: buyerProfile.fullName,
            username: buyerProfile.username,
            phoneNumber: buyerProfile.phoneNumber,
            profilePictureUrl: buyerProfile.profilePictureUrl,
          );

          return Right(buyerProfile.toEntity(userEntity: user.toEntity()));
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
    String username,
    String otp,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _buyerAuthRemoteDatasource
            .verifyAccountRegistration(username, otp);
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
        final existingBuyerByUsername = await _buyerAuthLocalDatasource
            .getBuyerByUsername(username);

        if (existingBuyerByUsername == null) {
          return const Left(
            LocalDatabaseFailure(
              message: "Buyer with this username does not exist!",
            ),
          );
        }

        final existingUserById = await _buyerAuthLocalDatasource.getUserById(
          existingBuyerByUsername.userId ?? "",
        );

        if (existingUserById == null) {
          return const Left(
            LocalDatabaseFailure(message: "User with this id does not exist!"),
          );
        }

        if (existingUserById.isVerified) {
          return const Left(
            LocalDatabaseFailure(
              message: "This account is already verified! Please login.",
            ),
          );
        }

        if (existingUserById.verifyCode == null ||
            existingUserById.verifyCodeExpiryDate == null) {
          return const Left(
            LocalDatabaseFailure(
              message: "No OTP request found! Please request for a new OTP.",
            ),
          );
        }

        final expiryDate = DateTime.parse(
          existingUserById.verifyCodeExpiryDate.toString(),
        );
        if (DateTime.now().isAfter(expiryDate)) {
          return const Left(
            LocalDatabaseFailure(
              message: "OTP has expired! Please request for a new OTP.",
            ),
          );
        }

        if (existingUserById.verifyCode != otp) {
          return const Left(
            LocalDatabaseFailure(message: "Invalid OTP! Please try again."),
          );
        }

        final updatedUser = await _buyerAuthLocalDatasource.updateBaseUser(
          existingUserById.copyWith(
            isVerified: true,
            verifyCode: null,
            verifyCodeExpiryDate: null,
          ),
        );

        if (updatedUser == null) {
          return const Left(
            LocalDatabaseFailure(message: "User is not updated and not found!"),
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
        final result = await _buyerAuthRemoteDatasource.logout();
        if (!result) {
          return const Left(ApiFailure(message: "Failed to logout buyer!"));
        }

        return Right(result);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data["message"] ?? "Failed to logout buyer!",
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
  Future<Either<Failures, BuyerEntity>> getCurrentBuyer(String buyerId) async {
    if (await _networkInfo.isConnected) {
      try {
        final buyer = await _buyerAuthRemoteDatasource.getCurrentBuyer(buyerId);
        if (buyer == null) {
          return const Left(
            ApiFailure(message: "Failed to get current buyer!"),
          );
        }

        return Right(buyer.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data["message"] ?? "Failed to get current buyer!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final buyer = await _buyerAuthLocalDatasource.getBuyerById(buyerId);
        if (buyer == null) {
          return const Left(
            LocalDatabaseFailure(message: "Failed to get current buyer!"),
          );
        }

        final user = await _buyerAuthLocalDatasource.getUserById(buyer.userId!);
        if (user == null) {
          return const Left(
            LocalDatabaseFailure(message: "Failed to get current base user!"),
          );
        }

        return Right(buyer.toEntity(userEntity: user.toEntity()));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }
}
