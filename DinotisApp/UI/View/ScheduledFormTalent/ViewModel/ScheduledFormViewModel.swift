//
//  ScheduledFormView.swift
//  DinotisApp
//
//  Created by Gus Adi on 26/02/22.
//

import Foundation
import SwiftUI
import OneSignal
import Combine
import DinotisData
import DinotisDesignSystem

enum AppCostTip {
    case first
    case two
}

extension AppCostTip {
    var value: String {
        switch self {
        case .first:
            return "first"
        case .two:
            return "two"
        }
    }
}

final class ScheduledFormViewModel: ObservableObject {

	private lazy var stateObservable = StateObservable.shared
	private var cancellables = Set<AnyCancellable>()
    private let userUseCase: GetUserUseCase
    private let addMeetingUseCase: CreateNewMeetingUseCase
    private let getMeetingFeeUseCase: GetMeetingFeeUseCase
	
	var backToHome: () -> Void

    @Published var isShowSelectedTalent = false
    @Published var talent = [MeetingCollaborationData]()
    @Published var presentTalentPicker = false
    @Published var isShowAdditionalMenu = false
    @Published var showsDatePicker = false
    @Published var showsTimePicker = false
    @Published var showsTimeUntilPicker = false
	@Published var colorTab = Color.clear

    @Published var managements: [ManagementWrappedData]?
	@Published var isLoading = false
	@Published var isError = false
	@Published var success = false
	@Published var error: String?
    
    @Published var isShowAppCostsManagement = false
    @Published var isChangedCostManagement = false
    @Published var appUsageFareSheetHeight: CGFloat = 460.0
    @Published var percentageString = "0"
    @Published var percentageRaw = 0.0
    @Published var isSliderUsed = false
    @Published var isFreeTextUsed = false
    @Published var percentageFaresForCreatorRaw = 1.0
    @Published var percentageFaresForCreator = 1.0
    @Published var percentageFaresForCreatorStr = "100"
    
    @Published var isShowPriceEmptyWarning = false
    @Published var timer: Timer?
    @Published var onSecondTime = 0
    
    @Published var isShowFirstTooltip = false
    @Published var isShowSeconTooltip = false

	@Published var minimumPeopleError = false
    
    @Published var isRefreshFailed = false
    
    @Published var meeting = AddMeetingRequest(title: "", description: "", price: 0, startAt: "", endAt: "", isPrivate: true, slots: 1, managementId: nil, urls: [])
    @Published var isArchieve = false
    
    @Published var arrSession = [LocaleText.privateCallLabel, LocaleText.groupcallLabel]
    @Published var selectedSession = ""
    @Published var peopleGroup = "1"
    @Published var estPrice = 0
    @Published var pricePerPeople = ""
    @Published var rawPrice = ""
    @Published var isValidPersonForGroup = false
    @Published var selectedWallet: String? = nil
    @Published var walletLocal = [
        ManagementWrappedData(
            id: nil,
            managementId: nil,
            userId: nil,
            management: UserDataOfManagement(
                createdAt: nil,
                id: nil,
                updatedAt: nil,
                user: ManagementTalentData(
                    id: nil,
                    name: LocalizableText.personalWalletText,
                    username: nil,
                    profilePhoto: nil,
                    profileDescription: nil,
                    professions: nil,
                    userHighlights: nil,
                    isVerified: nil,
                    isVisible: nil,
                    isActive: nil,
                    stringProfessions: nil
                ),
                userId: nil
            )
        )
    ]
    
    @Published var startDate: Date? = Date().addingTimeInterval(3600)
    @Published var endDate: Date? = Date().addingTimeInterval(7200)
    
    @Published var changedStartDate = Date().addingTimeInterval(3600)
    @Published var changedEndDate = Date().addingTimeInterval(7200)

    @Published var fee = 0
    
    @Published var isFieldTitleError = false
    @Published var fieldTitleError = ""
    @Published var isFieldDescError = false
    @Published var fieldDescError = ""
	
	init(
		backToHome: @escaping (() -> Void),
        userUseCase: GetUserUseCase = GetUserDefaultUseCase(),
        addMeetingUseCase: CreateNewMeetingUseCase = CreateNewMeetingDefaultUseCase(),
        getMeetingFeeUseCase: GetMeetingFeeUseCase = GetMeetingFeeDefaultUseCase()
	) {
		self.backToHome = backToHome
        self.userUseCase = userUseCase
        self.addMeetingUseCase = addMeetingUseCase
        self.getMeetingFeeUseCase = getMeetingFeeUseCase
	}
    
    func getThreeSecondTime() {
        isShowPriceEmptyWarning = true
        let getting = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(increaseTime), userInfo: nil, repeats: true)
        
