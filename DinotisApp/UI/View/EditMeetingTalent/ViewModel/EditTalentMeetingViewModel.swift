//
//  EditTalentMeetingViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 07/11/22.
//

import Foundation
import Combine
import OneSignal
import UIKit
import DinotisData
import DinotisDesignSystem

final class EditTalentMeetingViewModel: ObservableObject {

	var backToHome: () -> Void

	private lazy var stateObservable = StateObservable.shared

	private var cancellables = Set<AnyCancellable>()
	private let authRepository: AuthenticationRepository
	private let meetingRepository: MeetingsRepository
    private let userUseCase: GetUserUseCase
	private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?

	@Published var isLoading = false
	@Published var isError = false
	@Published var success = false
	@Published var error: String?
    @Published var managements: [ManagementWrappedData]?

	@Published var meetingID: String

	@Published var isShowSuccess = false
    @Published var isDisableEdit = false
    @Published var talent = [MeetingCollaborationData]()
    @Published var maxEdit = 0

  @Published var meetingForm = MeetingForm(id: "", title: "", description: "", price: 0, startAt: "", endAt: "", isPrivate: false, slots: 0, managementId: nil, urls: [])

	@Published var isRefreshFailed = false

	init(
		meetingID: String,
		backToHome: @escaping (() -> Void),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
		meetingRepository: MeetingsRepository = MeetingsDefaultRepository(),
        userUseCase: GetUserUseCase = GetUserDefaultUseCase()
	) {
		self.meetingID = meetingID
		self.backToHome = backToHome
		self.authRepository = authRepository
		self.meetingRepository = meetingRepository
        self.userUseCase = userUseCase
	}

	func routeToRoot() {
        NavigationUtil.popToRootView()
        self.stateObservable.userType = 0
        self.stateObservable.isVerified = ""
        self.stateObservable.refreshToken = ""
        self.stateObservable.accessToken = ""
        self.stateObservable.isAnnounceShow = false
        OneSignal.setExternalUserId("")
	}

	func onStartRequest() {
		DispatchQueue.main.async {[weak self] in
			self?.isLoading = true
			self?.isError = false
			self?.error = nil
			self?.isRefreshFailed = false
			self?.isShowSuccess = false
		}

	}
    
    func handleDefaultError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            
            if let error = error as? ErrorResponse {
                self?.error = error.message.orEmpty()
                
                
                if error.statusCode.orZero() == 401 {
                    self?.isRefreshFailed.toggle()
                } else {
                    self?.isError = true
                }
            } else {
                self?.isError = true
                self?.error = error.localizedDescription
            }
            
        }
    }
    
    func getUsers() async {
        onStartRequest()
        
        let result = await userUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.managements = success.managements
                self?.stateObservable.userId = success.id.orEmpty()
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
				self.meetingForm.id = response.id
				self.meetingForm.description = response.description.orEmpty()
                self.meetingForm.endAt = DateUtils.dateFormatter(response.endAt.orCurrentDate(), forFormat: .utcV2)
				self.meetingForm.isPrivate = response.isPrivate ?? false
				self.meetingForm.price = Int(response.price.orEmpty()).orZero()
                self.meetingForm.slots = response.slots.orZero()
                self.meetingForm.startAt = DateUtils.dateFormatter(response.startAt.orCurrentDate(), forFormat: .utcV2)
                self.meetingForm.title = response.title.orEmpty()
                self.meetingForm.managementId = response.managementId
                
                if let startAt = response.startAt, let maxEdit = response.maxEditAt {
                    self.toggleDisableEdit(from: maxEdit)
                    self.maxEdit = self.minuteDifferenceOfMaxEdit(with: maxEdit, from: startAt)
                }
                
                self.meetingForm.urls = response.meetingUrls?.compactMap({ value in
                    MeetingURL(title: value.title.orEmpty(), url: value.url.orEmpty())
                }) ?? []
                
                self.meetingForm.collaborations = response.meetingCollaborations?.compactMap({
                    $0.username
                })
                
                self.talent = response.meetingCollaborations ?? []
            }
            .store(in: &cancellables)
    }

	func editMeeting() {
		onStartRequest()

		meetingRepository.providePutEditMeeting(by: self.meetingID, contain: meetingForm)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							
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
					}
				}
			} receiveValue: { _ in

			}
			.store(in: &cancellables)
	}
    
    func toggleDisableEdit(from maxEdit: Date) {
        isDisableEdit = maxEdit < Date()
    }
    
    func minuteDifferenceOfMaxEdit(with maxEdit: Date, from start: Date) -> Int {
        
        var components1 = Calendar.current.dateComponents([.hour, .minute], from: start)
        
        let components2 = Calendar.current.dateComponents([.hour, .minute, .day, .month, .year], from: maxEdit)
        
        components1.year = components2.year;
        components1.month = components2.month;
        components1.day = components2.day;
        
        guard let date3 = Calendar.current.date(from: components1) else { return 0 }
        
        let timeIntervalInMinutes = date3.timeIntervalSince(maxEdit)/60
        
        return Int(timeIntervalInMinutes)
    }
    
    func disableSaveButton() -> Bool {
        (!meetingForm.urls.isEmpty && meetingForm.urls.allSatisfy({!$0.url.validateURL()})) || isDisableEdit
    }
}
