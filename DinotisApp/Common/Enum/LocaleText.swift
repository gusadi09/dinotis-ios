//
//  LocaleText.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/02/22.
//

import Foundation

enum LocaleText {
	
	// MARK: - General
	static let attention = NSLocalizedString("attention", comment: "")
	static let okText = NSLocalizedString("ok_text", comment: "")
	static let returnText = NSLocalizedString("return", comment: "")
	static let sessionExpireText = NSLocalizedString("session_expired", comment: "")
	static let cancelText = NSLocalizedString("cancel", comment: "")
	static let successTitle = NSLocalizedString("success", comment: "")
	static let generalParticipant = NSLocalizedString(
		"participant",
		comment: "string for participant label"
	)
	static let generalSearch = NSLocalizedString("general_search", comment: "")
	static let selectCountry = NSLocalizedString("select_country", comment: "")
	static let generalClose = NSLocalizedString("general_close", comment: "")
	static let generalRegisterText = NSLocalizedString("register_text", comment: "")
	static let generalLoginText = NSLocalizedString("login_text", comment: "")
	static let generalResetPassword = NSLocalizedString("reset_password", comment: "")
	static let generalHelp = NSLocalizedString("general_help", comment: "")
	static let enterConfirmNewPass = NSLocalizedString("enter_confirm_password", comment: "")
	static let enterNewPassword = NSLocalizedString("enter_new_password", comment: "")
	static let newConfirmPasswordTitle = NSLocalizedString("confirm_new_pass", comment: "")
	static let newPasswordTitle = NSLocalizedString("new_password", comment: "")
	static let passwordNotMatch = NSLocalizedString("password_not_match", comment: "")
	static let meetingDeleted = NSLocalizedString("meeting_deleted", comment: "")
	static let walletBalance = NSLocalizedString("wallet_balance", comment: "")
	static let withdrawBalance = NSLocalizedString("withdraw_balance", comment: "")
	static let noText = NSLocalizedString("no_button", comment: "")
	static let yesDeleteText = NSLocalizedString("yes_delete_button", comment: "")
	static let errorText = NSLocalizedString("error", comment: "")
	static let resetPasswordSubtext = NSLocalizedString("reset_password_subtext", comment: "")
	static let changePasswordTitle = NSLocalizedString("change_password", comment: "")
	static let oldPasswordText = NSLocalizedString("old_password_text", comment: "")
	static let oldPasswordPlaceholder = NSLocalizedString("old_password_placheholder", comment: "")
	static let passwordChangedText = NSLocalizedString("password_changed", comment: "")
	static let repeatNewPassword = NSLocalizedString("repeat_new_password", comment: "")
	static let repeatNewPasswordPlaceholder = NSLocalizedString("repeat_new_password_alt", comment: "")
	static let changeVoucherText = NSLocalizedString("change_text", comment: "")
	static let applyText = NSLocalizedString("apply_text", comment: "")
	
	// MARK: - UserType View
	static let loginAsText = NSLocalizedString("log_in_as", comment: "")
	static let basicUserText = NSLocalizedString("basic_user", comment: "")
	static let basicUserPlaceholder = NSLocalizedString("start_chatting_with_your_idol", comment: "")
	static let talentUserText = NSLocalizedString("talent_influencer", comment: "")
	static let talentUserPlaceholder = NSLocalizedString("start_chatting_with_your_fans", comment: "")
	
	// MARK: - Login View
	static let enterPhoneLabel = NSLocalizedString("enter_phone_label", comment: "")
	static let loginAsBasicUser = NSLocalizedString("log_in_as_basic_user", comment: "")
	static let loginAsTalent = NSLocalizedString("log_in_as_talent", comment: "")
	static let passwordPlaceholder = NSLocalizedString("enter_password", comment: "")
	static let forgetPasswordText = NSLocalizedString("forgot_password", comment: "")
	static let resetPasswordLabels = NSLocalizedString("enter_reset_password_label", comment: "")
	static let registerTitle = NSLocalizedString("register_screen_title", comment: "")
	static let registerLoginFirst = NSLocalizedString("register_screen_login_first", comment: "")
	static let registerLoginSecond = NSLocalizedString("register_screen_login_second", comment: "")
	static let loginRegisterFirst = NSLocalizedString("login_screen_register_first", comment: "")
	static let loginRegisterSecond = NSLocalizedString("login_screen_register_second", comment: "")
	
