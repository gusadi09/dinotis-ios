//
//  LocalizationText.swift
//  
//
//  Created by Gus Adi on 06/12/22.
//

import SwiftUI

public enum LocalizableText {
	public static let firstOnboardingTitle = NSLocalizedString(
		"title_boarding_first",
		bundle: .module,
		comment: "This string usage for first content boarding title"
	)
	public static let descriptionFirstOnboardingContent = NSLocalizedString(
		"description_boarding_first",
		bundle: .module,
		comment: "This string usage for first boarding content desription"
	)
	public static let secondOnboardingTitle = NSLocalizedString(
		"title_boarding_second",
		bundle: .module,
		comment: "This string usage for second content boarding title"
	)
	public static let descriptionSecondOnboardingContent = NSLocalizedString(
		"description_boarding_second",
		bundle: .module,
		comment: "This string usage for second boarding content desription"
	)
	public static let titleRoleType = NSLocalizedString(
		"title_role_type",
		bundle: .module,
		comment: "This string usage for title on role selection"
	)
	public static let descriptionRoleType = NSLocalizedString(
		"description_role_type",
		bundle: .module,
		comment: "This string usage for description on role selection"
	)
    public static let generalSuccess = NSLocalizedString(
        "general_success",
        bundle: .module,
        comment: "success"
    )

	public static let skipLabel = NSLocalizedString(
		"label_skip",
		bundle: .module,
		comment: "This string usage for skip label"
	)
	public static let continueLabel = NSLocalizedString(
		"label_continue",
		bundle: .module,
		comment: "This string usage for continue label"
	)
	public static let previousLabel = NSLocalizedString(
		"label_previous",
		bundle: .module,
		comment: "This string usage for previous label"
	)

	public static let audienceTitle = NSLocalizedString(
		"title_audience",
		bundle: .module,
		comment: "This string usage for audience title label"
	)
	public static let descriptionAudienceLogin = NSLocalizedString(
		"description_audience_login",
		bundle: .module,
		comment: "This string usage for audience description login label"
	)

	public static let creatorTitle = NSLocalizedString(
		"title_creator",
		bundle: .module,
		comment: "This string usage for creator title label"
	)
	public static let descriptionCreatorLogin = NSLocalizedString(
		"description_creator_login",
		bundle: .module,
		comment: "This string usage for creator description login label"
	)

	public static let loginTitle = NSLocalizedString(
		"title_login",
		bundle: .module,
		comment: "this string usage for login title"
	)
	public static let loginDescription = NSLocalizedString(
		"description_login",
		bundle: .module,
		comment: "usage for description on login screen"
	)
	public static let phoneHint = NSLocalizedString(
		"hint_phone",
		bundle: .module,
		comment: "this string usage for placeholder text of the phone field"
	)
	public static let alertPhoneUnregister = NSLocalizedString(
		"alert_phone_unregister",
		bundle: .module,
		comment: "usage for alert when phone unregistered"
	)
	public static let alertPhoneWrong = NSLocalizedString(
		"alert_phone_wrong",
		bundle: .module,
		comment: "usage for alert when wrong phone number"
	)
    public static let alertPhoneAlreadyRegistered = NSLocalizedString(
        "alert_phone_already_register",
        bundle: .module,
        comment: "already registered error"
    )
	public static let passwordHint = NSLocalizedString(
		"hint_password",
		bundle: .module,
		comment: "usage for password placeholder"
	)
	public static let alertPasswordWrong = NSLocalizedString(
		"alert_password_wrong",
		bundle: .module,
		comment: "usage for alewart when wrong password entered"
	)
	public static let linkForgot = NSLocalizedString(
		"link_forgot",
		bundle: .module,
		comment: "usage for forgot password link button"
	)
	public static let labelLoginTermsHighlighted = NSLocalizedString(
		"label_login_terms_higlighted",
		bundle: .module,
		comment: "usage for combine with terms part this part specially for highlighted"
	)
	public static let labelLoginTermsFirstPart = NSLocalizedString(
		"label_login_terms_first_part",
		bundle: .module,
		comment: "usage for terms login text and combine with other part"
	)
	public static let labelLoginTermsSecondPart = NSLocalizedString(
		"label_login_terms_second_part",
		bundle: .module,
		comment: "usage for terms login text and combine with other part"
	)
	public static let linkRegisterHere = NSLocalizedString(
		"link_register_here",
		bundle: .module,
		comment: "usage for register button and combine with highlited part"
	)
	public static let linkRegisterHereHighlighted = NSLocalizedString(
		"link_register_here_highlighted",
		bundle: .module,
		comment: "usage for highlighted part of register here text"
	)
	public static let loginLabel = NSLocalizedString(
		"label_login",
		bundle: .module,
		comment: "usage for login label text"
	)

	public static let titleRegisterAudience = NSLocalizedString(
		"title_register_audience",
		bundle: .module,
		comment: "usage for text on register audience title text"
	)
	public static let descriptionRegister = NSLocalizedString(
		"description_register",
		bundle: .module,
		comment: "usage for description on register audience screen"
	)
	public static let labelRegisterTermsHighlighted = NSLocalizedString(
		"label_register_terms_highlighted",
		bundle: .module,
		comment: "usage for register terms and this will combine"
	)
	public static let labelRegisterTermsFirstPart = NSLocalizedString(
		"label_register_terms_first_part",
		bundle: .module,
		comment: "usage for register terms and this will combine"
	)
	public static let labelRegisterTermsSecondPart = NSLocalizedString(
		"label_register_terms_second_part",
		bundle: .module,
		comment: "usage for register terms and this will combine"
	)
	public static let linkLoginHere = NSLocalizedString(
		"link_login_here",
		bundle: .module,
		comment: "usage for login linked button"
	)
	public static let linkLoginHereHighlighted = NSLocalizedString(
		"link_login_here_highlighted",
		bundle: .module,
		comment: "usage for login linked button and highlighted"
	)
	public static let labelSendOTP = NSLocalizedString(
		"label_send_otp",
		bundle: .module,
		comment: "usage for send otp label"
	)

	public static let titleRegisterCreator = NSLocalizedString(
		"title_register_creator",
		bundle: .module,
		comment: "usage for creator register title"
	)
	public static let descriptionRegisterCreator = NSLocalizedString(
		"description_register_creator",
		bundle: .module,
		comment: "usage for description when creator registering"
	)
	public static let hintInvitationCode = NSLocalizedString(
		"hint_invitation_code",
		bundle: .module,
		comment: "usage for invitation code placeholder"
	)
	public static let alertInvitationCodeInvalid = NSLocalizedString(
		"alert_invitation_code_invalid",
		bundle: .module,
		comment: "usage for alert when invitation code invalid"
	)
	public static let linkRequestInvitation = NSLocalizedString(
		"link_request_invitation_code",
		bundle: .module,
		comment: "usage for linked request invitation"
	)
	public static let labelJoinNow = NSLocalizedString(
		"label_join_now",
		bundle: .module,
		comment: "usage for join now label"
	)

	public static let titleCountryPicker = NSLocalizedString(
		"title_country_picker",
		bundle: .module,
		comment: "usage for title on country picker"
	)
	public static let hintCountryPicker = NSLocalizedString(
		"hint_country_picker",
		bundle: .module,
		comment: "usage for placeholder on country picker"
	)
	public static let linkCountryPicker = NSLocalizedString(
		"link_country_picker",
		bundle: .module,
		comment: "usage for country picker reset default underlined button"
	)

	public static let titleOTPSendWA = NSLocalizedString(
		"title_otp_send_wa",
		bundle: .module,
		comment: "usage for otp send to wa button"
	)
	public static let descriptionOTPSendWA = NSLocalizedString(
		"description_otp_send_wa",
		bundle: .module,
		comment: "usage for description of send OTP to WA"
	)
	public static let titleOTPSendSMS = NSLocalizedString(
		"title_otp_send_sms",
		bundle: .module,
		comment: "usage for otp send to sms button"
	)
	public static let descriptionOTPSendSMS = NSLocalizedString(
		"description_otp_send_sms",
		bundle: .module,
		comment: "usage for description of send OTP to SMS"
	)

	public static let hintSendOTP = NSLocalizedString(
		"hint_send_otp",
		bundle: .module,
		comment: "usage for placeholder on send otp"
	)
	public static let alertSendOTPInvalid = NSLocalizedString(
		"alert_send_otp_invalid",
		bundle: .module,
		comment: "usage for alert of otp when invalid"
	)
    
    public static let hintResendOTP = NSLocalizedString(
        "hint_resend_otp",
        bundle: .module,
        comment: "usage for combine with link resend OTP"
    )
    
	public static func linkResendOTP(with value: Int) -> String {
		String(
			format: NSLocalizedString(
				"link_resend_otp",
				bundle: .module,
				comment: "usage for resend otp with second left"
			),
			value
		)
	}
    
    public static let linkResendOTPActive = NSLocalizedString(
        "link_resend_otp_active",
        bundle: .module,
        comment: "usage for resend otp when counter has done"
    )

	public static let titleFormRegister = NSLocalizedString(
		"title_form_register",
		bundle: .module,
		comment: "usage for title on register form"
	)
	public static let labelFormName = NSLocalizedString(
		"label_form_name",
		bundle: .module,
		comment: "usage for form name label"
	)
	public static let hintFormName = NSLocalizedString(
		"hint_form_name",
		bundle: .module,
		comment: "usage for placeholder for name on form"
	)
	public static let alerFormNameCharacterInvalid = NSLocalizedString(
		"alert_form_name_character_invalid",
		bundle: .module,
		comment: "usage for when name is invalid character"
	)
	public static let alertFormNameCharacterMinimum = NSLocalizedString(
		"alert_form_name_character_minimum",
		bundle: .module,
		comment: "usage for alert when character not in minimum value"
	)
	public static let labelFormPassword = NSLocalizedString(
		"label_form_password",
		bundle: .module,
		comment: "usage for password label"
	)
	public static let hintFormPassword = NSLocalizedString(
		"hint_form_password",
		bundle: .module,
		comment: "usage for password placeholder"
	)
	public static let labelFormRepassword = NSLocalizedString(
		"label_form_repassword",
		bundle: .module,
		comment: "usage for password label"
	)
	public static let hintFormRepassword = NSLocalizedString(
		"hint_form_repassword",
		bundle: .module,
		comment: "usage for password placeholder"
	)
	public static let alertFormRepasswordNotMatch = NSLocalizedString(
		"alert_form_repassword_not_match",
		bundle: .module,
		comment: "usage for repassword not match alert error"
	)
	public static let labelFormUsername = NSLocalizedString(
		"label_form_username",
		bundle: .module,
		comment: "usage for label on username form"
	)
	public static let hintFormUsername = NSLocalizedString(
		"hint_form_username",
		bundle: .module,
		comment: "usage for username placeholder"
	)
	public static let alertFormUsernameTaken = NSLocalizedString(
		"alert_form_username_taken",
		bundle: .module,
		comment: "usage for alert on form if username has been taken"
	)
	public static let labelFormBio = NSLocalizedString(
		"label_form_bio",
		bundle: .module,
		comment: "usage for label on bio form"
	)
	public static let hintFormBio = NSLocalizedString(
		"hint_form_bio",
		bundle: .module,
		comment: "usage for bio placeholder"
	)
	public static let labelFormProfession = NSLocalizedString(
		"label_form_profession",
		bundle: .module,
		comment: "usage for label on profession form"
	)
	public static let hintFormProfession = NSLocalizedString(
		"hint_form_profession",
		bundle: .module,
		comment: "usage for placeholder of profession form"
	)
	public static let saveLabel = NSLocalizedString(
		"label_save",
		bundle: .module,
		comment: "usage for save text"
	)

	public static let titleFormRegisterDialogSuccess = NSLocalizedString(
		"title_form_register_dialog_success",
		bundle: .module,
		comment: "usage for title if success register"
	)
	public static let descriptionFormRegisterDialogSuccess = NSLocalizedString(
		"description_form_register_dialog_success",
		bundle: .module,
		comment: "usage for description on register form dialog success"
	)
	public static let closeLabel = NSLocalizedString(
		"label_close",
		bundle: .module,
		comment: "usage for close label"
	)

	public static let titleForgotPassword = NSLocalizedString(
		"title_forgot_password",
		bundle: .module,
		comment: "usage for forgot password text"
	)
	public static let descriptionForgotPassword = NSLocalizedString(
		"description_forgot_password",
		bundle: .module,
		comment: "usage for forgot password description"
	)
	public static let titleChangePassword = NSLocalizedString(
		"title_change_password",
		bundle: .module,
		comment: "usage for change password title"
	)
	public static let descriptionChangePassword = NSLocalizedString(
		"description_change_password",
		bundle: .module,
		comment: "usage for description of change password"
	)
	public static let hintNewPassword = NSLocalizedString(
		"hint_new_password",
		bundle: .module,
		comment: "usage for placeholder on new password"
	)
	public static let hintNewRepassword = NSLocalizedString(
		"hint_new_repassword",
		bundle: .module,
		comment: "usage for new repassword placeholder"
	)
	public static let alertNewRepasswordNotMatch = NSLocalizedString(
		"alert_new_repassword_not_match",
		bundle: .module,
		comment: "usage for alert of password not match"
	)

