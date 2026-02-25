// lib/features/seller/presentation/view_models/seller_view_model.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/features/seller/domain/usecases/get_current_seller_usecase.dart';
import 'package:leelame/features/seller/domain/usecases/get_all_sellers_usecase.dart';
import 'package:leelame/features/seller/domain/usecases/update_seller_profile_details_usecase.dart';
import 'package:leelame/features/seller/domain/usecases/upload_seller_profile_picture_usecase.dart';
import 'package:leelame/features/seller/presentation/states/seller_state.dart';

final sellerViewModelProvider = NotifierProvider<SellerViewModel, SellerState>(
  () {
    return SellerViewModel();
  },
);

class SellerViewModel extends Notifier<SellerState> {
  late final GetCurrentSellerUsecase _getCurrentSellerUsecase;
  late final UpdateSellerProfileDetailsUsecase
  _updateSellerProfileDetailsUsecase;
  late final UploadSellerProfilePictureUsecase
  _uploadSellerProfilePictureUsecase;
  late final GetAllSellersUsecase _getAllSellersUsecase;

  @override
  SellerState build() {
    _getCurrentSellerUsecase = ref.read(getCurrentSellerUsecaseProvider);
    _updateSellerProfileDetailsUsecase = ref.read(
      updateSellerProfileDetailsUsecaseProvider,
    );
    _uploadSellerProfilePictureUsecase = ref.read(
      uploadSellerProfilePictureUsecaseProvider,
    );
    _getAllSellersUsecase = ref.read(getAllSellersUsecaseProvider);
    return SellerState();
  }

  Future<void> getCurrentUser({required String sellerId}) async {
    state = state.copyWith(sellerStatus: SellerStatus.loading);

    final result = await _getCurrentSellerUsecase(
      GetCurrentSellerUsecaseParams(sellerId: sellerId),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          sellerStatus: SellerStatus.error,
          errorMessage: failure.message,
        );
      },
      (seller) {
        state = state.copyWith(
          sellerStatus: SellerStatus.loaded,
          seller: seller,
        );
      },
    );
  }

  Future<void> updateSeller({
    required String sellerId,
    String? fullName,
    String? email,
    String? username,
    String? phoneNumber,
    String? bio,
  }) async {
    state = state.copyWith(sellerStatus: SellerStatus.loading);

    // Wait for few seconds
    await Future.delayed(Duration(seconds: 2));

    final result = await _updateSellerProfileDetailsUsecase(
      UpdateSellerProfileDetailsUsecaseParams(
        sellerId: sellerId,
        fullName: fullName,
        username: username,
        phoneNumber: phoneNumber,
        bio: bio,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        sellerStatus: SellerStatus.error,
        errorMessage: failure.message,
      ),
      (seller) {
        state = state.copyWith(sellerStatus: SellerStatus.updated);
        getCurrentUser(sellerId: seller.sellerId!);
      },
    );
  }

  Future<void> uploadProfilePicture({
    required String sellerId,
    required File profilePicture,
  }) async {
    state = state.copyWith(sellerStatus: SellerStatus.loading);

    // Wait for few seconds
    await Future.delayed(Duration(seconds: 2));

    final result = await _uploadSellerProfilePictureUsecase(
      UploadSellerProfilePictureUsecaseParams(
        sellerId: sellerId,
        profilePicture: profilePicture,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          sellerStatus: SellerStatus.error,
          errorMessage: failure.message,
        );
      },
      (profilePictureUrl) {
        state = state.copyWith(
          sellerStatus: SellerStatus.imageLoaded,
          uploadedProfilePictureUrl: profilePictureUrl,
        );
      },
    );
  }

  Future<void> getAllSellers() async {
    state = state.copyWith(sellerStatus: SellerStatus.loading);
    final result = await _getAllSellersUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        sellerStatus: SellerStatus.error,
        errorMessage: failure.message,
      ),
      (sellers) => state = state.copyWith(
        sellerStatus: SellerStatus.loaded,
        sellers: sellers,
      ),
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearSellerList() {
    state = state.copyWith(sellers: []);
  }

  void clearSellerStatus() {
    state = state.copyWith(sellerStatus: SellerStatus.initial);
  }
}