	// MARK: - Verification OTP
	static let otpVerificationTitle = NSLocalizedString("OTP_verification_title", comment: "")
	static let otpSubtitle = NSLocalizedString("OTP_subtitle", comment: "")
	static let otpNotReceive = NSLocalizedString("OTP_not_receive", comment: "")
	static func remainingText(time: Int) -> String {
		return String(format: NSLocalizedString("resend_label %lld", comment: ""), time)
	}
	static let resendText = NSLocalizedString("resend", comment: "")
	
	// MARK: - Biodata View
	static let completePersonalDataText = NSLocalizedString("complete_personal_data", comment: "")
	static let nameText = NSLocalizedString("name", comment: "")
	static let nameHint = NSLocalizedString("name_hint", comment: "")
	static let usernameTitle = NSLocalizedString("your_dinotis_link", comment: "")
	static let usernameHint = NSLocalizedString("username_hint", comment: "")
	static let bioTitle = NSLocalizedString("bio", comment: "")
	static let saveText = NSLocalizedString("save", comment: "")
	static let chooseProfession = NSLocalizedString("choose_your_profession", comment: "")
	static let professionTitle = NSLocalizedString("profession", comment: "")
	static let biodataScreenLoginAnother = NSLocalizedString("biodata_screen_login_with_another", comment: "")
	static let resetPasswordSublabels = NSLocalizedString("reset_password_sublabel", comment: "")
	
	// MARK: - Profile
	static let myAccountTitle = NSLocalizedString("my_account", comment: "")
	static let copyText = NSLocalizedString("copy", comment: "")
	static let accountSettingText = NSLocalizedString("account_settings", comment: "")
	static let editProfileText = NSLocalizedString("edit_profile", comment: "")
	static let financialStatementText = NSLocalizedString("financial_statements", comment: "")
	static let helpText = NSLocalizedString("help", comment: "")
	static let exitText = NSLocalizedString("exit", comment: "")
	static let successCopyText = NSLocalizedString("success_copy", comment: "")
	static let exitTitle = NSLocalizedString("exit_title", comment: "")
	static let exitSubtitle = NSLocalizedString("exit_label", comment: "")
	static let requestScheduleText = NSLocalizedString("request_schedule_text", comment: "")
	static let tellMeText = NSLocalizedString("tell_me_text", comment: "")
	static let requestScheduleSubLabel = NSLocalizedString("request_schedule_sublabel", comment: "")
	static let requestPrivateText = NSLocalizedString("request_private", comment: "")
	static let requestLiveText = NSLocalizedString("request_live", comment: "")
	static let requestGroupText = NSLocalizedString("request_group", comment: "")
	static let previewProfileTitle = NSLocalizedString("preview_profile_title", comment: "")
	static let requestSuccessTitle = NSLocalizedString("request_success_title", comment: "")
	static let requestSuccessSubtitle = NSLocalizedString("request_success_subtitle", comment: "")
	static let orText = NSLocalizedString("or_text", comment: "")
	static let highlightNote = NSLocalizedString("highlight_note", comment: "")
	static let highlightTitle = NSLocalizedString("highlight_title", comment: "")
	static let addPasswordAlertTitle = NSLocalizedString("add_password_alert_title", comment: "")
	static let addPasswordAlertSubtitle = NSLocalizedString("add_password_subtitle", comment: "")
	
	// MARK: - Edit Profile
	static let editProfileTitle = NSLocalizedString("edit_profile", comment: "")
	static let linkUrlTitle = NSLocalizedString("link_url", comment: "")
	static let phoneText = NSLocalizedString("phone", comment: "")
	static let changeText = NSLocalizedString("change", comment: "")
	static let successUpdateAccount = NSLocalizedString("success_update_account", comment: "")
	static let photoProfile = NSLocalizedString("foto_profile", comment: "")
	static let photo = NSLocalizedString("photo", comment: "")
	