	public static let titleChangePasswordDialogSuccess = NSLocalizedString(
		"title_change_password_dialog_success",
		bundle: .module,
		comment: "usage for change password success alert"
	)
	public static let descriptionChangePasswordDialogSuccess = NSLocalizedString(
		"description_change_password_dialog_success",
		bundle: .module,
		comment: "usage for change password dialog success"
	)

	public static let yourCoinLabel = NSLocalizedString(
		"label_your_coin",
		bundle: .module,
		comment: "usage for your coin label"
	)
	public static let addCoinLabel = NSLocalizedString(
		"label_add_coin",
		bundle: .module,
		comment: "usage for add coin label"
	)

	public static let tabProfile = NSLocalizedString(
		"tab_profile",
		bundle: .module,
		comment: "usage for profile tab title"
	)
	public static let setupAccountDescription = NSLocalizedString(
		"description_setup_account",
		bundle: .module,
		comment: "usage for setup account description"
	)
	public static let editProfileLabel = NSLocalizedString(
		"label_edit_profile",
		bundle: .module,
		comment: "usage for edit profile label"
	)
	public static let followedCreatorLabel = NSLocalizedString(
		"label_followed_creator",
		bundle: .module,
		comment: "usage for followed creator label"
	)
	public static let changePasswordLabel = NSLocalizedString(
		"label_change_password",
		bundle: .module,
		comment: "usage for change password label"
	)
	public static let helpLabel = NSLocalizedString(
		"label_help",
		bundle: .module,
		comment: "usage for help label"
	)
	public static let logoutLabel = NSLocalizedString(
		"label_logout",
		bundle: .module,
		comment: "usage for logout label"
	)

	public static let titleFollowedCreator = NSLocalizedString(
		"title_followed_creator",
		bundle: .module,
		comment: "usage for followed creator title"
	)

	public static let editProfileTitle = NSLocalizedString(
		"title_edit_profile",
		bundle: .module,
		comment: "usage for edit profile title"
	)
	public static let formPhoneLabel = NSLocalizedString(
		"label_form_phone",
		bundle: .module,
		comment: "usage for phone form label"
	)
	public static let changeLabel = NSLocalizedString(
		"label_change",
		bundle: .module,
		comment: "usage for change label"
	)
	public static let changeNowLabel = NSLocalizedString(
		"label_change_now",
		bundle: .module,
		comment: "usage for change now label"
	)

	public static let changeOldPasswordTitle = NSLocalizedString(
		"title_change_old_password",
		bundle: .module,
		comment: "usage for title of change old password"
	)
	public static let linkForgotOldPassword = NSLocalizedString(
		"link_forgot_old_password",
		bundle: .module,
		comment: "usage for forgot old password linked button"
	)
	public static let formOldPasswordLabel = NSLocalizedString(
		"label_form_old_password",
		bundle: .module,
		comment: "usage for old password label on form"
	)
	public static let hintFormOldPassword = NSLocalizedString(
		"hint_form_old_password",
		bundle: .module,
		comment: "usage for old password placeholder"
	)
	public static let alertFormOldPasswordCharacterMinimum = NSLocalizedString(
		"alert_form_old_password_character_minimum",
		bundle: .module,
		comment: "usage for old password character minimum error"
	)
	public static let formNewPasswordLabel = NSLocalizedString(
		"label_form_new_password",
		bundle: .module,
		comment: "usage for new password label on form"
	)
	public static let hintFormNewPassword = NSLocalizedString(
		"hint_form_new_password",
		bundle: .module,
		comment: "usage for new password placeholder"
	)
	public static let alertFormNewPasswordCharacterMinimum = NSLocalizedString(
		"alert_form_new_password_character_minimum",
		bundle: .module,
		comment: "usage for alert of new password violation"
	)
	public static let formNewRepasswordLabel = NSLocalizedString(
		"label_form_new_repassword",
		bundle: .module,
		comment: "usage for new repassword label"
	)
	public static let hintFormNewRepassword = NSLocalizedString(
		"hint_form_new_repassword",
		bundle: .module,
		comment: "usage for repassword placeholder"
	)
	public static let alertFormNewRepasswordCharacterMinimum = NSLocalizedString(
		"alert_form_new_repassword_character_minimum",
		bundle: .module,
		comment: "usage for repassword minimum violation"
	)

	public static let changePhoneTitle = NSLocalizedString(
		"title_change_phone",
		bundle: .module,
		comment: "usage for change phone title text"
	)
	public static let descriptionChangePhone = NSLocalizedString(
		"description_change_phone",
		bundle: .module,
		comment: "usage for change phone description text"
	)

	public static let paymentSuccessTitle = NSLocalizedString(
		"title_payment_success",
		bundle: .module,
		comment: "usage for payment success title"
	)
	public static let invoiceLabel = NSLocalizedString(
		"label_invoice",
		bundle: .module,
		comment: "usage for invoice label"
	)
	public static let orderNameLabel = NSLocalizedString(
		"label_order_name",
		bundle: .module,
		comment: "usage for order name label"
	)
	public static let paymentMethodLabel = NSLocalizedString(
		"label_payment_method",
		bundle: .module,
		comment: "usage for payment method label"
	)
	public static let totalPaymentLabel = NSLocalizedString(
		"label_payment_total",
		bundle: .module,
		comment: "usage for payment total label"
	)
	public static let doneLabel = NSLocalizedString(
		"label_done",
		bundle: .module,
		comment: "usage for done label on the view or button"
	)

