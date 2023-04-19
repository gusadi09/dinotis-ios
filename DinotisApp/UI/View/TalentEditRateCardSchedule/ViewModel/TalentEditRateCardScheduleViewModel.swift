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

enum EditRateCardType: Identifiable {
	var id: UUID {
		UUID()
	}

	case date
	case startTime
	case endTime
}

final class TalentEditRateCardScheduleViewModel: ObservableObject {
    
    var backToRoot: () -> Void
    var backToHome: () -> Void

    private var stateObservable = StateObservable.shared

    private var cancellables = Set<AnyCancellable>()
    private let authRepository: AuthenticationRepository
    private let meetingRepository: MeetingsRepository
    private let editRateCardUseCase: EditRequestedSessionUseCase
    
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
        backToRoot: @escaping (() -> Void),
        backToHome: @escaping (() -> Void),
        authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
        meetingRepository: MeetingsRepository = MeetingsDefaultRepository(),
        editRateCardUseCase: EditRequestedSessionUseCase = EditRequestedSessionDefaultUseCase()
    ) {
        self.meetingID = meetingID
        self.backToRoot = backToRoot
        self.backToHome = backToHome
        self.authRepository = authRepository
        self.meetingRepository = meetingRepository
        self.editRateCardUseCase = editRateCardUseCase
    }
    
	@Published var title = ""
    @Published var duration = 0
    @Published var price = ""
    private var rateCardId = ""

	@Published var sheetType: EditRateCardType?

	@Published var timeStart: Date = Date()
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
              self?.backToRoot()
            }
          )
          self?.isShowAlert = true
				}else if error.statusCode.orZero() == 422 {
					self?.isError = true

					self?.error = LocaleText.formFieldError
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
    
    func getMeetingDetail() {
        onStartRequest()

        meetingRepository.provideGetDetailMeeting(meetingId: self.meetingID)
            .sink { result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {[weak self] in
                        if error.statusCode.orZero() == 401 {
                          self?.alert.isError = true
                          self?.alert.message = LocalizableText.alertSessionExpired
                          self?.alert.primaryButton = .init(
                            text: LocalizableText.okText,
                            action: {
                              self?.backToRoot()
                            }
                          )
                          self?.isShowAlert = true
                        } else {
                            self?.isLoading = false
                            self?.isError = true

                            self?.error = error.message.orEmpty()
                        }
                    }

                case .finished:
                    DispatchQueue.main.async { [weak self] in
                        self?.isLoading = false
                    }
                }
            } receiveValue: { response in
                print(response)
                self.meetingForm.id = response.id
                self.meetingForm.description = response.description.orEmpty()
                self.meetingForm.endAt = DateUtils.dateFormatter(response.endAt.orCurrentDate(), forFormat: .utcV2)
                self.meetingForm.isPrivate = response.isPrivate ?? false
                self.meetingForm.price = Int(response.price.orEmpty()).orZero()
                self.meetingForm.slots = response.slots.orZero()
                self.meetingForm.startAt = DateUtils.dateFormatter(response.startAt.orCurrentDate(), forFormat: .utcV2)
                self.meetingForm.title = response.title.orEmpty()
                
                self.title = response.title.orEmpty()
                self.price = response.price.orEmpty()
                self.duration = (response.meetingRequest?.rateCard?.duration).orZero()
                self.timeStart = response.startAt.orCurrentDate()
                self.timeEnd = response.startAt.orCurrentDate()
                self.rateCardId = (response.meetingRequest?.rateCardId).orEmpty()
            }
            .store(in: &cancellables)
    }

    func editMeeting(successAction: @escaping () -> Void) {
        onStartRequest()

        let body = MeetingForm(
            title: meetingForm.title,
            description: meetingForm.description,
            price: Int(price).orZero(),
            startAt: DateUtils.dateFormatter(timeStart, forFormat: .utcV2),
            endAt: DateUtils.dateFormatter(timeEnd, forFormat: .utcV2),
            isPrivate: meetingForm.isPrivate,
            slots: meetingForm.slots,
            urls: []
        )

        meetingRepository.providePutEditMeeting(by: self.meetingID, contain: body)
            .sink { result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {[weak self] in
                        if error.statusCode.orZero() == 401 {
                          self?.alert.isError = true
                          self?.alert.message = LocalizableText.alertSessionExpired
                          self?.alert.primaryButton = .init(
                            text: LocalizableText.okText,
                            action: {
                              self?.backToRoot()
                            }
                          )
                          self?.isShowAlert = true
                        } else if error.statusCode.orZero() == 422 {
                            self?.isLoading = false
                            self?.isError = true

                            self?.error = LocaleText.formFieldError
                        } else {
                            self?.isLoading = false
                            self?.isError = true

                            self?.error = error.message.orEmpty()
                        }
                    }

                case .finished:
                    DispatchQueue.main.async { [weak self] in
                        self?.isLoading = false
                        self?.isShowSuccess = true
                        successAction()
                    }
                }
            } receiveValue: { _ in

            }
            .store(in: &cancellables)
    }
}