	// MARK: - Change Phone Number
	static let changePhoneNumberTitle = NSLocalizedString("change_phone", comment: "")
	static let newPhoneNumberSubtitle = NSLocalizedString("enter_new_phone_label", comment: "")
	static let sendText = NSLocalizedString("send", comment: "")
	static let talentDetailEmptySchedule = NSLocalizedString("talent_detail_empty_label", comment: "")
	
	// MARK: - Home Screen
	static let helloText = NSLocalizedString("hello,", comment: "")
	static let searchText = NSLocalizedString("find_idol_search", comment: "")
	static let videoCallSchedule = NSLocalizedString("video_call_schedule", comment: "")
	static let checkSchedule = NSLocalizedString("check_schedule", comment: "")
	static let checkScheduleSubtitle = NSLocalizedString("check_schedule_subtitle", comment: "")
	static let moreCrowded = NSLocalizedString("more_crowded", comment: "")
	static let recommendation = NSLocalizedString("recommendation", comment: "")
	static let noScheduleLabel = NSLocalizedString("no_schedule_label", comment: "")
	static let createScheduleLabel = NSLocalizedString("create_schedule_label", comment: "")
	static let createScheduleText = NSLocalizedString("create_schedule", comment: "")
	static let deleteAlertText = NSLocalizedString("delete_alert", comment: "")
	
	// MARK: - VideoCall List
	static let navigationTitleOfScheduleList = NSLocalizedString("video_call_schedule", comment: "")
	static let historyText = NSLocalizedString("view_history", comment: "")
	static let leaveMeetingTitle = NSLocalizedString("leave_meeting_title", comment: "")
	static let leaveMeetingLabel = NSLocalizedString("leave_meeting_label", comment: "")
	static let leaveMeetingSublabelUser = NSLocalizedString("leave_meeting_sublabel_user", comment: "")
	static let leaveMeetingSublabelTalent = NSLocalizedString("leave_meeting_sublabel_talent", comment: "")
	static let leaveMeetingButtonText = NSLocalizedString("leave_meeting_button_text", comment: "")
	
	// MARK: - Search View
	static let searchNavigationTitle = NSLocalizedString("search", comment: "")
	static let searchPlaceholder = NSLocalizedString("find_idol_search", comment: "")
	static let searchByCategory = NSLocalizedString("search_by_category", comment: "")
	static func moreCrowdedInCategory(
		categoryName: String,
		professionId: Int,
		professionName: String
	) -> String {
		return professionId == 0 ?
		String(format: NSLocalizedString("search_with_crowded", comment: ""), categoryName) :
		String(format: NSLocalizedString("search_with_crowded", comment: ""), professionName)
		
	}
	static func allInText(by category: String) -> String {
		String(format: NSLocalizedString("all_in", comment: ""), category)
	}
	static let allText = NSLocalizedString("all", comment: "")
	static func searchResultText() -> String {
		NSLocalizedString("search_result", comment: "")
	}
	static func searchInTitle(categoryName: String, categoryId: Int, professionId: Int, professionName: String) -> String {
		return categoryId == 0 ?
		NSLocalizedString("search", comment: "") :
		professionId == 0 ? String(format: NSLocalizedString("search_in", comment: ""), categoryName) : String(format: NSLocalizedString("search_in", comment: ""), professionName)
	}
	
	static let homeScreenVerified = NSLocalizedString(
		"home_screen_verified",
		comment: "verified string for home screen"
	)
	static let homeScreenSeeSchedule = NSLocalizedString(
		"home_screen_see_schedule",
		comment: "string for see schedule text on home screen"
	)
	static let homeScreenPrivateVideo = NSLocalizedString(
		"home_screen_private_video",
		comment: "String for private video call title on home"
	)
	static let homeScreenGroupVideo = NSLocalizedString("home_screen_group_video", comment: "")
	static let coinSingleText = NSLocalizedString("coin_text_single", comment: "")
	