	public static let historyCoinTitle = NSLocalizedString(
		"title_history_coin",
		bundle: .module,
		comment: "usage for history coin title"
	)
	public static let noCoinHistoryTitle = NSLocalizedString(
		"title_no_history_coin",
		bundle: .module,
		comment: "usage for no coin history title"
	)
	public static let tabAllText = NSLocalizedString(
		"tab_all",
		bundle: .module,
		comment: "usage for all tab text"
	)
	public static let tabCoinIncome = NSLocalizedString(
		"tab_coin_income",
		bundle: .module,
		comment: "usage for income coin tab title"
	)
	public static let tabCoinOutcome = NSLocalizedString(
		"tab_coin_outcome",
		bundle: .module,
		comment: "usage for outcome coin tab title"
	)
	public static let okText = NSLocalizedString(
		"ok_text",
		bundle: .module,
		comment: "for general usage of ok label"
	)
	public static let returnText = NSLocalizedString(
		"return_text",
		bundle: .module,
		comment: "for general usage of return label"
	)
	public static let attentionText = NSLocalizedString(
		"attention_text",
		bundle: .module,
		comment: "for general usage of attention label"
	)
	public static let notificationTitle = NSLocalizedString(
		"notification_title",
		bundle: .module,
		comment: "usage for title on notification header bar"
	)
	public static let notificationGeneralTabText = NSLocalizedString(
		"notification_general_tab_text",
		bundle: .module,
		comment: "usage for general text on notification tab"
	)
	public static let notificationTransactionTabText = NSLocalizedString(
		"notification_transaction_tab_text",
		bundle: .module,
		comment: "usage for transaction text on notification tab"
	)
	public static let notificationEmptyTitle = NSLocalizedString(
		"notification_empty_title",
		bundle: .module,
		comment: "usage for title if notification list is empty"
	)
	public static let notificationTransactionEmptyTitle = NSLocalizedString(
		"notification_transaction_empty_title",
		bundle: .module,
		comment: "usage for title if transaction notification is empty"
	)
	public static let notificationEmptyDescription = NSLocalizedString(
		"notification_empty_description",
		bundle: .module,
		comment: "usage for description if notification is empty"
	)
	public static let notificationTransactionEmptyDescription = NSLocalizedString(
		"notification_transaction_empty_description",
		bundle: .module,
		comment: "usage for description if transaction notification is empty"
	)
    public static let notificationReadAll = NSLocalizedString(
        "notification_read_all",
        bundle: .module,
        comment: "used for read all label on button"
    )
    public static let stepPaymentDone = NSLocalizedString(
        "step_payment_done",
        bundle: .module,
        comment: "usage for step in session detail when payment is done"
    )
    public static let stepWaitingForSession = NSLocalizedString(
        "step_waiting_for_session",
        bundle: .module,
        comment: "usage for step in session detail when waiting for session"
    )
    public static let stepSessionStart = NSLocalizedString(
        "step_session_start",
        bundle: .module,
        comment: "usage for step in session detail when session start"
    )
    public static let stepSessionDone = NSLocalizedString(
        "step_session_done",
        bundle: .module,
        comment: "usage for step in session detail when session is done"
    )
    public static let videoCallRulesLabel = NSLocalizedString(
        "video_call_rules",
        bundle: .module,
        comment: "usage for video call rules label"
    )
    public static let participant = NSLocalizedString(
        "participant",
        bundle: .module,
        comment: "usage for participant label"
    )
    public static let groupSessionLabelWithEmoji = NSLocalizedString(
        "group_session_label_with_emoji",
        bundle: .module,
        comment: "usage for group session label in schedule card"
    )
    public static let privateSessionLabelWithEmoji = NSLocalizedString(
        "private_session_label_with_emoji",
        bundle: .module,
        comment: "usage for private session label in schedule card"
    )
    public static let groupSessionParticipantTitle = NSLocalizedString(
        "group_session_participant_title",
        bundle: .module,
        comment: "usage for group session participant title in schedule card"
    )
    public static let privateSessionParticipantTitle = NSLocalizedString(
        "private_session_participant_title",
        bundle: .module,
        comment: "usage for private session participant title in schedule card"
    )
    public static let needHelpQuestion = NSLocalizedString(
        "need_help_question",
        bundle: .module,
        comment: "usage for help button in schedule card"
    )
    public static let contactUsLabel = NSLocalizedString(
        "contact_us_label",
        bundle: .module,
        comment: "usage for help button in schedule card"
    )
    public static let startNowLabel = NSLocalizedString(
        "start_now_label",
        bundle: .module,
        comment: "usage for start now button in schedule details"
    )
    public static let meLabel = NSLocalizedString(
        "me_label",
        bundle: .module,
        comment: "usage for user label in schedule card"
    )
    public static func andMoreParticipant(_ value: Int) -> String {
        String(format: NSLocalizedString(
            "and_more_participant",
            bundle: .module,
            comment: "usage to tell how many participants join the session"),
               value
        )
    }
    public static let bookingRateCardTitle = NSLocalizedString(
        "booking_ratecard_title",
        bundle: .module,
        comment: "usage for title of booking service page"
    )
    public static let bookingRateCardMessageSubtitle = NSLocalizedString(
        "booking_rate_card_message_subtitle",
        bundle: .module,
        comment: "usage for note below the message title section on rate card booking"
    )
    public static let bookingRateCardShowFullText = NSLocalizedString(
        "booking_ratecard_show_full_text",
        bundle: .module,
        comment: "usage for show full rate card description text"
    )
    public static let bookingRateCardHideFullText = NSLocalizedString(
        "booking_ratecard_hide_full_text",
        bundle: .module,
        comment: "usage for hide full rate card description text"
    )
    public static func minuteInDuration(_ minute: Int) -> String {
        String(format: NSLocalizedString(
            "minute_in_duration",
            bundle: .module,
            comment: "usage for rate card duration with minutes"),
               minute
        )
    }
    public static let unconfirmedText = NSLocalizedString(
        "not_confirmed_text",
        bundle: .module,
        comment: "usage for unconfirmed time in schedule card"
    )
    public static let giveReviewLabel = NSLocalizedString(
        "give_review_label",
        bundle: .module,
        comment: "usage for give a review button when session has done"
    )
    public static let detailScheduleTitle = NSLocalizedString(
        "detail_schedule_title",
        bundle: .module,
        comment: "usage for the title of the schedule status"
    )
    public static let stepWaitingConfirmation = NSLocalizedString(
        "step_waiting_confirmation",
        bundle: .module,
        comment: "usage for the creators confirmation step label"
    )
    public static let stepSetSessionTime = NSLocalizedString(
        "step_set_session_time",
        bundle: .module,
        comment: "usage for set session time step label"
    )
    public static let videoCallDetailTitle = NSLocalizedString(
        "video_call_detail_title",
        bundle: .module,
        comment: "usage for the title of video call detail page"
    )
    public static let privateVideoCallLabel = NSLocalizedString(
        "private_video_call_label",
        bundle: .module,
        comment: "usage for private video call label in session card"
    )
    public static let priceLabel = NSLocalizedString(
        "price_label",
        bundle: .module,
        comment: "usage for price label in rate card"
    )
    public static let noteForCreatorPlaceholder = NSLocalizedString(
        "note_for_creator_placeholder",
        bundle: .module,
        comment: "usage for note for creator placeholder in rate card"
    )
    public static let noteForCreatorTitle = NSLocalizedString(
        "note_for_creator_title",
        bundle: .module,
        comment: "usage for note for creator title in rate card"
    )
    public static let noteForCreatorSuggestTimeTitle = NSLocalizedString(
        "note_for_creator_suggest_time_title",
        bundle: .module,
        comment: "suggest time title"
    )
    public static let noteForCreatorSuggestTimeSubtitle = NSLocalizedString(
        "note_for_creator_suggest_time_subtitle",
        bundle: .module,
        comment: "suggest time for creator"
    )
    public static let noteForCreatorDateTitle = NSLocalizedString(
        "note_for_creator_date_title",
        bundle: .module,
        comment: "date"
    )
    public static let noteForCreatorTimeTitle = NSLocalizedString(
        "note_for_creator_time_title",
        bundle: .module,
        comment: "time"
    )
    public static let nextLabel = NSLocalizedString(
        "next_label",
        bundle: .module,
        comment: "usage for next label"
    )
    public static let descriptionAddCoin = NSLocalizedString(
        "description_add_coin",
        bundle: .module,
        comment: "usage for description text in add coin bottom sheet"
    )
    public static let limitedQuotaLabelWithEmoji = NSLocalizedString(
        "limited_quota_label",
        bundle: .module,
        comment: "usage for limited quota label with emoji"
    )
    public static let cancelLabel = NSLocalizedString(
        "cancel_label",
        bundle: .module,
        comment: "usage for cancel label"
    )
    public static let payLabel = NSLocalizedString(
        "pay_label",
        bundle: .module,
        comment: "usage for pay label"
    )
    public static let inAppPurchaseLabel = NSLocalizedString(
        "in_app_purchase_label",
        bundle: .module,
        comment: "usage for in-app purchase label"
    )
    public static let otherPaymentMethodTitle = NSLocalizedString(
        "other_payment_method_title",
        bundle: .module,
        comment: "usage for other payment method title in payment method"
    )
    public static let otherPaymentMethodDescription = NSLocalizedString(
        "other_payment_method_description",
        bundle: .module,
        comment: "usage for other payment method description in payment method"
    )
    public static let paymentConfirmationTitle = NSLocalizedString(
        "payment_confirmation_title",
        bundle: .module,
        comment: "usage for other payment confirmation title in payment method"
    )
    public static let promoCodeTitle = NSLocalizedString(
        "promo_code_title",
        bundle: .module,
        comment: "usage for other promo code title in bill"
    )
    public static let promoCodeLabel = NSLocalizedString(
        "promo_code_label",
        bundle: .module,
        comment: "usage for other promo code label in bill"
    )
    public static let enterLabel = NSLocalizedString(
        "enter_label",
        bundle: .module,
        comment: "usage for general enter label"
    )
    public static let paymentLabel = NSLocalizedString(
        "payment_label",
        bundle: .module,
        comment: "usage for general payment label"
    )
    public static let feeSubTotalLabel = NSLocalizedString(
        "fee_sub_total_label",
        bundle: .module,
        comment: "usage for subtotal fee label in bill"
    )
    public static let feeApplication = NSLocalizedString(
        "fee_application",
        bundle: .module,
        comment: "usage for application fee label in bill"
    )
    public static let feeService = NSLocalizedString(
        "fee_service",
        bundle: .module,
        comment: "usage for service fee label in bill"
    )
    public static let totalLabel = NSLocalizedString(
        "total_label",
        bundle: .module,
        comment: "usage for general total label"
    )
    public static let paymentPromoNotFound = NSLocalizedString(
        "payment_promo_not_found",
        bundle: .module,
        comment: "usage for payment not found error message"
    )
    public static let applePayText = NSLocalizedString(
        "apple_pay_text",
        bundle: .module,
        comment: "usage for apple pay text"
    )
    public static let discountLabel = NSLocalizedString(
        "discount_label",
        bundle: .module,
        comment: "usage for discount text"
    )
    public static let continuePaymentLabel = NSLocalizedString(
        "continue_payment_label",
        bundle: .module,
        comment: "usage for continue payment button"
    )
    public static let cancelPaymentQuestion = NSLocalizedString(
        "cancel_payment_question",
        bundle: .module,
        comment: "usage for cancel payment question in detail payment"
    )
    public static let cancelPaymentTitleQuestion = NSLocalizedString(
        "cancel_payment_title_question",
        bundle: .module,
        comment: "usage for cancel payment question in detail payment bottom sheet"
    )
    public static let cancelPaymentDescription = NSLocalizedString(
        "cancel_payment_description",
        bundle: .module,
        comment: "usage for cancel payment description in detail payment bottom sheet"
    )
    public static let cancelPaymentConfirmation = NSLocalizedString(
        "cancel_payment_confirmation",
        bundle: .module,
        comment: "usage for cancel payment confirmation button in detail payment bottom sheet"
    )
    public static let logoutTitleQuestion = NSLocalizedString(
        "logout_title_question",
        bundle: .module,
        comment: "usage for logout question title in profile"
    )
    public static let logoutDescription = NSLocalizedString(
        "logout_description",
        bundle: .module,
        comment: "usage for logout description in profile"
    )
    public static let seeDetailsLabel = NSLocalizedString(
        "see_details_label",
        bundle: .module,
        comment: "usage for see details button in payment"
    )
    public static let detailPaymentTitle = NSLocalizedString(
        "detail_payment_title",
        bundle: .module,
        comment: "usage for detail payment title in payment bottom sheet"
    )
    public static let withdrawErrorAmountOver = NSLocalizedString(
        "withdraw_error_amount_over",
        bundle: .module,
        comment: "usage for error message if the transaction exceeds the maximum limit"
    )
    public static let withdrawErrorLess = NSLocalizedString(
        "withdraw_error_less",
        bundle: .module,
        comment: "usage for error message if the transaction is less than Rp50.000"
    )
    public static let withdrawErrorOverBalance = NSLocalizedString(
        "withdraw_error_over_balance",
        bundle: .module,
        comment: "usage for error message if the transaction exceeds user balance"
    )
	public static let invoiceItemName = NSLocalizedString(
		"invoice_item_name",
		bundle: .module,
		comment: "usage for item name labelling"
	)
	public static let invoiceFailedPayment = NSLocalizedString(
		"invoice_failed_payment",
		bundle: .module,
		comment: "usage for failed wording title"
	)
	public static let generalOrderAgain = NSLocalizedString(
		"general_order_again",
		bundle: .module,
		comment: "usage for order again labelling"
	)
	public static let detailPaymentCancelConfirmation = NSLocalizedString(
		"detail_payment_cancel_confirmation",
		bundle: .module,
		comment: "usage for cancel confirmation button label"
	)
	public static let profileChoosenCreator = NSLocalizedString(
		"profile_choosen_creator",
		bundle: .module,
		comment: "usage for choosen creator label on profile"
	)
	public static let choosenCreatorEmpty = NSLocalizedString(
		"choosen_creator_empty",
		bundle: .module,
		comment: "usage for empty label when item is empty"
	)
	public static let professionManagement = NSLocalizedString(
		"profession_management",
		bundle: .module,
		comment: "usage for management label profession"
	)
	public static let managementName = NSLocalizedString(
		"management_name",
		bundle: .module,
		comment: "usage for managed by label"
	)
	public static let talentDetailSession = NSLocalizedString(
		"talent_detail_session",
		bundle: .module,
		comment: "used to labelling session title"
	)
	public static let talentDetailFollower = NSLocalizedString(
		"talent_detail_follower",
		bundle: .module,
		comment: "used to follower label"
	)
	public static let talentDetailRating = NSLocalizedString(
		"talent_detail_rating",
		bundle: .module,
		comment: "used to labelling rating"
	)
	public static let talentDetailFollow = NSLocalizedString(
		"talent_detail_follow",
		bundle: .module,
		comment: "used to follow button label"
	)
	public static let talentDetailFollowing = NSLocalizedString(
		"talent_detail_following",
		bundle: .module,
		comment: "used to labelling following"
	)
	public static let talentDetailInformation = NSLocalizedString(
		"talent_detail_information",
		bundle: .module,
		comment: "used to labelling information tab bar"
	)
	public static let talentDetailServices = NSLocalizedString(
		"talent_detail_services",
		bundle: .module,
		comment: "used to labelling services tab title"
	)
	public static let talentDetailReviews = NSLocalizedString(
		"talent_detail_review",
		bundle: .module,
		comment: "used to labelling reviews tab"
	)
	public static let talentDetailAboutMe = NSLocalizedString(
		"talent_detail_about_me",
		bundle: .module,
		comment: "used to be labelling about me title"
	)
	public static let talentDetailGallery = NSLocalizedString(
		"talent_detail_gallery",
		bundle: .module,
		comment: "used to be labelling gallery title"
	)
	public static let talentDetailEmptyReviewTitle = NSLocalizedString(
		"talent_detail_empty_review_title",
		bundle: .module,
		comment: "used to be title when reviews empty"
	)
	public static let talentDetailEmptyReviewContent = NSLocalizedString(
		"talent_detail_empty_review_content",
		bundle: .module,
		comment: "used to be content when reviews empty"
	)
    public static let talentDetailAvailableSessions = NSLocalizedString(
        "talent_detail_available_sessions",
        bundle: .module,
        comment: "used to be content when filter available session"
    )
    public static let searchPlaceholder = NSLocalizedString(
        "search_placeholder",
        bundle: .module,
        comment: "usage for text in search bar placeholder"
    )
    public static let searchRecommendationTitle = NSLocalizedString(
        "search_recommendation_title",
        bundle: .module,
        comment: "usage for search recommendation title in search menu"
    )
    public static let tabSession = NSLocalizedString(
        "tab_session",
        bundle: .module,
        comment: "usage for session tab in search menu"
    )
    public static let tabCreator = NSLocalizedString(
        "tab_creator",
        bundle: .module,
        comment: "usage for creator tab in search menu"
    )
    public static let searchRelatedCreatorTitle = NSLocalizedString(
        "search_related_creator_title",
        bundle: .module,
        comment: "usage for related creator title text in search menu"
    )
    public static let searchRelatedSessionTitle = NSLocalizedString(
        "search_related_session_title",
        bundle: .module,
        comment: "usage for related session title text in search menu"
    )
    public static let searchSeeAllLabel = NSLocalizedString(
        "search_see_all_label",
        bundle: .module,
        comment: "usage for see all button in search menu"
    )
    public static let searchGeneralNotFound = NSLocalizedString(
        "search_general_not_found",
        bundle: .module,
        comment: "usage for the message when search is not found"
    )
    public static let searchTellUsLabel = NSLocalizedString(
        "search_tell_us_label",
        bundle: .module,
        comment: "usage for label in button to open whatsapp in search menu"
    )
    public static let searchCreatorNotFoundTitle = NSLocalizedString(
        "search_creator_not_found_title",
        bundle: .module,
        comment: "usage for title when creator is not found in search menu"
    )
    public static let searchCreatorNotFoundDesc = NSLocalizedString(
        "search_creator_not_found_desc",
        bundle: .module,
        comment: "usage for desc when creator is not found in search menu"
    )
    public static let searchSessionNotFoundTitle = NSLocalizedString(
        "search_session_not_found_title",
        bundle: .module,
        comment: "usage for title when session is not found in search menu"
    )
    public static let searchSessionNotFoundDesc = NSLocalizedString(
        "search_session_not_found_desc",
        bundle: .module,
        comment: "usage for desc when session is not found in search menu"
    )
    public static let searchText = NSLocalizedString(
        "search_text",
        bundle: .module,
        comment: "usage for search text in search menu"
    )
    public static let seeText = NSLocalizedString(
        "see_text",
        bundle: .module,
        comment: "usage for see text in session card"
    )
    public static let sessionCompleted = NSLocalizedString(
        "session_completed",
        bundle: .module,
        comment: "usage for completed session text in session card"
    )
    public static let freeText = NSLocalizedString(
        "free_text",
        bundle: .module,
        comment: "usage for free text in session card"
    )
    public static let inAppPurchaseErrorTrx = NSLocalizedString(
        "in_app_purchase_error_trx",
        bundle: .module,
        comment: "usage for error message when unable to do in-app purchase transaction"
    )
	public static let bundlingText = NSLocalizedString(
		"bundling_text",
		bundle: .module,
		comment: "used to bundling title text"
	)
	public static func sessionValueText(with session: Int) -> String {
		String(format: NSLocalizedString("session_value_text", bundle: .module, comment: "used for session with value labelling"), session)
	}
	public static let bundlingSession = NSLocalizedString(
		"bundling_session",
		bundle: .module,
		comment: "used to describe a bundling session label"
	)
	public static let seeBundling = NSLocalizedString(
		"see_bundling",
		bundle: .module,
		comment: "used to label a see bundling button"
	)
	public static func totalSessionValueText(with session: Int) -> String {
		String(format: NSLocalizedString("total_session_value", bundle: .module, comment: "used for total session with value labelling"), session)
	}
	public static let bookingText = NSLocalizedString(
		"booking_text",
		bundle: .module,
		comment: "used for label booking text"
	)
	public static let requestSession = NSLocalizedString(
		"request_session",
		bundle: .module,
		comment: "used for request session label"
	)
	public static let galleryEmpty = NSLocalizedString(
		"gallery_empty",
		bundle: .module,
		comment: "used for empty gallery text"
	)
    public static let scheduleTodayAgenda = NSLocalizedString(
        "schedule_today_agenda",
        bundle: .module,
        comment: "used for today agenda text in schedule menu"
    )
    public static let scheduleTabWaiting = NSLocalizedString(
        "schedule_tab_waiting",
        bundle: .module,
        comment: "used for waiting payment tab in schedule menu"
    )
    public static let scheduleTabUpcoming = NSLocalizedString(
        "schedule_tab_upcoming",
        bundle: .module,
        comment: "used for upcoming session tab in schedule menu"
    )
    public static let scheduleTabCancel = NSLocalizedString(
        "schedule_tab_cancel",
        bundle: .module,
        comment: "used for canceled session tab in schedule menu"
    )
    public static let scheduleEmptyTodayAgenda = NSLocalizedString(
        "schedule_empty_today_agenda",
        bundle: .module,
        comment: "used for message when todays agenda is empty"
    )
    public static let scheduleEmptySessionTitle = NSLocalizedString(
        "schedule_empty_session_title",
        bundle: .module,
        comment: "used for message title when session is empty"
    )
    public static let scheduleEmptySessionDesc = NSLocalizedString(
        "schedule_empty_session_desc",
        bundle: .module,
        comment: "used for message desc when session is empty"
    )
    public static let scheduleSearchSessionLabel = NSLocalizedString(
        "schedule_search_session_label",
        bundle: .module,
        comment: "used for message desc when session is empty"
    )
    public static let totalPriceLabel = NSLocalizedString(
        "total_price_label",
        bundle: .module,
        comment: "used for total price label on button"
    )
    public static let paymentFailedText = NSLocalizedString(
        "payment_failed_text",
        bundle: .module,
        comment: "used for payment failed status on session card"
    )
    public static let payNowLabel = NSLocalizedString(
        "pay_now_label",
        bundle: .module,
        comment: "used for pay now label button on session card"
    )
    public static let yourCommentTitle = NSLocalizedString(
        "your_comment_title",
        bundle: .module,
        comment: "used for title of comment section in review sheet"
    )
    public static let yourCommentPlaceholder = NSLocalizedString(
        "your_comment_placeholder",
        bundle: .module,
        comment: "used for placeholder of comment section in review sheet"
    )
    public static let sendReviewLabel = NSLocalizedString(
        "send_review_label",
        bundle: .module,
        comment: "used for send review button in review sheet"
    )
    public static let reviewSuccessTitle = NSLocalizedString(
        "review_success_title",
        bundle: .module,
        comment: "used alert title when review submitted successfully"
    )
    public static let reviewSuccessMessage = NSLocalizedString(
        "review_success_message",
        bundle: .module,
        comment: "used alert message when review submitted successfully"
    )
  public static let resendLabel = NSLocalizedString(
    "resend_label",
    bundle: .module,
    comment: "used for resend button label"
  )
  public static let seeAgendaLabel = NSLocalizedString(
    "see_agenda_label",
    bundle: .module,
    comment: "used for see agenda button label"
  )
  public static let alertSuccessChangeProfileTitle = NSLocalizedString(
    "alert_success_change_profile_title",
    bundle: .module,
    comment: "used for alert title when profile changed successfully"
  )
  public static let alertSuccessChangeProfileMessage = NSLocalizedString(
    "alert_success_change_profile_message",
    bundle: .module,
    comment: "used for alert message when profile changed successfully"
  )
  public static let alertFailedChangeProfileTitle = NSLocalizedString(
    "alert_failed_change_profile_title",
    bundle: .module,
    comment: "used for alert title when failed to change profile"
  )
  public static let alertFailedChangeProfileMessage = NSLocalizedString(
    "alert_failed_change_profile_message",
    bundle: .module,
    comment: "used for alert message when failed to change profile"
  )
  public static let alertFailedChangePasswordTitle = NSLocalizedString(
    "alert_failed_change_password_title",
    bundle: .module,
    comment: "used for alert title when failed to change password"
  )
  public static let alertFailedChangePasswordMessage = NSLocalizedString(
    "alert_failed_change_password_message",
    bundle: .module,
    comment: "used for alert message when failed to change password"
  )
  public static let alertFailedGiveReviewTitle = NSLocalizedString(
    "alert_failed_give_review_title",
    bundle: .module,
    comment: "used for alert title when failed to send review"
  )
  public static let alertFailedGiveReviewMessage = NSLocalizedString(
    "alert_failed_give_review_message",
    bundle: .module,
    comment: "used for alert message when failed to send review"
  )
  public static let alertSuccessRequestSessionTitle = NSLocalizedString(
    "alert_success_request_session_title",
    bundle: .module,
    comment: "used for alert title when session requested successfully"
  )
  public static let alertSuccessRequestSessionMessage = NSLocalizedString(
    "alert_success_request_session_message",
    bundle: .module,
    comment: "used for alert message when session requested successfully"
  )
  public static let alertFailedRequestSessionTitle = NSLocalizedString(
    "alert_failed_request_session_title",
    bundle: .module,
    comment: "used for alert title when failed to request session"
  )
  public static let alertFailedRequestSessionMessage = NSLocalizedString(
    "alert_failed_request_session_message",
    bundle: .module,
    comment: "used for alert message when failed to request session"
  )
  public static let alertSuccessBookingTitle = NSLocalizedString(
    "alert_success_booking_title",
    bundle: .module,
    comment: "used for alert title when session booked successfully"
  )
  public static let alertSuccessBookingMessage = NSLocalizedString(
    "alert_success_booking_message",
    bundle: .module,
    comment: "used for alert message when session booked successfully"
  )
  public static let alertFailedBookingTitle = NSLocalizedString(
    "alert_failed_booking_title",
    bundle: .module,
    comment: "used for alert title when failed to book session"
  )
  public static let alertFailedBookingMessage = NSLocalizedString(
    "alert_failed_booking_message",
    bundle: .module,
    comment: "used for alert message when failed to book session"
  )
  public static let alertSuccessFollowTitle = NSLocalizedString(
    "alert_success_follow_title",
    bundle: .module,
    comment: "used for alert title when success follow creator"
  )
  public static let alertSuccessFollowMessage = NSLocalizedString(
    "alert_success_follow_message",
    bundle: .module,
    comment: "used for alert message when success follow creator"
  )
  public static let alertFailedFollowTitle = NSLocalizedString(
    "alert_failed_follow_title",
    bundle: .module,
    comment: "used for alert title when failed to follow creator"
  )
  public static let alertFailedFollowMessage = NSLocalizedString(
    "alert_failed_follow_message",
    bundle: .module,
    comment: "used for alert message when failed to follow creator"
  )
  public static let alertSuccessChangePhoneTitle = NSLocalizedString(
    "alert_success_change_phone_title",
    bundle: .module,
    comment: "used for alert title when success to change phone number"
  )
  public static let alertSuccessChangePhoneMessage = NSLocalizedString(
    "alert_success_change_phone_message",
    bundle: .module,
    comment: "used for alert message when success to change phone number"
  )
  public static let alertFailedChangePhoneTitle = NSLocalizedString(
    "alert_failed_change_phone_title",
    bundle: .module,
    comment: "used for alert title when failed to change phone number"
  )
  public static let alertFailedChangePhoneMessage = NSLocalizedString(
    "alert_failed_change_phone_message",
    bundle: .module,
    comment: "used for alert message when failed to change phone number"
  )
  public static let alertSessionExpired = NSLocalizedString(
    "alert_session_expired",
    bundle: .module,
    comment: "used for alert message when user session has expired"
  )
    public static let sessionCardBooked = NSLocalizedString(
        "session_card_booked",
        bundle: .module,
        comment: "usage for booked label on schedule"
    )
  public static let listManagementLabel = NSLocalizedString(
    "list_management_label",
    bundle: .module,
    comment: "usage for list management bottom sheet label"
  )
  public static let attachmentsText = NSLocalizedString(
    "attachments_text",
    bundle: .module,
    comment: "usage for attachments text in schedule detail"
  )
    public static let revenuePurposeText = NSLocalizedString(
        "general_revenue_purpose",
        bundle: .module,
        comment: "usage for revenue purpose on talent form schedule card"
    )
    
