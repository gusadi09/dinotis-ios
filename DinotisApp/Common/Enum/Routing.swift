//
//  Routing.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/02/22.
//

import Foundation

enum PrimaryRouting {
    case onboarding
	case userType
    case outdatedVersion
	case userLogin(viewModel: LoginViewModel)
	case talentLogin(viewModel: LoginViewModel)
	case verificationOtp(viewModel: OtpVerificationViewModel)
	case tabContainer(viewModel: TabViewContainerViewModel)
	case homeUser(viewModel: UserHomeViewModel)
	case homeTalent(viewModel: TalentHomeViewModel)
	case biodataUser(viewModel: BiodataViewModel)
	case biodataTalent(viewModel: BiodataViewModel)
	case forgotPassword(viewModel: ForgotPasswordViewModel)
	case resetPassword(viewModel: ResetPasswordViewModel)
}

enum HomeRouting {
	case userProfile(viewModel: ProfileViewModel)
	case talentProfile(viewModel: ProfileViewModel)
	case editTalentProfile(viewModel: EditProfileViewModel)
	case editUserProfile(viewModel: EditProfileViewModel)
	case changePhone(viewModel: ChangePhoneViewModel)
	case changePhoneOtp(viewModel: ChangePhoneVerifyViewModel)
	case talentFormSchedule(viewModel: ScheduledFormViewModel)
	
	case talentScheduleDetail(viewModel: ScheduleDetailViewModel)
	case userScheduleDetail(viewModel: ScheduleDetailViewModel)
	case talentWallet(viewModel: TalentWalletViewModel)
	case talentProfileDetail(viewModel: TalentProfileDetailViewModel)
	case scheduleList(viewModel: ScheduleListViewModel)
	case videoCall(viewModel: PrivateVideoCallViewModel)
	case afterCall(viewModel: AfterCallViewModel)
	case searchTalent(viewModel: SearchTalentViewModel)
	case paymentMethod(viewModel: PaymentMethodsViewModel)
	case detailPayment(viewModel: DetailPaymentViewModel)
	case bookingInvoice(viewModel: InvoicesBookingViewModel)
	case changePassword(viewModel: ChangesPasswordViewModel)
	case previewTalent(viewModel: PreviewTalentViewModel)
	case coinHistory(viewModel: CoinHistoryViewModel)
    case bundlingMenu(viewModel: BundlingViewModel)
    case createBundling(viewModel: TalentCreateBundlingViewModel)
    case bundlingDetail(viewModel: BundlingDetailViewModel)
    case bundlingForm(viewModel: BundlingFormViewModel)
    case talentRateCardList(viewModel: TalentCardListViewModel)
    case rateCardServiceBookingForm(viewModel: RateCardServiceBookingFormViewModel)
    case talentCreateRateCardForm(viewModel: CreateTalentRateCardFormViewModel)
    case scheduleNegotiationChat(viewModel: ScheduleNegotiationChatViewModel)
	case editScheduleMeeting(viewModel: EditTalentMeetingViewModel)
	case addBankAccount(viewModel: TalentAddBankAccountViewModel)
	case withdrawTransactionDetail(viewModel: TalentTransactionDetailViewModel)
	case revenueTransactionDetail(viewModel: TalentTransactionDetailViewModel)
	case withdrawBalance(viewModel: TalentWithdrawalViewModel)
    case editRateCardSchedule(viewModel: TalentEditRateCardScheduleViewModel)
	case notification(viewModel: NotificationViewModel)
	case followedCreator(viewModel: FollowedCreatorViewModel)
    case dyteGroupVideoCall(viewModel: GroupVideoCallViewModel)
    case feedbackAfterCall(viewModel: FeedbackViewModel)
    case inbox(viewModel: InboxViewModel)
    case discussionList(viewModel: DiscussionListViewModel)
    case reviewList(viewModel: ReviewListViewModel)
    case creatorAvailability(viewModel: CreatorAvailabilityViewModel)
    case setUpVideo(viewModel: SetUpVideoViewModel)
    case sessionRecordingList(viewModel: SessionRecordingListViewModel)
    case creatorStudio(viewModel: CreatorStudioViewModel)
    case detailVideo(viewModel: DetailVideoViewModel)
    case creatorAnalytics
    case creatorRoom(viewModel: CreatorRoomViewModel)
}