	static let loginText = NSLocalizedString("log_in_text", comment: "")
	static let talentNotRegisterError = NSLocalizedString("talent_not_register", comment: "")
	static let registerBeATalent = NSLocalizedString("register_be_talent", comment: "")
	static let backToHome = NSLocalizedString("back_to_home", comment: "")
	static let invoiceText = NSLocalizedString("invoice_title", comment: "")
	static let reportText = NSLocalizedString("report_text", comment: "")
	static let reportAudienceTitle = NSLocalizedString("report_audience_title", comment: "")
	static let reportNotesPlaceholder = NSLocalizedString("report_notes_placeholder", comment: "")
	static let failedToReport = NSLocalizedString("failed_report_text", comment: "")
	static let otherText = NSLocalizedString("other_text", comment: "")
	static let serviceFeeText = NSLocalizedString("service_fee", comment: "")
	static let vaServiceFeeSubtitle = NSLocalizedString("va_service_fee_subtitle", comment: "")
	static let ewalletServiceFeeSubtitle = NSLocalizedString("ewallet_service_fee_subtitle", comment: "")
	static let selectPaymentText = NSLocalizedString("select_payment_method", comment: "")
	static let virtualAccountText = NSLocalizedString("virtual_account_transfer", comment: "")
	static let ewalletText = NSLocalizedString("ewallet_text", comment: "")
	static let qrisText = NSLocalizedString("qris_text", comment: "")
	static let paymentText = NSLocalizedString("payment", comment: "")
	static let subtotalText = NSLocalizedString("subtotal_payment", comment: "")
	static let applicationFeeText = NSLocalizedString("application_fee", comment: "")
	static let totalPaymentText = NSLocalizedString("total_payment", comment: "")
	static let useMethodText = NSLocalizedString("use_method", comment: "")
	static let payNowText = NSLocalizedString("pay_now", comment: "")
	static let howToPayTitle = NSLocalizedString("how_to_pay", comment: "")
	static let howToPayFirstText = NSLocalizedString("how_to_pay_first_section", comment: "")
	static let howToPaySecondText = NSLocalizedString("how_to_pay_second_section", comment: "")
	static let howToPayThirdText = NSLocalizedString("how_to_pay_third_section", comment: "")
	static let howToPayFourthText = NSLocalizedString("how_to_pay_fourth_section", comment: "")
	static let attentionQrisText = NSLocalizedString("attention_qris_text", comment: "")
	static let minimumPriceOfMeeting = NSLocalizedString("minimum_price_of_meeting", comment: "")
	static let liveStreamText = NSLocalizedString("live_stream_text", comment: "")
	