    public static let personalWalletText = NSLocalizedString(
        "general_private_wallet",
        bundle: .module,
        comment: "usage for personal wallet on talent form schedule card"
    )
  public static let urlLinkText = NSLocalizedString(
      "url_link_text",
      bundle: .module,
      comment: "usage for URL Link text in session form"
  )
  public static let addUrlLinkLabel = NSLocalizedString(
      "add_url_link_label",
      bundle: .module,
      comment: "usage for add URL Link button in session form"
  )
  public static let deleteUrlLinkLabel = NSLocalizedString(
      "delete_url_link_label",
      bundle: .module,
      comment: "usage for delete URL Link button in session form"
  )
  public static let urlLinkTitlePlaceholder = NSLocalizedString(
      "url_link_title_placeholder",
      bundle: .module,
      comment: "usage for URL Link title placeholder in session form"
  )
  public static let seeAdditionalMenuLabel = NSLocalizedString(
      "see_additional_menu_label",
      bundle: .module,
      comment: "usage for see additional menu button in session form"
  )
  public static let hideAdditionalMenuLabel = NSLocalizedString(
      "hide_additional_menu_label",
      bundle: .module,
      comment: "usage for hide additional menu button in session form"
  )
  public static let emptyFileMessage = NSLocalizedString(
      "empty_file_message",
      bundle: .module,
      comment: "usage for hide additional menu button in session form"
  )
    public static let invalidUrlMessage = NSLocalizedString(
        "invalid_url",
        bundle: .module,
        comment: "usage for invalid url format message"
    )
    public static let collaborationTitle = NSLocalizedString(
        "collaboration_text",
        bundle: .module,
        comment: "usage for collaboration title text"
    )
    public static let collaborationPlaceholder = NSLocalizedString(
        "collaboration_placeholder",
        bundle: .module,
        comment: "usage for placeholder of collaboration field"
    )
    public static let invitedCreatorTitle = NSLocalizedString(
        "invited_creator_title",
        bundle: .module,
        comment: "usage for title of invited creator"
    )
    public static let waitingForConfirmCollab = NSLocalizedString(
        "waiting_for_confirmation_collab",
        bundle: .module,
        comment: "usage for waiting status of invited creator"
    )
    public static let acceptedCollab = NSLocalizedString(
        "accepted_collab",
        bundle: .module,
        comment: "usage for accepted status of invited creator"
    )
    public static let declinedCollab = NSLocalizedString(
        "declined_collab",
        bundle: .module,
        comment: "usage for declined status of invited creator"
    )
    public static let creatorInvitedCollabTitle = NSLocalizedString(
        "creator_invited_collab_title",
        bundle: .module,
        comment: "usage for creator invited text"
    )
    public static let searchCreatorPlaceholder = NSLocalizedString(
        "search_creator_placeholder",
        bundle: .module,
        comment: "usage for search creator placeholder"
    )
    public static let selectCreatorForCollabTitle = NSLocalizedString(
        "select_creator_for_collaboration_title",
        bundle: .module,
        comment: "usage for select collab creator title sheet"
    )
    public static let retryText = NSLocalizedString(
        "retry_text",
        bundle: .module,
        comment: "usage for retry text"
    )
    public static let retrySubtitle = NSLocalizedString(
        "retry_subtitle",
        bundle: .module,
        comment: "usage for retry subtitle text"
    )
    public static let rejectedText = NSLocalizedString(
        "rejected_text",
        bundle: .module,
        comment: "usage for rejected text for collab status"
    )
    public static let waitingText = NSLocalizedString(
        "waiting_text",
        bundle: .module,
        comment: "usage for waiting text for collab status"
    )
    public static let withText = NSLocalizedString(
        "with_text",
        bundle: .module,
        comment: "usage for with text"
    )
    
    public static let seeInvitation = NSLocalizedString(
        "see_invitation",
        bundle: .module,
        comment: "see invitation label for notification card collab button"
    )
    
    public static let decline = NSLocalizedString(
        "decline",
        bundle: .module,
        comment: "general decline text"
    )
    
    public static let accept = NSLocalizedString(
        "accept",
        bundle: .module,
        comment: "general accept text"
    )
    
    public static let acceptInvitation = NSLocalizedString(
        "accept_invitation",
        bundle: .module,
        comment: "accept invitation label for notification card collab button"
    )
    
    public static let acceptedInvitationTitle = NSLocalizedString(
        "accepted_invitation_title",
        bundle: .module,
        comment: "accepted title for alert when succeed to accept collaboration"
    )
    
    public static func acceptedInvitationMessage(name: String, title: String) -> String {
        String(
            format: NSLocalizedString(
                "accepted_invitation_message",
                bundle: .module,
                comment: "accepted message for alert when succeed to accept collaboration"
            ),
            name,
            title
        )
    }
    
    public static let declinedInvitationTitle = NSLocalizedString(
        "declined_invitation_title",
        bundle: .module,
        comment: "declined title for alert when succeed to decline collaboration"
    )
    
