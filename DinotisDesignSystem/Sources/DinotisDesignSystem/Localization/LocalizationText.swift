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
}


