//
//  TalentEditRateCardScheduleViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 06/10/22.
//

import Foundation
import Combine
import DinotisData
import DinotisDesignSystem
import OneSignal

enum EditRateCardType: Identifiable {
	var id: UUID {
		UUID()
	}

	case date
	case startTime
	case endTime
}

final class TalentEditRateCardScheduleViewModel: ObservableObject {
    
    var backToHome: () -> Void

    private var stateObservable = StateObservable.shared

    private var cancellables = Set<AnyCancellable>()
    private let authRepository: AuthenticationRepository
    private let meetingRepository: MeetingsRepository
    private let editRateCardUseCase: EditRequestedSessionUseCase
    private let getDetailMeetingUseCase: GetMeetingDetailUseCase
    private let editMeetingUseCase: EditCreatorMeetingUseCase
    
    @Published var isLoading = false
    @Published var isError = false
    @Published var success = false
    @Published var error: String?
    
    @Published var isShowAlert = false
    @Published var alert = AlertAttribute()
    
    @Published var meetingID: String
    
    @Published var isShowSuccess = false
    
    @Published var meetingForm = MeetingForm(id: "", title: "", description: "", price: 0, startAt: "", endAt: "", isPrivate: false, slots: 0, urls: [])
    
    @Published var isRefreshFailed = false
    
    init(
        meetingID: String,
        backToHome: @escaping (() -> Void),
        authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
        meetingRepository: MeetingsRepository = MeetingsDefaultRepository(),
        editRateCardUseCase: EditRequestedSessionUseCase = EditRequestedSessionDefaultUseCase(),
        getDetailMeetingUseCase: GetMeetingDetailUseCase = GetMeetingDetailDefaultUseCase(),
        editMeetingUseCase: EditCreatorMeetingUseCase = EditCreatorMeetingDefaultUseCase()
    ) {
        self.meetingID = meetingID
        self.backToHome = backToHome
        self.authRepository = authRepository
        self.meetingRepository = meetingRepository
        self.editRateCardUseCase = editRateCardUseCase
        self.getDetailMeetingUseCase = getDetailMeetingUseCase
        self.editMeetingUseCase = editMeetingUseCase
    }
    
	@Published var title = ""
    @Published var duration = 0
    @Published var price = ""
    private var rateCardId = ""

	@Published var sheetType: EditRateCardType?

    @Published var timeStart: Date = Date().addingTimeInterval(3600)
    @Published var timeEnd: Date = Date()
    
    func onStartRequest() {
        DispatchQueue.main.async {[weak self] in
            self?.isLoading = true
            self?.isError = false
            self?.error = nil
            self?.isRefreshFailed = false
            self?.isShowSuccess = false
          self?.isShowAlert = false
          self?.alert = .init(
            isError: false,
            title: LocalizableText.attentionText,
            message: "",
            primaryButton: .init(text: LocalizableText.closeLabel, action: {}),
            secondaryButton: nil
          )
        }

    }

    func handleDefaultError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            self?.success = false
            
            if let error = error as? ErrorResponse {
                
                if error.statusCode.orZero() == 401 {
                    self?.error = error.message.orEmpty()
                    self?.isRefreshFailed.toggle()
                    self?.alert.isError = true
                    self?.alert.message = LocalizableText.alertSessionExpired
                    self?.alert.primaryButton = .init(
                        text: LocalizableText.okText,
                        action: {
                            NavigationUtil.popToRootView()
                            self?.stateObservable.userType = 0
                            self?.stateObservable.isVerified = ""
                            self?.stateObservable.refreshToken = ""
                            self?.stateObservable.accessToken = ""
                            self?.stateObservable.isAnnounceShow = false
                            OneSignal.setExternalUserId("")
                        }
                    )
                    self?.isShowAlert = true
                }else if error.statusCode.orZero() == 422 {
                    self?.isError = true
                    self?.alert.isError = true
                    self?.alert.message = LocaleText.formFieldError
                    self?.isShowAlert = true
                } else {
                    self?.isError = true
                    self?.error = error.message.orEmpty()
                    self?.alert.message = error.message.orEmpty()
                    self?.alert.isError = true
                    self?.isShowAlert = true
                }
            } else {
                self?.isError = true
                self?.error = error.localizedDescription
                self?.alert.message = error.localizedDescription
                self?.alert.isError = true
                self?.isShowAlert = true
            }
            
        }
	}
    
  func editRateCard(successAction: @escaping () -> Void) async {
        onStartRequest()

        let body = EditRequestedSessionRequest(
            startAt: DateUtils.dateFormatter(timeStart, forFormat: .utcV2),
            endAt: DateUtils.dateFormatter(timeEnd, forFormat: .utcV2)
        )

		let result = await editRateCardUseCase.execute(by: meetingID, with: body)

		switch result {
		case .success(_):
			DispatchQueue.main.async { [weak self] in
				self?.isLoading = false
        self?.alert.isError = false
        self?.alert.title = LocaleText.successTitle
        self?.alert.message = LocaleText.editVideoCallSuccessSubtitle
        self?.alert.primaryButton = .init(
          text: LocalizableText.okText,
          action: {
            successAction()
          }
        )
        self?.alert.secondaryButton = nil
        self?.isShowAlert = true
			}
		case .failure(let failure):
			handleDefaultError(error: failure)
		}
    }
    
    func getMeetingDetail() async {
        onStartRequest()

        let result = await getDetailMeetingUseCase.execute(for: meetingID)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                
                self?.meetingForm.id = success.id
                self?.meetingForm.description = success.description.orEmpty()
                self?.meetingForm.endAt = DateUtils.dateFormatter(success.endAt.orCurrentDate(), forFormat: .utcV2)
                self?.meetingForm.isPrivate = success.isPrivate ?? false
                self?.meetingForm.price = Int(success.price.orEmpty()).orZero()
                self?.meetingForm.slots = success.slots.orZero()
                self?.meetingForm.startAt = DateUtils.dateFormatter(success.startAt.orCurrentDate(), forFormat: .utcV2)
                self?.meetingForm.title = success.title.orEmpty()
                
                self?.title = success.title.orEmpty()
                self?.price = success.price.orEmpty()
                self?.duration = (success.meetingRequest?.rateCard?.duration).orZero()
                self?.timeStart = success.startAt ?? Date().addingTimeInterval(3600)
                self?.timeEnd = success.startAt.orCurrentDate()
                self?.rateCardId = (success.meetingRequest?.rateCardId).orEmpty()
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }

    func editMeeting(successAction: @escaping () -> Void) async {
        onStartRequest()

        let body = AddMeetingRequest(
            title: meetingForm.title,
            description: meetingForm.description,
            price: Int(price).orZero(),
            startAt: DateUtils.dateFormatter(timeStart, forFormat: .utcV2),
            endAt: DateUtils.dateFormatter(timeEnd, forFormat: .utcV2),
            isPrivate: meetingForm.isPrivate,
            slots: meetingForm.slots,
            urls: [], 
            archiveRecording: false, collaboratorAudienceVisibility: false
        )
        
        let result = await editMeetingUseCase.execute(for: meetingID, with: body)
        
        switch result {
        case .success(_):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.isShowSuccess = true
                successAction()
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }

    }
}