    public static func declinedInvitationMessage(name: String, title: String) -> String {
        String(
            format: NSLocalizedString(
                "declined_invitation_message",
                bundle: .module,
                comment: "declined message for alert when succeed to decline collaboration"
            ),
            name,
            title
        )
    }
  
    public static let collaboratorSpeakerTitle = NSLocalizedString(
        "collaborator_speaker_title",
        bundle: .module,
        comment: "collaborator speaker title for schedule detail"
    )
    
    public static let outdatedVersionUpdateNow = NSLocalizedString(
        "outdated_version_update_text",
        bundle: .module,
        comment: "update now label for outdated version view"
    )
    
    public static let outdatedVersionSubtitleContent = NSLocalizedString(
        "outdated_version_subtitle_content",
        bundle: .module,
        comment: "subtitle content of outdated version view"
    )
    
    public static let outdatedVersionTitleContent = NSLocalizedString(
        "outdated_version_title_content",
        bundle: .module,
        comment: "title content of outdated version view"
    )
    public static let labelChat = NSLocalizedString(
        "label_chat",
        bundle: .module,
        comment: "Chat label"
    )
    public static let aboutCallTitle = NSLocalizedString(
        "about_call_title",
        bundle: .module,
        comment: "title in about call bottom sheet"
    )
    public static let labelPolls = NSLocalizedString(
        "label_polls",
        bundle: .module,
        comment: "label button in polls section"
    )
    public static let titleWaitingRoom = NSLocalizedString(
        "title_waiting_room",
        bundle: .module,
        comment: "title in waiting room"
    )
    public static let acceptAllLabel = NSLocalizedString(
        "accept_all_label",
        bundle: .module,
        comment: "accept all label in meeting room"
    )
    public static let acceptToJoinLabel = NSLocalizedString(
        "accept_to_join_label",
        bundle: .module,
        comment: "accept to join label in meeting room"
    )
    public static let speakerTitle = NSLocalizedString(
        "speaker_title",
        bundle: .module,
        comment: "speaker title"
    )
    public static let viewerTitle = NSLocalizedString(
        "viewer_title",
        bundle: .module,
        comment: "viewer title"
    )
    
    public static let liveText = NSLocalizedString(
        "live_text",
        bundle: .module,
        comment: "general live text"
    )
    
    public static let videoCallMoreMenu = NSLocalizedString(
        "video_call_more_menu",
        bundle: .module,
        comment: "more menu text for more menu sheet title"
    )
    public static let videoCallQna = NSLocalizedString(
        "video_call_qna",
        bundle: .module,
        comment: "qna text"
    )
    public static let videoCallPolls = NSLocalizedString(
        "video_call_polls",
        bundle: .module,
        comment: "polls text"
    )
    public static let videoCallRecord = NSLocalizedString(
        "video_call_record",
        bundle: .module,
        comment: "record text"
    )
    public static let videoCallInformation = NSLocalizedString(
        "video_call_information",
        bundle: .module,
        comment: "information text"
    )
    public static let generalSearchPlaceholder = NSLocalizedString(
        "general_search_placeholder",
        bundle: .module,
        comment: "for general search bar placeholder"
    )
    public static let videoCallMessagePlaceholder = NSLocalizedString(
        "video_call_message_placeholder",
        bundle: .module,
        comment: "for message bar placeholder"
    )
    public static let videoCallPollByHost = NSLocalizedString(
        "video_call_poll_by_host",
        bundle: .module,
        comment: "poll by host title in video call"
    )
    public static let videoCallPollQuestionTitle = NSLocalizedString(
        "video_call_poll_question_title",
        bundle: .module,
        comment: "poll question title in video call"
    )
    public static let videoCallPollQuestionPlaceholder = NSLocalizedString(
        "video_call_poll_question_placeholder",
        bundle: .module,
        comment: "for poll question bar placeholder"
    )
    public static let videoCallPollAddOption = NSLocalizedString(
        "video_call_poll_add_option",
        bundle: .module,
        comment: "add option text"
    )
    public static let anonymousText = NSLocalizedString(
        "anonymous_text",
        bundle: .module,
        comment: "anonymous text"
    )
    public static let videoCallPollHideResult = NSLocalizedString(
        "video_call_poll_hide_result",
        bundle: .module,
        comment: "for video call hide polling result text"
    )
    public static let videoCallCreatePollTitle = NSLocalizedString(
        "video_call_create_poll_title",
        bundle: .module,
        comment: "for video call create polling title"
    )
    public static let videoCallCancelPollTitle = NSLocalizedString(
        "video_call_cancel_poll_title",
        bundle: .module,
        comment: "for video call cancel polling title"
    )
    public static let videoCallCreateNewPollTitle = NSLocalizedString(
        "video_call_create_new_poll_title",
        bundle: .module,
        comment: "for video call create new polling title"
    )
    public static let videoCallCreatePollFooter = NSLocalizedString(
        "video_call_create_poll_footer",
        bundle: .module,
        comment: "for video call create polling footer"
    )
    public static let videoCallFiveMinutesLeftAlertTitle = NSLocalizedString(
        "video_call_five_minutes_left_alert_title",
        bundle: .module,
        comment: "for video call alert title when session is about to end"
    )
    public static let videoCallFiveMinutesLeftAlertDesc = NSLocalizedString(
        "video_call_five_minutes_left_alert_desc",
        bundle: .module,
        comment: "for video call alert description when session is about to end"
    )
    public static let understoodText = NSLocalizedString(
        "understood_text",
        bundle: .module,
        comment: "understood text"
    )
    public static let videoCallScreenShareText = NSLocalizedString(
        "video_call_screen_share_text",
        bundle: .module,
        comment: "video call screen share text"
    )
    
    public static func videoCallSessionTitle(creatorName: String) -> String {
        String(
            format: NSLocalizedString(
                "video_call_session_title",
                bundle: .module,
                comment: "video call session title"
            ),
            creatorName
        )
    }
    
    public static let videoCallScheduledText = NSLocalizedString(
        "video_call_scheduled_text",
        bundle: .module,
        comment: "video call schedule text"
    )
    public static let timeText = NSLocalizedString(
        "time_text",
        bundle: .module,
        comment: "time text"
    )
    public static let typeText = NSLocalizedString(
        "type_text",
        bundle: .module,
        comment: "type text"
    )
    public static let groupCallText = NSLocalizedString(
        "group_call_text",
        bundle: .module,
        comment: "type text"
    )
    public static let videoCallListQuestionTitle = NSLocalizedString(
        "video_call_list_question_title",
        bundle: .module,
        comment: "video call list of question title"
    )
    public static let videoCallBoxQuestionTitle = NSLocalizedString(
        "video_call_box_question_title",
        bundle: .module,
        comment: "video call question box title"
    )
    public static let videoCallSendQuestionTitle = NSLocalizedString(
        "video_call_send_question_title",
        bundle: .module,
        comment: "video call send question title"
    )
    
    public static let videoCallJoinStageRequest = NSLocalizedString(
        "video_call_join_stage_request",
        bundle: .module,
        comment: "video call join stage request"
    )
    
    public static let videoCallPinParticipant = NSLocalizedString(
        "video_call_pin_participant",
        bundle: .module,
        comment: "video call pin participant"
    )
    
    public static let videoCallUnpinParticipant = NSLocalizedString(
        "video_call_unpin_participant",
        bundle: .module,
        comment: "video call unpin participant"
    )
    
    public static let videoCallMuteParticipant = NSLocalizedString(
        "video_call_mute_participant",
        bundle: .module,
        comment: "video call mute participant"
    )
    
    public static let videoCallOffVideo = NSLocalizedString(
        "video_call_off_video",
        bundle: .module,
        comment: "video call off video"
    )
    
    public static let videoCallPutToViewer = NSLocalizedString(
        "video_call_put_to_viewer",
        bundle: .module,
        comment: "video call put to viewer"
    )
    
    public static let videoCallKickFromSession = NSLocalizedString(
        "video_call_kick_from_session",
        bundle: .module,
        comment: "video call kick from session"
    )
    
    public static let videoCallKickAlertFromSession = NSLocalizedString(
        "video_call_alert_kick_participant",
        bundle: .module,
        comment: "video call kick alert from session"
    )
    
    public static let videoCallKickAlertSecondaryButton = NSLocalizedString(
        "video_call_secondary_button_alert_kick_participant",
        bundle: .module,
        comment: "video call kick alert secondary button"
    )
    
    public static let videoCallKickAlertPrimaryButton = NSLocalizedString(
        "video_call_primary_button_alert_kick_participant",
        bundle: .module,
        comment: "video call kick alert primary button"
    )
    public static let videoCallWaitingRoomTitle = NSLocalizedString(
        "video_call_waiting_room_title",
        bundle: .module,
        comment: "video call waiting room title"
    )
    public static let videoCallWaitingRoomDesc = NSLocalizedString(
        "video_call_waiting_room_desc",
        bundle: .module,
        comment: "video call waiting room description"
    )
    public static func creatorRescheduleWarning(_ minute: Int) -> String {
        String(
            format: NSLocalizedString(
                "creator_reschedule_warning",
                bundle: .module,
                comment: "reschedule warning when creator wants to edit the schedule"
            ),
            minute
        )
    }
    public static let videoCallPutToSpeaker = NSLocalizedString(
        "video-call-put-to-speaker",
        bundle: .module,
        comment: "video call viewer put to speaker"
    )
    public static let videoCallQnAEmptyText = NSLocalizedString(
        "video_call_qna_empty",
        bundle: .module,
        comment: "empty state qna text"
    )
    public static let videoCallQnaAnsweredEmptyText = NSLocalizedString(
        "video_call_qna_answered_empty",
        bundle: .module,
        comment: "empty state qna answered text"
    )
    public static let videoCallQuestionsTitle = NSLocalizedString(
        "video_call_questions_title",
        bundle: .module,
        comment: "questions tab title text"
    )
    public static let videoCallAnsweredTitle = NSLocalizedString(
        "video_call_answered_title",
        bundle: .module,
        comment: "answered tab title text"
    )
    public static let videoCallRemovedFromRoomMessage = NSLocalizedString(
        "video_call_removed_from_room_message",
        bundle: .module,
        comment: "kicked message"
    )
    public static let videoCallWaitingCreatorTitle = NSLocalizedString(
        "video_call_waiting_creator_title",
        bundle: .module,
        comment: "waiting creator title"
    )
    public static let videoCallWaitingCreatorSubtitle = NSLocalizedString(
        "video_call_waiting_creator_subtitle",
        bundle: .module,
        comment: "waiting creator subtitle"
    )
    
    public static let videoCallConnectionFailed = NSLocalizedString(
        "video_call_failed_connect_meeting_room",
        bundle: .module,
        comment: "connection_failed"
    )
    
    public static let videoCallFailedJoin = NSLocalizedString(
        "video_call_failed_join_meeting_room",
        bundle: .module,
        comment: "join_failed"
    )
    
    public static let videoCallAlertError = NSLocalizedString(
        "video_call_alert_error",
        bundle: .module,
        comment: "alert_error"
    )
    
    public static let videoCallDismissError = NSLocalizedString(
        "video_call_dismiss_error",
        bundle: .module,
        comment: "dismiss_error"
    )
    
    public static let videoCallFailedPinParticipant = NSLocalizedString(
        "video_call_failed_pin",
        bundle: .module,
        comment: "failed_pin"
    )
    
    public static let videoCallFailedDisableAudio = NSLocalizedString(
        "video_call_failed_disable_audio",
        bundle: .module,
        comment: "failed_disable_audio"
    )
    
    public static let videoCallFailedDisableVideo = NSLocalizedString(
        "video_call_failed_disable_video",
        bundle: .module,
        comment: "failed_disable_video"
    )
    
    public static let videoCallFaiedKickParticipant = NSLocalizedString(
        "video_call_failed_kick_participant",
        bundle: .module,
        comment: "failed_kick_participant"
    )
    
    public static let videoCallFailedAcceptWaitlistedRequest = NSLocalizedString(
        "video_call_failed_accept_waitlisted_participant",
        bundle: .module,
        comment: "failed_accept_waitlisted"
    )
    
    public static let videoCallFailedSendMessage = NSLocalizedString(
        "video_call_failed_send_request",
        bundle: .module,
        comment: "failed_send_message"
    )
    
    public static let videoCallFailedAcceptAllRequest = NSLocalizedString(
        "video_call_failed_accept_all_waiting_request",
        bundle: .module,
        comment: "failed_accept_all_waiting_request"
    )
    
    public static let videoCallFailRequest = NSLocalizedString(
        "video_call_fail_request",
        bundle: .module,
        comment: "failed_request"
    )
    
    public static let videoCallLeaveRoom = NSLocalizedString(
        "video_call_leave_room",
        bundle: .module,
        comment: "leave_room"
    )
    
    public static let videoCallRejoin = NSLocalizedString(
        "video_call_rejoin",
        bundle: .module,
        comment: "rejoin"
    )
    
    public static let tooltipAgenda = NSLocalizedString(
        "tooltip_agenda",
        bundle: .module,
        comment: "tooltip agenda"
    )
    