	static let liveScreenWaitingTitle = NSLocalizedString(
		"live_screen_waiting_title",
		comment: "String for waiting title at live screen"
	)
	static let liveScreenWaitingSubtitle = NSLocalizedString(
		"live_screen_waiting_subtitle",
		comment: "String for waiting subtitle at live screen"
	)
	static let liveScreenLeavingAlertSubtitle = NSLocalizedString(
		"live_screen_leaving_alert_subtitle",
		comment: "string for leaving alert"
	)
	static let liveScreenCloseLive = NSLocalizedString(
		"live_screen_close_live",
		comment: "string for close live"
	)
	static let liveScreenLiveChat = NSLocalizedString(
		"live_screen_live_chat",
		comment: "string for live chat title"
	)
	static let liveScreenChatboxPlaceholder = NSLocalizedString(
		"live_screen_chatbox_placeholder",
		comment: "string for chatbox placeholder"
	)
	static let liveScreenTalentLabel = NSLocalizedString(
		"live_screen_talent_label",
		comment: "string for talent label in chat bubble"
	)
	static let liveScreenMeLabel = NSLocalizedString(
		"live_screen_me_label",
		comment: "string for me label in chat bublbe"
	)
	static let liveScreenThankYouText = NSLocalizedString(
		"live_screen_thank_you",
		comment: "string for thank you text on streaming ended"
	)
	static let liveScreenClosingText = NSLocalizedString(
		"live_screen_closing_text",
		comment: "string for closing text in streaming ended modal"
	)
	static let liveScreenTalentMicOff = NSLocalizedString(
		"live_screen_talent_mic_off",
		comment: "label when streamer mic off"
	)
	static let liveScreenTalentVideoOff = NSLocalizedString(
		"live_screen_talent_video_off",
		comment: "label when streamer video off"
	)
	static let liveScreenDeviceRestrict = NSLocalizedString(
		"live_screen_device_restrict",
		comment: "String for device restrict alert"
	)
	static let successLabels = NSLocalizedString(
		"free_payment_success",
		comment: ""
	)
	static let paymentScreenPromoCodeTitle = NSLocalizedString(
		"payment_screen_promo_code_title",
		comment: ""
	)
	static let paymentScreenPromoCodePlaceholder = NSLocalizedString(
		"payment_screen_promo_code_placeholder",
		comment: ""
	)
	static let paymentScreenPromoNotFound = NSLocalizedString(
		"payment_screen_promo_not_found",
		comment: ""
	)
	static let groupCallWaitingTalent = NSLocalizedString(
		"group_call_waiting_talent",
		comment: ""
	)
	static let generalYouText = NSLocalizedString(
		"general_you_text",
		comment: ""
	)
	static let groupCallShareScreen = NSLocalizedString(
		"group_call_share_screen",
		comment: ""
	)
	static let groupCallTitle = NSLocalizedString("group_call_title" , comment: "")
	
	static let detailScheduleStepTitle = NSLocalizedString(
		"detail_schedule_step_title",
		comment: ""
	)
	static let detailScheduleStepOne = NSLocalizedString(
		"detail_schedule_step_one",
		comment: ""
	)
	static let detailScheduleStepTwo = NSLocalizedString(
		"detail_schedule_step_two",
		comment: ""
	)
	static let detailScheduleStepThree = NSLocalizedString(
		"detail_schedule_step_three",
		comment: ""
	)
	static let detailScheduleStepFour = NSLocalizedString(
		"detail_schedule_step_four",
		comment: ""
	)
	static func talentDetailManaged(code: String) -> String {
		return String(format: NSLocalizedString("talent_detail_managed_by", comment: ""), code)
	}
	static let talentDetailMyTalent = NSLocalizedString("talent_detail_my_talent", comment: "")
	static let detailScheduleMeetingRulesTitle = NSLocalizedString("detail_schedule_rules_title", comment: "")
	static let groupCallDetailInfo = NSLocalizedString("group_call_detail_info", comment: "")
	static let groupCallNoShareScreenAvail = NSLocalizedString("group_call_no_share_screen", comment: "")
	static let groupCallNoTalent = NSLocalizedString("group_call_no_talent", comment: "")
	static let groupCallQuestionBox = NSLocalizedString("group_call_question_box", comment: "")
	static let groupCallQuestionSub = NSLocalizedString("group_call_question_box_sub", comment: "")
	static let groupCallQuestionSend = NSLocalizedString("group_call_question_send", comment: "")
	static func groupCallNameRaised(name: String) -> String {
		String(format: NSLocalizedString("group_call_name_raised", comment: ""), name)
	}
	static let agora110Error = NSLocalizedString("agora_110_error", comment: "")
	static let groupCallQnaActivated = NSLocalizedString("group_call_qna_activated", comment: "")
	static let generalFilterSchedule = NSLocalizedString("general_filter_schedule", comment: "")
	static let inAppsPurchaseTrx = NSLocalizedString("in_app_purchase_error_trx", comment: "")
	static let homeScreenYourCoin = NSLocalizedString("home_your_coin", comment: "")
	static let homeScreenAddCoin = NSLocalizedString("home_add_coin", comment: "")
	static let homeScreenCoinDetail = NSLocalizedString("home_coin_detail", comment: "")
	static let homeScreenCoinSuccess = NSLocalizedString("home_success_buy_coin", comment: "")
	static let coinHistoryTitle = NSLocalizedString("coin_history_title", comment: "")
	static let coinHistoryCoinIn = NSLocalizedString("coin_history_coin_in", comment: "")
	static let coinHistoryCoinOut = NSLocalizedString("coin_history_coin_out", comment: "")
	static let coinHistoryEmptyText = NSLocalizedString("coin_history_empty_text", comment: "")
	static let coinPaymentText = NSLocalizedString("coin_payment_text", comment: "")
	static let otherPaymentText = NSLocalizedString("other_payment_method", comment: "")
	static let otherPaymentSubtitle = NSLocalizedString("other_payment_subtitle", comment: "")
	static func valueCoinLabel(_ value: String) -> String {
		String(format: NSLocalizedString("coin_value_label", comment: ""), value)
	}
	
