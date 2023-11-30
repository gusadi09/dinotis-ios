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
    private let getDetailMeetingUseCase: GetMeetingDetailUseCase
	private let authRepository: AuthenticationRepository
	private let meetingRepository: MeetingsRepository
    private let userUseCase: GetUserUseCase
    private let editMeetingUseCase: EditCreatorMeetingUseCase
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
    
    @Published var meetingForm = AddMeetingRequest(title: "", description: "", price: 0, startAt: "", endAt: "", isPrivate: false, slots: 0, managementId: nil, urls: [], archiveRecording: false, collaboratorAudienceVisibility: false)
    
    @Published var isRefreshFailed = false
    
    @Published var isShowAlert = false
    
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
    
    @Published var isArchieve = false
    @Published var isVisible = false
    
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
    
    @Published var isShowSelectedTalent = false
    @Published var presentTalentPicker = false
    @Published var isShowAdditionalMenu = false
    @Published var showsDatePicker = false
    @Published var showsTimePicker = false
    @Published var showsTimeUntilPicker = false
    
    init(
		meetingID: String,
		backToHome: @escaping (() -> Void),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
		meetingRepository: MeetingsRepository = MeetingsDefaultRepository(),
        userUseCase: GetUserUseCase = GetUserDefaultUseCase(),
        getDetailMeetingUseCase: GetMeetingDetailUseCase = GetMeetingDetailDefaultUseCase(),
        editMeetingUseCase: EditCreatorMeetingUseCase = EditCreatorMeetingDefaultUseCase()
	) {
		self.meetingID = meetingID
		self.backToHome = backToHome
		self.authRepository = authRepository
		self.meetingRepository = meetingRepository
        self.userUseCase = userUseCase
        self.getDetailMeetingUseCase = getDetailMeetingUseCase
        self.editMeetingUseCase = editMeetingUseCase
	}
    
    func onPeopleOnGroupChanges(_ value: String) {
        if let intVal = Int(value) {
            meetingForm.slots = intVal
            
            let intPeople = Int(peopleGroup)
            let intPrice = Int(pricePerPeople)
            estPrice = (intPrice ?? 0) * (intPeople ?? 0)
            
            isValidPersonForGroup = Int(value).orZero() > 0
        }
    }
    
    func appUsageEstimated() -> Double {
        Double((fee * Int(peopleGroup).orZero()) * (Int(endDate.orCurrentDate().timeIntervalSince(startDate.orCurrentDate()))/60))
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
            self?.isShowAlert = false
		}

	}
    
    func handleDefaultError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            
            if let error = error as? ErrorResponse {
                
                if error.statusCode.orZero() == 401 {
                    self?.isRefreshFailed.toggle()
                    self?.error = error.message.orEmpty()
                } else if error.statusCode.orZero() == 422 {
                    self?.isError = true

                    self?.error = LocaleText.formFieldError
                } else {
                    self?.isError = true
                    self?.error = error.message.orEmpty()
                }
            } else {
                self?.isError = true
                self?.error = error.localizedDescription
            }
            
            self?.isShowAlert = true
        }
    }
    
    func getUsers() async {
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

    func onGetUser() {
        Task {
            await getUsers()
        }
    }
    
    func onGetMeetingDetail() {
        Task {
            await getMeetingDetail()
        }
    }
    
    func onAppear() {
        onGetUser()
        onGetMeetingDetail()
    }
    
    func getThreeSecondTime() {
        isShowPriceEmptyWarning = true
        let getting = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(increaseTime), userInfo: nil, repeats: true)
        
        self.timer = getting
    }
    
    @objc func increaseTime() {
        onSecondTime += 1
    }
    
    func perPersonPriceCount(price: String) {
        if let intPrice = Int(price) {
            meetingForm.price = intPrice
            
            let intPeople = Int(peopleGroup)
            let intPrice = Int(pricePerPeople)
            estPrice = (intPrice ?? 0) * (intPeople ?? 0)
            
        }
    }
    
	func getMeetingDetail() async {
		onStartRequest()

        let result = await getDetailMeetingUseCase.execute(for: self.meetingID)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.meetingForm.description = success.description.orEmpty()
                self?.meetingForm.endAt = DateUtils.dateFormatter(success.endAt.orCurrentDate(), forFormat: .utcV2)
                self?.meetingForm.isPrivate = success.isPrivate ?? false
                self?.selectedSession = success.isPrivate ?? false ? (self?.arrSession.first(where: { $0 == LocaleText.privateCallLabel })).orEmpty() : (self?.arrSession.first(where: { $0 == LocaleText.groupcallLabel })).orEmpty()
                self?.meetingForm.price = Int(success.price.orEmpty()).orZero()
                self?.meetingForm.slots = success.slots.orZero()
                self?.meetingForm.startAt = DateUtils.dateFormatter(success.startAt.orCurrentDate(), forFormat: .utcV2)
                self?.meetingForm.title = success.title.orEmpty()
                self?.meetingForm.managementId = success.managementId
                self?.pricePerPeople = success.price.orEmpty()
                self?.peopleGroup = "\(success.slots.orZero())"
                self?.selectedWallet = success.managementId == nil ?
                LocalizableText.personalWalletText :
                self?.managements?.first(where: {
                    $0.management?.id == success.managementId
                })?.management?.user?.name
                
                self?.isArchieve = success.archiveRecording.orFalse()
                self?.isVisible = success.collaboratorAudienceVisibility.orFalse()
                self?.isChangedCostManagement = true
                self?.percentageRaw = Double((success.meetingFee?.userFeePercentage).orZero())/100
                self?.percentageString = "\((success.meetingFee?.userFeePercentage).orZero())"
                self?.percentageFaresForCreatorStr = "\((success.meetingFee?.talentFeePercentage).orZero())"
                self?.percentageFaresForCreatorRaw = Double((success.meetingFee?.talentFeePercentage).orZero())/100
                self?.percentageFaresForCreator = Double((success.meetingFee?.talentFeePercentage).orZero())/100
                
                self?.fee = (success.meetingFee?.oneMinuteFee).orZero()
                
                if let startAt = success.startAt, let maxEdit = success.maxEditAt {
                    self?.toggleDisableEdit(from: maxEdit)
                    self?.maxEdit = (self?.minuteDifferenceOfMaxEdit(with: maxEdit, from: startAt)).orZero()
                }
                
                self?.meetingForm.urls = success.meetingUrls?.compactMap({ value in
                    MeetingURLrequest(title: value.title.orEmpty(), url: value.url.orEmpty())
                }) ?? []
                
                self?.meetingForm.collaborations = success.meetingCollaborations?.compactMap({
                    $0.username
                })
                
                self?.talent = success.meetingCollaborations ?? []
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }

    @MainActor
	func editMeeting() async {
		onStartRequest()
        self.meetingForm = AddMeetingRequest(
            title: self.meetingForm.title,
            description: self.meetingForm.description,
            price: Int(self.pricePerPeople).orZero(),
            startAt: self.meetingForm.startAt,
            endAt: self.meetingForm.endAt,
            isPrivate: self.meetingForm.isPrivate,
            slots: Int(self.peopleGroup).orZero(),
            managementId: self.meetingForm.managementId,
            urls: self.meetingForm.urls,
            collaborations: self.meetingForm.collaborations,
            userFeePercentage: Int(percentageString) ?? Int(percentageRaw*100),
            talentFeePercentage: Int(percentageFaresForCreatorStr) ?? Int(percentageFaresForCreator*100),
            archiveRecording: self.meetingForm.isPrivate ? false : self.isArchieve,
            collaboratorAudienceVisibility: self.meetingForm.isPrivate ? false : self.isVisible
        )
        
        let result = await editMeetingUseCase.execute(for: meetingID, with: meetingForm)
        
        switch result {
        case .success(_):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.isShowSuccess = true
                self?.isShowAlert = true
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }

	}
    
    func alertText() -> String {
        if isRefreshFailed && !isShowSuccess && !isError {
            return LocaleText.sessionExpireText
        } else if !isRefreshFailed && isShowSuccess && !isError {
            return LocaleText.editVideoCallSuccessSubtitle
        } else {
            return self.error.orEmpty()
        }
    }
    
    func alertTitle() -> String {
        if isRefreshFailed && !isShowSuccess && !isError {
            return LocaleText.attention
        } else if !isRefreshFailed && isShowSuccess && !isError {
            return LocaleText.attention
        } else {
            return LocaleText.successTitle
        }
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