    public static let videoCallDisconnected = NSLocalizedString(
        "video_call_disconnected",
        bundle: .module,
        comment: "disconnected text"
    )
    
    public static let videoCallRaiseHand = NSLocalizedString(
        "video_call_raise_hand",
        bundle: .module,
        comment: "raise hand text"
    )
    
    public static let videoCallViewerMode = NSLocalizedString(
        "video_call_viewer_mode",
        bundle: .module,
        comment: "viewer mode text"
    )
    
    public static let videoCallRateUs = NSLocalizedString(
        "vide_call_rate_us",
        bundle: .module,
        comment: "rate us"
    )
    
    public static let videoCallRateText = NSLocalizedString(
        "video_call_rate_text",
        bundle: .module,
        comment: "rate text"
    )
    
    public static let videoCallSendFeedback = NSLocalizedString(
        "video_call_send_feedback",
        bundle: .module,
        comment: "send feedback"
    )
    public static let videoCallToMain = NSLocalizedString(
        "video_call_to_main",
        bundle: .module,
        comment: "to main text"
    )
    
    public static let feedbackVeryBad = NSLocalizedString(
        "feedback_very_bad",
        bundle: .module,
        comment: "feedback very bad"
    )
    
    public static let feedbackVeryGood = NSLocalizedString(
        "feedback_very_good",
        bundle: .module,
        comment: "feedback very good"
    )
    
    public static let feedbackWeaknessTitle = NSLocalizedString(
        "feedback_weakness_title",
        bundle: .module,
        comment: "feedback weakness title"
    )
    
    public static let feedbackProblemTitle = NSLocalizedString(
        "feedback_problem_title",
        bundle: .module,
        comment: "feedback problem title"
    )
    
    public static let feedbackSuccessTitle = NSLocalizedString(
        "feedback_success_title",
        bundle: .module,
        comment: "feedback success title"
    )
    
    public static let sessionDetailrateForCreator = NSLocalizedString(
        "session_detail_rate_for_creator",
        bundle: .module,
        comment: "rate for creator"
    )
    public static let sessionDetailRatingTooltip = NSLocalizedString(
        "session_detail_rating_tooltip",
        bundle: .module,
        comment: "rating tooltip text"
    )
    public static let videoCallRaisedToast = NSLocalizedString(
        "video_call_raised_toast",
        bundle: .module,
        comment: "raised toast text"
    )
    public static let videoCallUnraisedToast = NSLocalizedString(
        "video_call_unraised_toast",
        bundle: .module,
        comment: "raised toast text"
    )
    public static let videoCallEndSessionPopupTitle = NSLocalizedString(
        "video_call_end_session_popup_title",
        bundle: .module,
        comment: "End this session?"
    )
    public static let videoCallLeavePopupTitle = NSLocalizedString(
        "video_call_leave_popup_title",
        bundle: .module,
        comment: "Leave the session?"
    )
    public static let videoCallEndSessionPopupSubtitle = NSLocalizedString(
        "video_call_end_session_popup_subtitle",
        bundle: .module,
        comment: "Are you sure want to end this session?"
    )
    public static let videoCallLeavePopupSubtitle = NSLocalizedString(
        "video_call_leave_popup_subtitle",
        bundle: .module,
        comment: "If the session has not ended, you can rejoin to this session"
    )
    public static let videoCallEndSessionButton = NSLocalizedString(
        "video_call_end_session_button",
        bundle: .module,
        comment: "end session"
    )
    public static let videoCallKickedAlertTitle = NSLocalizedString(
        "video_call_kicked_alert_title",
        bundle: .module,
        comment: "video call kicked alert title"
    )
    
    public static let videoCallMoveToViewerAlertTitle = NSLocalizedString(
        "video_call_move_to_viewer_alert_title",
        bundle: .module,
        comment: "video call move to viewer alert title"
    )
    public static let videoCallViewerModeLabel = NSLocalizedString(
        "video_call_viewer_mode_label",
        bundle: .module,
        comment: "video call viewer mode label"
    )
    
    public static func videoCallViewerModeGuide() -> String {
        String(
            format: NSLocalizedString(
                "video_call_viewer_mode_guide",
                bundle: .module,
                comment: "video call viewer mode guide"
            )
        )
    }
    
    public static let videoCallRaiseHandGuide = NSLocalizedString(
        "video_call_raise_hand_guide",
        bundle: .module,
        comment: "video call raise hand guide"
    )
    public static let videoCallInteractionGuide = NSLocalizedString(
        "video_call_interaction_guide",
        bundle: .module,
        comment: "video call interaction guide"
    )
    public static let okayWithDotLabel = NSLocalizedString(
        "okay_with_dot_label",
        bundle: .module,
        comment: "okay with dot label"
    )
    public static let showMeLabel = NSLocalizedString(
        "show_me_label",
        bundle: .module,
        comment: "show me label"
    )
    public static let tabExplore = NSLocalizedString(
        "tab_explore",
        bundle: .module,
        comment: "tab explore in home"
    )
    public static let tabSearch = NSLocalizedString(
        "tab_search",
        bundle: .module,
        comment: "tab search in home"
    )
    public static let tabAgenda = NSLocalizedString(
        "tab_agenda",
        bundle: .module,
        comment: "tab agenda in home"
    )
    public static let videoCallMeetingForceEnd = NSLocalizedString(
        "video_call_force_end",
        bundle: .module,
        comment: "force ended"
    )
    public static let homeCreatorWithdraw = NSLocalizedString(
        "home_creator_withdraw",
        bundle: .module,
        comment: "withdraw"
    )
    public static let creatorEmptySessionTitle = NSLocalizedString(
        "creator_empty_session_title",
        bundle: .module,
        comment: "creator empty session title"
    )
    public static let creatorEmptySessionDesc = NSLocalizedString(
        "creator_empty_session_desc",
        bundle: .module,
        comment: "creator empty session description"
    )
    public static let filterScheduled = NSLocalizedString(
        "filter_scheduled",
        bundle: .module,
        comment: "filter scheduled"
    )
    public static let filterUnconfirmed = NSLocalizedString(
        "filter_unconfirmed",
        bundle: .module,
        comment: "filter not confirmed"
    )
    public static let filterPending = NSLocalizedString(
        "filter_pending",
        bundle: .module,
        comment: "filter pending"
    )
    public static let filterCanceled = NSLocalizedString(
        "filter_canceled",
        bundle: .module,
        comment: "filter canceled"
    )
    public static let filterSessionCompleted = NSLocalizedString(
        "filter_session_completed",
        bundle: .module,
        comment: "filter session completed"
    )
    public static let sortLabel = NSLocalizedString(
        "sort_label",
        bundle: .module,
        comment: "sort label"
    )
    
    public static let sortByLabel = NSLocalizedString(
        "sort_by_label",
        bundle: .module,
        comment: "sort by label"
    )
    
    public static let sortLatest = NSLocalizedString(
        "sort_latest",
        bundle: .module,
        comment: "sort latest"
    )
    public static let sortEarliest = NSLocalizedString(
        "sort_earliest",
        bundle: .module,
        comment: "sort earliest"
    )
    public static let statusWaitingNewSession = NSLocalizedString(
        "status_waiting_new_session",
        bundle: .module,
        comment: "status waiting new session"
    )
    public static let statusUnconfirmedSession = NSLocalizedString(
        "status_unconfirmed_session",
        bundle: .module,
        comment: "status unconfirmed session"
    )
    public static let statusCanceledSession = NSLocalizedString(
        "status_canceled_session",
        bundle: .module,
        comment: "status canceled session"
    )
    public static let statusCompletedSession = NSLocalizedString(
        "status_completed_session",
        bundle: .module,
        comment: "status completed session"
    )
    public static let creatorCreateSessionLabel = NSLocalizedString(
        "creator_create_session_label",
        bundle: .module,
        comment: "creator create session label"
    )
    
    public static let homeCreatorNearestTitle = NSLocalizedString(
        "home_creator_nearest_title",
        bundle: .module,
        comment: "nearest schedule title"
    )
    
    public static let requestCardSessionText = NSLocalizedString(
        "request_card_session",
        bundle: .module,
        comment: "session"
    )
    
    public static let withdrawSuccessSubtitle = NSLocalizedString(
        "withdraw_success_subtitle",
        bundle: .module,
        comment: "success subtitle"
    )
    public static let tippingGiftTitle = NSLocalizedString(
        "tipping_gift_title",
        bundle: .module,
        comment: "give gift to creator title"
    )
    public static let tippingYourBalance = NSLocalizedString(
        "tipping_your_balance",
        bundle: .module,
        comment: "your balance text"
    )
    public static let tippingTopUpNow = NSLocalizedString(
        "tipping_top_up_now",
        bundle: .module,
        comment: "top up now text"
    )
    public static let tippingNotEnoughBalance = NSLocalizedString(
        "tipping_not_enough_balance",
        bundle: .module,
        comment: "not enough balance error when tipping"
    )
    public static let tippingYourCurrentCoin = NSLocalizedString(
        "tipping_your_current_coin",
        bundle: .module,
        comment: "your current coin text on add coin bottom sheet"
    )
    public static let tippingSuccessDesc = NSLocalizedString(
        "tipping_success_desc",
        bundle: .module,
        comment: "tipping success description"
    )
    public static let ratecardRequestedTime = NSLocalizedString(
        "ratecard_requested_time",
        bundle: .module,
        comment: "requested time text"
    )
    
    public static let editProfileNameEmptyError = NSLocalizedString(
        "edit_profile_name_empty_error",
        bundle: .module,
        comment: "empty error for name field"
    )
    public static let editProfileUsernameEmptyError = NSLocalizedString(
        "edit_profile_username_empty_error",
        bundle: .module,
        comment: "error empty for username field"
    )
    public static let editProfileBioEmptyError = NSLocalizedString(
        "edit_profile_bio_empty_error",
        bundle: .module,
        comment: "bio empty error"
    )
    public static let editProfileProfessionEmptyError = NSLocalizedString(
        "edit_profile_profession_empty_error",
        bundle: .module,
        comment: "profession empty error"
    )
    public static let ratecardRequestExplanation = NSLocalizedString(
        "ratecard_request_explanation",
        bundle: .module,
        comment: "explanation for reqested time in rate card"
    )
    public static let anytimeLabel = NSLocalizedString(
        "anytime_label",
        bundle: .module,
        comment: "anytime label"
    )
    
    public static let giftLabel = NSLocalizedString(
        "gift_label",
        bundle: .module,
        comment: "gift label"
    )
    public static let reviewSuccessWithTipDesc = NSLocalizedString(
        "review_success_with_tip_desc",
        bundle: .module,
        comment: "review success with tip description"
    )
    public static let createSessionMinimumParticipantAlert = NSLocalizedString(
        "create_session_minimum_participant_alert",
        bundle: .module,
        comment: "create session minimum participant alert"
    )
    
    public static let pendingCardSetTime = NSLocalizedString(
        "pending_card_set_time",
        bundle: .module,
        comment: "set time"
    )
    public static let creatorConfirmationStatus = NSLocalizedString(
        "creator_confirmation_status",
        bundle: .module,
        comment: "Waiting confirmation from Creator"
    )
    public static let creatorNotSetScheduleStatus = NSLocalizedString(
        "creator_not_set_schedule_status",
        bundle: .module,
        comment: "Schedule didn't set"
    )
    public static let creatorScheduledStatus = NSLocalizedString(
        "creator_scheduled_status",
        bundle: .module,
        comment: "Session already scheduled"
    )
    public static let creatorCancelledStatus = NSLocalizedString(
        "creator_canceled_status",
        bundle: .module,
        comment: "Session cancelled by Creator"
    )
    public static let refundStatus = NSLocalizedString(
        "refund_status",
        bundle: .module,
        comment: "refund status"
    )
    public static let alreadyRefund = NSLocalizedString(
        "already_refund",
        bundle: .module,
        comment: "already refund"
    )
    public static let creatorInboxTitle = NSLocalizedString(
        "creator_inbox_title",
        bundle: .module,
        comment: "title in inbox view"
    )
    public static let inboxDiscussScheduleTitle = NSLocalizedString(
        "inbox_discuss_schedule_title",
        bundle: .module,
        comment: "title of schedule discussion section in inbox view"
    )
    public static let inboxDiscussScheduleDesc = NSLocalizedString(
        "inbox_discuss_schedule_desc",
        bundle: .module,
        comment: "description of schedule discussion section in inbox view"
    )
    public static let inboxCompletedSessionDesc = NSLocalizedString(
        "inbox_completed_session_desc",
        bundle: .module,
        comment: "description of completed session section in inbox view"
    )
    public static let inboxReviewDesc = NSLocalizedString(
        "inbox_review_desc",
        bundle: .module,
        comment: "description of completed session section in inbox view"
    )
    public static let discussionTagUnread = NSLocalizedString(
        "discussion_tag_unread",
        bundle: .module,
        comment: "unread tag in discussion list"
    )
    public static let discussionTagNearestSchedule = NSLocalizedString(
        "discussion_tag_nearest_schedule",
        bundle: .module,
        comment: "nearest schedule tag in discussion list"
    )
    public static func discussionStatusCancelWithin(date: String) -> String {
        String(
            format: NSLocalizedString(
                "discussion_status_cancel_within",
                bundle: .module,
                comment: "not confirmed schedule status in discussion list"
            ),
            date
        )
    }
    public static let discussionStatusScheduledSession = NSLocalizedString(
        "discussion_status_scheduled_session",
        bundle: .module,
        comment: "scheduled session status in discussion list"
    )
    public static let dayText = NSLocalizedString(
        "day_text",
        bundle: .module,
        comment: "day text"
    )
    public static let hourText = NSLocalizedString(
        "hour_text",
        bundle: .module,
        comment: "hour text"
    )
    
