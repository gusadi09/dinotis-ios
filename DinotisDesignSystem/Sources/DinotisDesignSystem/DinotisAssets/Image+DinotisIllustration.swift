//
//  Image+DinotisIllustration.swift
//  
//
//  Created by Gus Adi on 01/12/22.
//

import SwiftUI

public extension Image {
    static let generalDinotisImage = Image("img-dinotis-general", bundle: Bundle.module)
    static let generalEmptyImage = Image("img-empty-general", bundle: Bundle.module)
    
    static let onboardingSlide1Image = Image("img-slide1-onboarding", bundle: Bundle.module)
    static let onboardingSlide2Image = Image("img-slide2-onboarding", bundle: Bundle.module)
    
    static let loginAudienceImage = Image("img-audience-login", bundle: Bundle.module)
    static let loginCreatorImage = Image("img-creator-login", bundle: Bundle.module)
	static let loginRunningTextImage = Image("img-runningText-login", bundle: .module)
    
    static let searchNotFoundImage = Image("img-not-found-search", bundle: Bundle.module)
    
    static let scheduleEmptyImage = Image("img-empty-schedule", bundle: Bundle.module)
    
    static let notificationEmptyImage = Image("img-empty-notification", bundle: Bundle.module)
    
    static let coinNoTransactionImage = Image("img-no-transaction-coin", bundle: Bundle.module)
    
    static let paymentCancelImage = Image("img-cancel-payment", bundle: Bundle.module)
    static let paymentSuccessImage = Image("img-success-payment", bundle: Bundle.module)
	static let paymentFailed = Image("img-failed-payment", bundle: Bundle.module)
    
    static let talentProfileComingSoonImage = Image("img-coming-soon-talent-profile", bundle: Bundle.module)
    static let talentProfileNoServiceImage = Image("img-no-service-talent-profile", bundle: Bundle.module)
    static let talentProfileEmptyGallery = Image("img-empty-gallery", bundle: .module)
	static let talentProfileEmptyVideo = Image("img-empty-video", bundle: .module)
    
    static let profileLogoutImage = Image("img-logout-profile", bundle: Bundle.module)
    
    static let videoCallBackgroundPattern = Image("video-call-pattern", bundle: .module)
    
    static let versionUpdateImage = Image("img-update-version", bundle: .module)
    
    static let feedbackSuccessImage = Image("img-success-feedback", bundle: .module)
    static let feedbackSmileImage = Image("smile-feedback-illustration", bundle: .module)
}
