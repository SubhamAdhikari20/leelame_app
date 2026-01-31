// lib/features/buyer/presentation/view_models/buyer_view_model.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/features/buyer/domain/usecases/buyer_get_current_user_usecase.dart';
import 'package:leelame/features/buyer/domain/usecases/update_buyer_profile_details_usecase.dart';
import 'package:leelame/features/buyer/domain/usecases/upload_buyer_profile_picture_usecase.dart';
import 'package:leelame/features/buyer/presentation/states/buyer_state.dart';

final buyerViewModelProvider = NotifierProvider<BuyerViewModel, BuyerState>(() {
  return BuyerViewModel();
});

class BuyerViewModel extends Notifier<BuyerState> {
  late final BuyerGetCurrentUserUsecase _buyerGetCurrentUserUsecase;
  late final UpdateBuyerProfileDetailsUsecase _updateBuyerProfileDetailsUsecase;
  late final UploadBuyerProfilePictureUsecase _uploadBuyerProfilePictureUsecase;

  @override
  BuyerState build() {
    _buyerGetCurrentUserUsecase = ref.read(buyerGetCurrentUserUsecaseProvider);
    _updateBuyerProfileDetailsUsecase = ref.read(
      updateBuyerProfileDetailsUsecaseProvider,
    );
    _uploadBuyerProfilePictureUsecase = ref.read(
      uploadBuyerProfilePictureUsecaseProvider,
    );
    return BuyerState();
  }

  Future<void> getCurrentUser({required String buyerId}) async {
    state = state.copyWith(buyerStatus: BuyerStatus.loading);

    final result = await _buyerGetCurrentUserUsecase(
      BuyerGetCurrentUserUsecaseParams(buyerId: buyerId),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          buyerStatus: BuyerStatus.error,
          errorMessage: failure.message,
        );
      },
      (buyer) {
        state = state.copyWith(buyerStatus: BuyerStatus.loaded, buyer: buyer);
      },
    );
  }

  Future<void> updateBuyer({
    required String buyerId,
    String? fullName,
    String? email,
    String? username,
    String? phoneNumber,
    String? bio,
  }) async {
    state = state.copyWith(buyerStatus: BuyerStatus.loading);

    // Wait for few seconds
    await Future.delayed(Duration(seconds: 2));

    final result = await _updateBuyerProfileDetailsUsecase(
      UpdateBuyerProfileDetailsUsecaseParams(
        buyerId: buyerId,
        fullName: fullName,
        username: username,
        phoneNumber: phoneNumber,
        bio: bio,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        buyerStatus: BuyerStatus.error,
        errorMessage: failure.message,
      ),
      (buyer) {
        state = state.copyWith(buyerStatus: BuyerStatus.updated);
        getCurrentUser(buyerId: buyer.buyerId!);
      },
    );
  }

  Future<void> uploadProfilePicture({
    required String buyerId,
    required File profilePicture,
  }) async {
    state = state.copyWith(buyerStatus: BuyerStatus.loading);

    // Wait for few seconds
    await Future.delayed(Duration(seconds: 2));

    final result = await _uploadBuyerProfilePictureUsecase(
      UploadBuyerProfilePictureUsecaseParams(
        buyerId: buyerId,
        profilePicture: profilePicture,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          buyerStatus: BuyerStatus.error,
          errorMessage: failure.message,
        );
      },
      (profilePictureUrl) {
        state = state.copyWith(
          buyerStatus: BuyerStatus.imageLoaded,
          uploadedProfilePictureUrl: profilePictureUrl,
        );
      },
    );
  }
}