    public static func chatBookedSession(title: String) -> String {
        String(
            format: NSLocalizedString(
                "booked_session_chat",
                bundle: .module,
                comment: "booked session : "
            ),
            title
        )
    }
    
    public static let chatDisabledText = NSLocalizedString(
        "chat_disabled_text",
        bundle: .module,
        comment: "chat disabled explanation"
    )
    public static let today = NSLocalizedString(
        "today",
        bundle: .module,
        comment: "today"
    )
    public static let yesterday = NSLocalizedString(
        "yesterday",
        bundle: .module,
        comment: "yesterday"
    )
    
    public static let reviewFilterHighestStar = NSLocalizedString(
        "review_filter_highest_star",
        bundle: .module,
        comment: "highest star filter in review list"
    )
    public static let reviewFilterLowestStar = NSLocalizedString(
        "review_filter_lowest_star",
        bundle: .module,
        comment: "lowest star filter in review list"
    )
    public static let discussionSearchPlaceholder = NSLocalizedString(
        "discussion_search_placeholder",
        bundle: .module,
        comment: "discussion list search placeholder"
    )
    public static let discussionSearchCreatorName = NSLocalizedString(
        "discussion_search_creator_name",
        bundle: .module,
        comment: "discussion list search creator name"
    )
    public static let discussionSearchAudienceName = NSLocalizedString(
        "discussion_search_audience_name",
        bundle: .module,
        comment: "discussion list search audience name"
    )
    public static let discussionSearchNotFound = NSLocalizedString(
        "discussion_search_not_found",
        bundle: .module,
        comment: "discussion list search not found"
    )
    public static let discussWithCreatorTitle = NSLocalizedString(
        "discuss_with_creator",
        bundle: .module,
        comment: "discuss with creator"
    )
    public static let discussWithAudienceTitle = NSLocalizedString(
        "discuss_with_audience",
        bundle: .module,
        comment: "discuss with audience"
    )
    
    public static let generalCloseDetails = NSLocalizedString(
        "general_close_details",
        bundle: .module,
        comment: "close details"
    )
    public static let manageAppUsageCostsTitle = NSLocalizedString(
        "manage_application_usage_costs",
        bundle: .module,
        comment: "manage application usage costs"
    )
    public static func costCalculatedSubtitle(fee: String) -> String {
        String(
            format: NSLocalizedString(
                "cost_calculated_subtitle",
                bundle: .module,
                comment: "cost calculated subtitle"
            ),
            fee
        )
    }
    public static let percentageBorneByAudience = NSLocalizedString(
        "percentage_borne_by_audience",
        bundle: .module,
        comment: "percentage borne"
    )
    public static let estimatedAppUsageCosts = NSLocalizedString(
        "estimated_app_usage_cost",
        bundle: .module,
        comment: "estimated app usage costs"
    )
    
    public static func audienceCountLabel(count: Int) -> String {
        String(
            format: NSLocalizedString(
                "audience_count",
                bundle: .module,
                comment: "audience count with label"
            ), 
            count
        )
    }
    public static func totalBorneByAudience(borne: String) -> String {
        String(
            format: NSLocalizedString(
                "total_borne_by_audience",
                bundle: .module,
                comment: "total borne"
            ),
            borne
        )
    }
    public static func totalBorneSubtitle(total: String) -> String {
        String(
            format: NSLocalizedString(
                "total_borne_subtitle",
                bundle: .module,
                comment: "total borne subtitle"
            ),
            total
        )
    }
    public static func totalCostsBorneByCreator(total: String) -> String {
        String(
            format: NSLocalizedString(
                "total_cost_borne",
                bundle: .module,
                comment: "total cost borne by the creator"
            ),
            total
        )
    }
    public static func appUsageCostCalculationTooltip(fee: String, minute: String, total: String) -> String {
        String(
            format: NSLocalizedString(
                "app_usage_cost_calculation_tooltip",
                bundle: .module,
                comment: "cost calculation tooltip text"
            ),
            fee,
            minute,
            total
        )
    }
    public static let appUsageCostsSliderTooltip = NSLocalizedString(
        "app_costs_slider_tooltip",
        bundle: .module,
        comment: "app usage costs slider tooltip text"
    )
    public static let inboxEmptyDescription = NSLocalizedString(
        "inbox_empty_description",
        bundle: .module,
        comment: "empty inbox description"
    )
    public static let reviewEmptyDescription = NSLocalizedString(
        "review_empty_description",
        bundle: .module,
        comment: "empty review description"
    )
    
    public static let scheduleFormSetParticipant = NSLocalizedString(
        "schedule_form_set_participant",
        bundle: .module,
        comment: "set participant on schedule form"
    )
    public static let scheduleFormSetPrice = NSLocalizedString(
        "schedule_form_set_price",
        bundle: .module,
        comment: "set price"
    )
    public static let scheduleFormPerPerson = NSLocalizedString(
        "schedule_form_per_person",
        bundle: .module,
        comment: "per person"
    )
    public static let scheduleFormPricePlaceholder = NSLocalizedString(
        "schedule_form_enter_price_label",
        bundle: .module,
        comment: "price placeholder"
    )
    
    public static let scheduleFormPriceSettingsTitle = NSLocalizedString(
        "price_settings_title",
        bundle: .module,
        comment: "price settings"
    )
    public static let scheduleFormApplicationCostTransfer = NSLocalizedString(
        "application_costs_transfer",
        bundle: .module,
        comment: "application cost transfer"
    )
    public static let scheduleFormSetAppUsageCost = NSLocalizedString(
        "set_app_usage_cost",
        bundle: .module,
        comment: "set app usage cost"
    )
    public static let scheduleFormSetAppUsageWarning = NSLocalizedString(
        "set_app_usage_warning",
        bundle: .module,
        comment: "set app usage warning if price not set"
    )
    public static let scheduleFormSetAppUsageRule = NSLocalizedString(
        "set_app_usage_rule",
        bundle: .module,
        comment: "set app usage rule"
    )
    
    public static let scheduleFormPriceSummary = NSLocalizedString(
        "summary_session_price",
        bundle: .module,
        comment: "price summary"
    )
    
    public static let scheduleFormSessionPriceTitle = NSLocalizedString(
        "session_price_title",
        bundle: .module,
        comment: "session price"
    )
    
    public static let scheduleFormAudienceQuota = NSLocalizedString(
        "audience_quota",
        bundle: .module,
        comment: "audience quota"
    )
    
    public static let scheduleFormCreatorSponsoredCosts = NSLocalizedString(
        "app_usage_borne_by_creator",
        bundle: .module,
        comment: "sponsored cost by creator"
    )
    
    public static let scheduleFormRevenueEstimation = NSLocalizedString(
        "revenue_estimation",
        bundle: .module,
        comment: "revenue estimation"
    )
    
    public static func scheduleFormCoverPercentage(total: String) -> String {
        String(
            format: NSLocalizedString(
                "app_cost_cover_percentage",
                bundle: .module,
                comment: "percentage covered"
            ),
            total
        )
    }
    
    public static let scheduleFormSessionSettingsTitle = NSLocalizedString(
        "session_settings_title",
        bundle: .module,
        comment: "session settings"
    )
    
    public static let scheduleFormTitleDescriptionEmptyError = NSLocalizedString(
        "title_description_empty_error",
        bundle: .module,
        comment: "empty title n desc error"
    )
    
    public static let scheduleFormEnableVideoArchieveTitle = NSLocalizedString(
        "activation_of_archieve_title",
        bundle: .module,
        comment: "enable archieve title"
    )
    
    public static let scheduleFormEnableVideoArchieveSubtitle = NSLocalizedString(
        "activation_of_archieve_subtitle",
        bundle: .module,
        comment: "enable archieve subtitle"
    )
    public static let profileAvailabilityLabel = NSLocalizedString(
        "profile_availability_label",
        bundle: .module,
        comment: "profile availability label"
    )
    public static let profileSetSubscriptionTitle = NSLocalizedString(
        "profile_set_subscription_title",
        bundle: .module,
        comment: "profile set subscription title"
    )
    public static let profileSetSubscriptionDesc = NSLocalizedString(
        "profile_set_subscription_desc",
        bundle: .module,
        comment: "profile set subscription description"
    )
    public static let profileSetCostTitle = NSLocalizedString(
        "profile_set_cost_title",
        bundle: .module,
        comment: "profil set cost title"
    )
    public static let profileSetCostDesc = NSLocalizedString(
        "profile_set_cost_desc",
        bundle: .module,
        comment: "profil set cost description"
    )
    public static let profileActivateSubscriptionTitle = NSLocalizedString(
        "profile_activate_subscription_title",
        bundle: .module,
        comment: "profile activate subscription title"
    )
    public static let profileSelectSubscriptionTypeTitle = NSLocalizedString(
        "profile_select_subscription_type_title",
        bundle: .module,
        comment: "profile select subscription type title"
    )
    public static let profileSelectSubscriptionTypePlaceholder = NSLocalizedString(
        "profile_select_subscription_type_placeholder",
        bundle: .module,
        comment: "profile select subscription type placeholder"
    )
    public static let subscriptionPaidMonthly = NSLocalizedString(
        "subscription_paid_monthly",
        bundle: .module,
        comment: "subscription paid monthly"
    )
    public static let subscriptionPaidFree = NSLocalizedString(
        "subscription_paid_free",
        bundle: .module,
        comment: "subscription paid free"
    )
    public static let monthLabel = NSLocalizedString(
        "month_label",
        bundle: .module,
        comment: "month label"
    )
    public static let archiveChooseVideo = NSLocalizedString(
        "archive_choose_video",
        bundle: .module,
        comment: "archive choose video"
    )
    public static let archiveChooseAudience = NSLocalizedString(
        "archive_choose_audience",
        bundle: .module,
        comment: "archive choose audience"
    )
    public static let archiveVideoTitle = NSLocalizedString(
        "archive_video_title",
        bundle: .module,
        comment: "archive video title"
    )
    public static let archiveVideoDesc = NSLocalizedString(
        "archive_video_desc",
        bundle: .module,
        comment: "archive video desc"
    )
    public static let goToArchiveLabel = NSLocalizedString(
        "go_to_archive_label",
        bundle: .module,
        comment: "go to archive label"
    )
    public static let goToUploadLabel = NSLocalizedString(
        "go_to_upload_label",
        bundle: .module,
        comment: "go to upload label"
    )
    public static let archivePublicDesc = NSLocalizedString(
        "archive_public_desc",
        bundle: .module,
        comment: "archive public desc"
    )
    public static let archiveSubscriberDesc = NSLocalizedString(
        "archive_subscriber_desc",
        bundle: .module,
        comment: "archive subscriber desc"
    )
    public static let publicLabel = NSLocalizedString(
        "public_label",
        bundle: .module,
        comment: "public label"
    )
    public static let subscriberLabel = NSLocalizedString(
        "subscriber_label",
        bundle: .module,
        comment: "subscriber label"
    )
    public static let archiveLabel = NSLocalizedString(
        "archive_label",
        bundle: .module,
        comment: "archive label"
    )
    public static let uploadLabel = NSLocalizedString(
        "upload_label",
        bundle: .module,
        comment: "upload label"
    )
    public static let titleLabel = NSLocalizedString(
        "title_label",
        bundle: .module,
        comment: "title label"
    )
    public static let descriptionLabel = NSLocalizedString(
        "description_label",
        bundle: .module,
        comment: "description label"
    )
    public static let editCoverLabel = NSLocalizedString(
        "edit_cover_label",
        bundle: .module,
        comment: "edit cover label"
    )
    public static let seeSessionRecordingLabel = NSLocalizedString(
        "see_session_recording_label",
        bundle: .module,
        comment: "see session recording label"
    )
    public static let downloadingLabel = NSLocalizedString(
        "downloading_label",
        bundle: .module,
        comment: "downloading label"
    )
    public static let emptyRecordingDesc = NSLocalizedString(
        "empty_recording_desc",
        bundle: .module,
        comment: "empty recording desc"
    )
    public static let creatorStudioLabel = NSLocalizedString(
        "creator_studio_label",
        bundle: .module,
        comment: "creator studio label"
    )
    public static let recordedLabel = NSLocalizedString(
        "recorded_label",
        bundle: .module,
        comment: "recorded label"
    )
    public static let uploadContentLabel = NSLocalizedString(
        "upload_content_label",
        bundle: .module,
        comment: "upload content label"
    )
    public static let popularLabel = NSLocalizedString(
        "popular_label",
        bundle: .module,
        comment: "popular label"
    )
    public static let deleteLabel = NSLocalizedString(
        "delete_label",
        bundle: .module,
        comment: "delete label"
    )
    public static let downloadLabel = NSLocalizedString(
        "download_label",
        bundle: .module,
        comment: "download label"
    )
    public static let postLabel = NSLocalizedString(
        "post_label",
        bundle: .module,
        comment: "post label"
    )
    public static let uploadingLabel = NSLocalizedString(
        "uploading_label",
        bundle: .module,
        comment: "uploading label"
    )
    public static let tryAgainLabel = NSLocalizedString(
        "try_again_label",
        bundle: .module,
        comment: "try again label"
    )
    public static let uploadFailedTitle = NSLocalizedString(
        "upload_failed_title",
        bundle: .module,
        comment: "upload failed title"
    )
    public static let cancelUploadLabel = NSLocalizedString(
        "cancel_upload_label",
        bundle: .module,
        comment: "cancel upload title"
    )
    public static let generalContinueLabel = NSLocalizedString(
        "general_continue_label",
        bundle: .module,
        comment: "general continue label"
    )
    public static let uploadVideoLabel = NSLocalizedString(
        "upload_video_label",
        bundle: .module,
        comment: "upload video label"
    )
    public static let subscribeLabel = NSLocalizedString(
        "subscribe_label",
        bundle: .module,
        comment: "subscribe label"
    )
    public static let commentLabel = NSLocalizedString(
        "comment_label",
        bundle: .module,
        comment: "comment label"
    )
    public static let detailVideoUpcomingSessionDesc = NSLocalizedString(
        "detail_video_upcoming_session_desc",
        bundle: .module,
        comment: "detail video upcoming session desc"
    )
    public static let groupVideoCallLabel = NSLocalizedString(
        "group_video_call_label",
        bundle: .module,
        comment: "group video call label"
    )
    