	static func andMoreParticipant(_ value: Int) -> String {
		String(format: NSLocalizedString("and_more_participant", comment: ""), value)
	}
	
	static let discountText = NSLocalizedString("discount_text", comment: "")
	static func cashbackCoinText(_ value: String) -> String {
		String(format: NSLocalizedString("cashback_coin_text", comment: ""), value)
	}
	static func cashbackPercentageText(_ value: String) -> String {
		String(format: NSLocalizedString("cashback_percentage_text", comment: ""), value)
	}
	static func discountCoinText(_ value: String) -> String {
		String(format: NSLocalizedString("discount_coin_text", comment: ""), value)
	}
	static func discountPriceText(_ value: String) -> String {
		String(format: NSLocalizedString("discount_price_text", comment: ""), value)
	}
	static func discountPercentageText(_ value: String) -> String {
		String(format: NSLocalizedString("discount_percentage_text", comment: ""), value)
	}
	static let waitingSessionText = NSLocalizedString("waiting_session_text", comment: "")
	static let deleteAccountText = NSLocalizedString("delete_account_text", comment: "")
	static let deleteAccountModalSubtitle = NSLocalizedString("delete_account_modal_subtitle", comment: "")
	static let generalDeleteText = NSLocalizedString("delete", comment: "")
	static let deleteAccountSuccessText = NSLocalizedString("delete_account_success_text", comment: "")
	static let startInText = NSLocalizedString("start_in", comment: "")
	static let sureEndCallSubtitle = NSLocalizedString("sure_to_end_call", comment: "")
	static let callConnectionLostText = NSLocalizedString("connection_lost_call", comment: "")
	static let callRejoinedText = NSLocalizedString("connection_good_call", comment: "")
	static let fiveMinuteEndTitle = NSLocalizedString("5_min_end_title", comment: "")
	static let fiveMinuteEndSubtitle = NSLocalizedString("5_min_end_subtitle", comment: "")
	static let groupcallLabel = NSLocalizedString("group_call_label", comment: "")
	static let fiveMinEndViewerMessage = NSLocalizedString("5_min_end_viewer_subtitle", comment: "")
	static let receivedSpeakerInviteTitle = NSLocalizedString("received_speaker_invite_title", comment: "")
	static let receivedSpeakerInviteMessage = NSLocalizedString("received_speaker_invite_message", comment: "")
	static let joinNow = NSLocalizedString("join_now", comment: "")
	static let neverMind = NSLocalizedString("never_mind", comment: "")
	static let speakerMovedToViewersByHostTitle = NSLocalizedString("speaker_moved_to_viewers_by_host_title", comment: "")
	static let speakerMovedToViewersByHostMessage = NSLocalizedString("speaker_moved_to_viewers_by_host_message", comment: "")
	static let streamEndedByHostTitle = NSLocalizedString("stream_ended_by_host_title", comment: "")
	static let streamEndedByHostMessage = NSLocalizedString("stream_ended_by_host_message", comment: "")
	static let streamWillEndIfHostLeavesTitle = NSLocalizedString("stream_will_end_if_host_leaves_title", comment: "")
	static let streamWillEndIfHostLeavesMessage = NSLocalizedString("stream_will_end_if_host_leaves_message", comment: "")
	static let endEvent = NSLocalizedString("end_event", comment: "")
	static let welcome = NSLocalizedString("welcome", comment: "")
	static let viewerConnectedMessage = NSLocalizedString("viewer_connected_message", comment: "")
	static let gotIt = NSLocalizedString("got_it", comment: "")
	static let mutedLockByHostMessage = NSLocalizedString("muted_lock_by_host_message", comment: "")
	static let mutedByHostMessage = NSLocalizedString("muted_by_host_message", comment: "")
	static let unlockedMuteByHostTitle = NSLocalizedString("unlocked_mute_by_host_title", comment: "")
	static let unlockedMuteByHostMessage = NSLocalizedString("unlocked_mute_by_host_message", comment: "")
	static let allParticipantIsMuted = NSLocalizedString("all_participant_is_muted", comment: "")
	static let connectingToRoom = NSLocalizedString("connecting_to_room", comment: "")
	static let lockMute = NSLocalizedString("lock_mute", comment: "")
	static let willDisableParticipantsAudio = NSLocalizedString("will_disable_participants_audio", comment: "")
	static let muteAllParticipants = NSLocalizedString("mute_all_participants", comment: "")
	static let invitationSent = NSLocalizedString("invitation_sent", comment: "")
	static let speakerInviteMessage1 = NSLocalizedString("speaker_invite_message_1", comment: "")
	static let speakerInviteMessage2 = NSLocalizedString("speaker_invite_message_2", comment: "")
	static let inviteToSpeak = NSLocalizedString("invite_to_speak", comment: "")
	static let unanswered = NSLocalizedString("unanswered", comment: "")
	static let answered = NSLocalizedString("answered", comment: "")
	static let qna = NSLocalizedString("qna", comment: "")
	static let back = NSLocalizedString("back", comment: "")
	static let you = NSLocalizedString("you", comment: "")
	static let mutedLockByHostTitle = NSLocalizedString("muted_lockByHost_title", comment: "")
	static let mutedByHostTitle = NSLocalizedString("muted_by_host_title", comment: "")
	static let joiningLoadingEvent = NSLocalizedString("joining_loading_text", comment: "")
	static let loadingText = NSLocalizedString("loading_text", comment: "")
	static let onlyYouOnRoom = NSLocalizedString("only_you_on_room", comment: "")
	static let isPresentingText = NSLocalizedString("is_presenting", comment: "")
    static let removeAllParticipants = NSLocalizedString("remove_all_participants", comment: "")
    static let moveAllSpeakerTitle = NSLocalizedString("move_all_speaker_title", comment: "")
    static let moveAllSpeakerMessage = NSLocalizedString("move_all_speaker_message", comment: "")
    static let moveAllParticipantsLoading = NSLocalizedString("loading_remove_all_participants", comment: "")
	static let selectDeliveryOptionOTP = NSLocalizedString("select_otp_delivery_title", comment: "")
	static let continueAlt = NSLocalizedString("continue_alt", comment: "")
	static let viaWhatsapp = NSLocalizedString("via_whatsapp", comment: "")
	static let viaWhatsappCaption = NSLocalizedString("via_whatsapp_caption", comment: "")
	static let viaSms = NSLocalizedString("via_sms", comment: "")
	static let viaSmsCaption = NSLocalizedString("via_sms_caption", comment: "")
	static let waitingOtherToJoin = NSLocalizedString("waiting_other_to_join_event", comment: "")
	static let settingText = NSLocalizedString("setting_text", comment: "")
	static let muteAllParticipantText = NSLocalizedString("mute_all_participant", comment: "")
	static let muteLockText = NSLocalizedString("lock_mute_title", comment: "")
	static let muteLockSubtitle = NSLocalizedString("lock_mute_subtitle", comment: "")
    static let mute = NSLocalizedString("mute", comment: "")
    static let remove = NSLocalizedString("remove", comment: "")
    static let removeSpotlight = NSLocalizedString("remove_spotlight", comment: "")
    static let spotlightMe = NSLocalizedString("spotlight_me", comment: "")
    static let spotlightSpeaker = NSLocalizedString("spotlight_speaker", comment: "")
    static let moveToViewers = NSLocalizedString("move_to_viewers", comment: "")
}
