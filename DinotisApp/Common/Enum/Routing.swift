//
//  Routing.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/02/22.
//

import Foundation

enum PrimaryRouting {
	case userLogin(viewModel: LoginViewModel)
	case talentLogin(viewModel: LoginViewModel)
	case verificationOtp(viewModel: OtpVerificationViewModel)
	case homeUser(viewModel: UserHomeViewModel)
	case homeTalent(viewModel: TalentHomeViewModel)
	case biodataUser(viewModel: BiodataViewModel)
	case biodataTalent(viewModel: BiodataViewModel)
	case forgotPassword(viewModel: ForgotPasswordViewModel)
	case loginResetPassword(viewModel: LoginPasswordResetViewModel)
	case resetPassword(viewModel: ResetPasswordViewModel)
}

enum HomeRouting {
	case userProfile(viewModel: ProfileViewModel)
	case talentProfile(viewModel: ProfileViewModel)
	case editTalentProfile(viewModel: EditProfileViewModel)
	case editUserProfile(viewModel: EditProfileViewModel)
	case changePhone(viewModel: ChangePhoneViewModel)
	case changePhoneOtp(viewModel: ChangePhoneVerifyViewModel)
	case talentFormSchedule(viewModel: ScheculedFormViewModel)
	
	case talentScheduleDetail(viewModel: ScheduleDetailViewModel)
	case userScheduleDetail(viewModel: ScheduleDetailViewModel)
	case talentWallet(viewModel: TalentWalletViewModel)
	case talentProfileDetail(viewModel: TalentProfileDetailViewModel)
	case scheduleList(viewModel: ScheduleListViewModel)
	case historyList(viewModel: UserHistoryViewModel)
	case videoCall(viewModel: PrivateVideoCallViewModel)
	case afterCall(viewModel: AfterCallViewModel)
	case searchTalent(viewModel: SearchTalentViewModel)
	case paymentMethod(viewModel: PaymentMethodsViewModel)
	case detailPayment(viewModel: DetailPaymentViewModel)
	case bookingInvoice(viewModel: InvoicesBookingViewModel)
    case twilioLiveStream(viewModel: TwilioLiveStreamViewModel)
	case loginResetPassword(viewModel: LoginPasswordResetViewModel)
	case changePassword(viewModel: ChangesPasswordViewModel)
	case previewTalent(viewModel: PreviewTalentViewModel)
	case coinHistory(viewModel: CoinHistoryViewModel)
}