    public static let scheduleFormMinusTotalRevenueWarning = NSLocalizedString(
        "minus_total_revenue_warning",
        bundle: .module,
        comment: "minus total revenue warning on schedule form"
    )
    
    public static let creatorStudioDeleteVideoAlertTitle = NSLocalizedString(
        "delete_video_alert_title",
        bundle: .module,
        comment: "alert title for creator studio"
    )
    
    public static let creatorStudioDeleteVideoAlertContent = NSLocalizedString(
        "delete_video_alert_content",
        bundle: .module,
        comment: "alert content for creator studio"
    )
    public static let subscirbeCardTitle = NSLocalizedString(
        "subscirbe_card_title",
        bundle: .module,
        comment: "subscirbe card title"
    )
    public static let subscirbeCardDesc = NSLocalizedString(
        "subscirbe_card_desc",
        bundle: .module,
        comment: "subscirbe card desc"
    )
    public static let subscirbeCancelDesc = NSLocalizedString(
        "subscirbe_cancel_desc",
        bundle: .module,
        comment: "subscirbe cancel desc"
    )
    public static let adaptiveSubscribtionLabel = NSLocalizedString(
        "adaptive_subscribtion_label",
        bundle: .module,
        comment: "adaptive subscribtion label"
    )
    public static let subscribeNowLabel = NSLocalizedString(
        "subscribe_now_label",
        bundle: .module,
        comment: "subscribe now label"
    )
    public static let forOneMonthLabel = NSLocalizedString(
        "for_one_month_label",
        bundle: .module,
        comment: "for one month label"
    )
    public static let subscribeAlertTitle = NSLocalizedString(
        "subscribe_alert_title",
        bundle: .module,
        comment: "subscribe alert title"
    )
    public static let subscribeAlertDesc = NSLocalizedString(
        "subscribe_alert_desc",
        bundle: .module,
        comment: "subscribe alert description"
    )
    public static let requestPrivateLabel = NSLocalizedString(
        "request_private_label",
        bundle: .module,
        comment: "request private label"
    )
    public static let requestPrivateDesc = NSLocalizedString(
        "request_private_desc",
        bundle: .module,
        comment: "request private desc"
    )
    public static let requestRatecardLabel = NSLocalizedString(
        "request_ratecard_label",
        bundle: .module,
        comment: "request ratecard label"
    )
    public static let overviewLabel = NSLocalizedString(
        "overview_label",
        bundle: .module,
        comment: "overview label"
    )
    public static let publicSessionLabel = NSLocalizedString(
        "public_session_label",
        bundle: .module,
        comment: "public session label"
    )
    public static let exclusiveVideoLabel = NSLocalizedString(
        "exclusive_video_label",
        bundle: .module,
        comment: "exclusive video label"
    )
    public static let scheduleFilterLabel = NSLocalizedString(
        "schedule_filter_label",
        bundle: .module,
        comment: "schedule filter label"
    )
    public static let sessionEmptyTitle = NSLocalizedString(
        "session_empty_title",
        bundle: .module,
        comment: "session empty title"
    )
    public static let emptyUploadDesc = NSLocalizedString(
        "empty_upload_desc",
        bundle: .module,
        comment: "empty upload desc"
    )
    public static let sessionTypeLabel = NSLocalizedString(
        "session_type_label",
        bundle: .module,
        comment: "session type label"
    )
    public static let messageLabel = NSLocalizedString(
        "message_label",
        bundle: .module,
        comment: "message label"
    )
    public static let defaultPlaceholder = NSLocalizedString(
        "default_placeholder",
        bundle: .module,
        comment: "default placeholder"
    )
    public static let sendRequestLabel = NSLocalizedString(
        "send_request_label",
        bundle: .module,
        comment: "send request label"
    )
    
    public static func sessionEmptyDesc(name: String) -> String {
        String(
            format: NSLocalizedString(
                "session_empty_desc",
                bundle: .module,
                comment: "session empty desc"
            ),
            name
        )
    }
    
    public static let detailVideoCommentPlaceholder = NSLocalizedString(
        "detail_video_comment_placeholder",
        bundle: .module,
        comment: "comment placeholder"
    )
    public static let talentDetailAboutUs = NSLocalizedString(
        "talent_detail_about_us",
        bundle: .module,
        comment: "talent detail about us label"
    )
    public static let managementCreatorLabel = NSLocalizedString(
        "management_creator_label",
        bundle: .module,
        comment: "management creator label"
    )
    public static let managementProfileLabel = NSLocalizedString(
        "management_profile_label",
        bundle: .module,
        comment: "management profile label"
    )
    
    public static let creatorStudioEmptyArchive = NSLocalizedString(
        "creator_studio_empty_archive",
        bundle: .module,
        comment: "empty text for archive general"
    )
    public static let creatorStudioEmptyUpload = NSLocalizedString(
        "creator_studio_empty_upload",
        bundle: .module,
        comment: "empty text for upload general"
    )
    public static let creatorStudioArchiveTitlePlaceholder = NSLocalizedString(
        "creator_studio_archive_title_placeholder",
        bundle: .module,
        comment: "title of archive placeholder"
    )
    public static let creatorStudioArchiveDescPlaceholder = NSLocalizedString(
        "creator_studio_archive_desc_placeholder",
        bundle: .module,
        comment: "desc of archive placeholder"
    )
    
    public static let creatorAvailabilitySuccessText = NSLocalizedString(
        "creator_availability_success_text",
        bundle: .module,
        comment: "success text when edit availability"
    )
    
    public static let subscribedLabel = NSLocalizedString(
        "subscribed_label",
        bundle: .module,
        comment: "subscribed"
    )
    public static let yesCancelLabel = NSLocalizedString(
        "yes_cancel_label",
        bundle: .module,
        comment: "yes cancel label"
    )
    public static let noLabel = NSLocalizedString(
        "no_label",
        bundle: .module,
        comment: "no label"
    )
    public static let unsubscribeAlertTitle = NSLocalizedString(
        "unsubscribe_alert_title",
        bundle: .module,
        comment: "unsubscribe alert title"
    )
    public static let followLabel = NSLocalizedString(
        "follow_label",
        bundle: .module,
        comment: "follow label"
    )
    public static let unfollowLabel = NSLocalizedString(
        "unfollow_label",
        bundle: .module,
        comment: "unfollow label"
    )
    public static let unsubscribeLabel = NSLocalizedString(
        "unsubscribe_label",
        bundle: .module,
        comment: "unsubscribe label"
    )
    
    public static func unsubscribeAlertDesc(name: String) -> String {
        String(
            format: NSLocalizedString(
                "unsubscribe_alert_desc",
                bundle: .module,
                comment: "unsubscribe alert description"
            ),
            name
        )
    }
    
    public static let subscriptionCardTitle = NSLocalizedString(
        "subscription_card_title",
        bundle: .module,
        comment: "subscription card title"
    )
    public static let subscriptionCancelDesc = NSLocalizedString(
        "subscription_cancel_desc",
        bundle: .module,
        comment: "subscription cancel description"
    )
    public static let cancelSubscriptionLabel = NSLocalizedString(
        "cancel_subscription_label",
        bundle: .module,
        comment: "cancel subscription label"
    )
    public static let subscriptionSuccessLabel = NSLocalizedString(
        "subscription_success_label",
        bundle: .module,
        comment: "subscription success label"
    )
    public static let creatorNameLabel = NSLocalizedString(
        "creator_name_label",
        bundle: .module,
        comment: "creator name label"
    )
    public static let durationLabel = NSLocalizedString(
        "duration_label",
        bundle: .module,
        comment: "duration label"
    )
    public static let dinotisCoinLabel = NSLocalizedString(
        "dinotis_coin",
        bundle: .module,
        comment: "dinotis coin label"
    )
    public static let subscriptionLabel = NSLocalizedString(
        "subscription_label",
        bundle: .module,
        comment: "subscription label"
    )
    public static let freeSubscriptionLabel = NSLocalizedString(
        "free_subscription_label",
        bundle: .module,
        comment: "free subscription label"
    )
    public static let premiumSubscriptionLabel = NSLocalizedString(
        "premium_subscription_label",
        bundle: .module,
        comment: "premium subscription label"
    )
    public static let adaptiveLabel = NSLocalizedString(
        "adaptive_label",
        bundle: .module,
        comment: "adaptive label"
    )
    
    public static func subscriptionExpiredRemaining(dayCount: Int) -> String {
        return String(
            format: NSLocalizedString(
                "subscription_expired_remaining",
                bundle: .module,
                comment: "subscription expired remaining"
            ),
            dayCount
        )
    }
    
    public static func subscriptionEndTimeAt(date: String) -> String {
        return String(
            format: NSLocalizedString(
                "subscription_end_time_at",
                bundle: .module,
                comment: "subscription end time at"
            ),
            date
        )
    }
    public static let revenueDetailText = NSLocalizedString(
        "revenue_detail_text",
        bundle: .module,
        comment: ""
    )
    
    public static let totalIncomeText = NSLocalizedString(
        "total_income_text",
        bundle: .module,
        comment: ""
    )
    
    public static let incomeDetailText = NSLocalizedString(
        "income_detail_text",
        bundle: .module,
        comment: ""
    )
    
    public static let totalAudienceText = NSLocalizedString(
        "total_audience_text",
        bundle: .module,
        comment: ""
    )
    
    public static let visibilityCollaboratorText = NSLocalizedString(
        "visibilty_collaborator_text",
        bundle: .module,
        comment: ""
    )
    
    public static let collaboratorText = NSLocalizedString(
        "collaborator_text",
        bundle: .module,
        comment: ""
    )
    
    public static let videoCallPollingPromotion = NSLocalizedString(
        "video_call_polling_promotion",
        bundle: .module,
        comment: ""
    )
    public static let videoCallEmptyPollingDesc = NSLocalizedString(
        "video_call_empty_polling_desc",
        bundle: .module,
        comment: "video call empty polling description"
    )
    public static let morePollingLabel = NSLocalizedString(
        "more_polling_label",
        bundle: .module,
        comment: "more polling label"
    )
    public static let pollLabel = NSLocalizedString(
        "poll_label",
        bundle: .module,
        comment: "poll label"
    )
    public static let resultLabel = NSLocalizedString(
        "result_label",
        bundle: .module,
        comment: "result label"
    )
    public static let createSessionDescriptionPlaceholder = NSLocalizedString(
        "create_session_description_placeholder",
        bundle: .module,
        comment: "create session description placeholder"
    )
    
    public static let groupVideoCallDuplicateAlert = NSLocalizedString(
        "group_video_call_duplicate_alert",
        bundle: .module,
        comment: "duplicate content"
    )
    public static let groupVideoCallDisconnectNow = NSLocalizedString(
        "group_video_call_disconnect_now",
        bundle: .module,
        comment: "disconnect now"
    )
    
    public static let profileCreatorMyAccountTitle = NSLocalizedString(
        "profile_creator_title",
        bundle: .module,
        comment: "My Account"
    )
    public static let profileCreatorAnalytics = NSLocalizedString(
        "profile_creator_analytics",
        bundle: .module,
        comment: "creator analytics"
    )
}