        self.timer = getting
    }
    
    @objc func increaseTime() {
        onSecondTime += 1
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
    
    func perPersonPriceCount(price: String) {
        if let intPrice = Int(price) {
            meeting.price = intPrice
            
            let intPeople = Int(peopleGroup)
            let intPrice = Int(pricePerPeople)
            estPrice = (intPrice ?? 0) * (intPeople ?? 0)
            
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
    
    func handleDefaultFieldError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            
            if let error = error as? ErrorResponse {
                self?.error = error.message.orEmpty()
                
                
                if error.statusCode.orZero() == 401 {
                    self?.isRefreshFailed.toggle()
                } else if error.statusCode.orZero() == 422 {
                    if let titleError = error.fields?.first(where: {
                        $0.name.orEmpty() == "title"
                    }) {
                        self?.isFieldTitleError = true
                        self?.fieldTitleError = titleError.error.orEmpty()
                    }
                    
                    if let descError = error.fields?.first(where: {
                        $0.name.orEmpty() == "description"
                    }) {
                        self?.isFieldDescError = true
                        self?.fieldDescError = descError.error.orEmpty()
                    }
                } else {
                    self?.isError = true
                }
            } else {
                self?.isError = true
                self?.error = error.localizedDescription
            }
            
        }
    }
    
    func appUsageEstimated() -> Double {
        Double((fee * Int(peopleGroup).orZero()) * (Int(endDate.orCurrentDate().timeIntervalSince(startDate.orCurrentDate()))/60))
    }
    
    func onPeopleOnGroupChanges(_ value: String) {
        if let intVal = Int(value) {
            meeting.slots = intVal
            
            let intPeople = Int(peopleGroup)
            let intPrice = Int(pricePerPeople)
            estPrice = (intPrice ?? 0) * (intPeople ?? 0)
            
            isValidPersonForGroup = Int(value).orZero() > 0
        }
    }
    
    func getUser() async {
        onStartRequest()
        
        let result = await userUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.managements = (self?.managements ?? []) + (success.managements ?? [])
                self?.stateObservable.userId = success.id.orEmpty()
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    func getFee() async {
        onStartRequest()
        
        let result = await getMeetingFeeUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.fee = success
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    func onAppear() {
        onGetUser()
        onGetFee()
    }
    
    func onGetUser() {
        Task {
            await getUser()
        }
    }
    
    func onGetFee() {
        Task {
            await getFee()
        }
    }
    
    func audienceBorne() -> Double {
        return appUsageEstimated() - (appUsageEstimated()*percentageFaresForCreator)
    }
    
    func creatorEstimated() -> Double {
        return isChangedCostManagement ? appUsageEstimated()*percentageFaresForCreator : 0.0
    }
    
    func creatorBorne() -> Double {
        return appUsageEstimated()*percentageFaresForCreator
    }

    func submitMeeting() {
        UIApplication.shared.endEditing()
        meeting.userFeePercentage = isChangedCostManagement ? Int(percentageString) ?? Int(percentageRaw*100) : 100
        meeting.talentFeePercentage = isChangedCostManagement ? Int(percentageFaresForCreatorStr) ?? Int(percentageFaresForCreator*100) : 0
        meeting.slots = Int(peopleGroup) ?? 1
        meeting.price = Int(rawPrice).orZero()
        if meeting.endAt.isEmpty && meeting.startAt.isEmpty {
            meeting.endAt = DateUtils.dateFormatter(Date().addingTimeInterval(7200), forFormat: .utcV2)
            
            meeting.startAt = DateUtils.dateFormatter(Date().addingTimeInterval(3600), forFormat: .utcV2)
            onCreateMeeting(with: meeting)
        } else if meeting.endAt.isEmpty {
            let time = DateUtils.dateFormatter(meeting.startAt, forFormat: .utcV2)
            meeting.endAt = DateUtils.dateFormatter(time.addingTimeInterval(3600), forFormat: .utcV2)
            onCreateMeeting(with: meeting)
            
        } else if meeting.startAt.isEmpty {
            meeting.endAt = DateUtils.dateFormatter(Date().addingTimeInterval(7200), forFormat: .utcV2)
            
            meeting.startAt = DateUtils.dateFormatter(Date().addingTimeInterval(3600), forFormat: .utcV2)
            onCreateMeeting(with: meeting)
        } else {
            onCreateMeeting(with: meeting)
        }
        
    }

	func onStartRequest() {
		DispatchQueue.main.async {[weak self] in
			self?.isLoading = true
			self?.isError = false
			self?.error = nil
			self?.success = false
			self?.isRefreshFailed = false
            self?.isFieldTitleError = false
            self?.isFieldDescError = false
		}

	}
    
    func onCreateMeeting(with meeting: AddMeetingRequest) {
        Task {
            await addMeeting(meeting: meeting)
        }
    }

	func addMeeting(meeting: AddMeetingRequest) async {
		onStartRequest()
        
        print(meeting)
        let result = await addMeetingUseCase.execute(from: meeting)
        
        switch result {
        case .success(_):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                
                self?.success = true
            }
        case .failure(let failure):
            handleDefaultFieldError(error: failure)
        }
	}
}
