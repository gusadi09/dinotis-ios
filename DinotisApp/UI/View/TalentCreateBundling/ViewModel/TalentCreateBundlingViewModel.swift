//
//  TalentCreateBundlingViewModel.swift
//  DinotisApp
//
//  Created by Garry on 26/09/22.
//

import Foundation
import Combine
import UIKit
import DinotisData
import OneSignal

enum CreatorCreateBundlingAlert {
    case error
    case refresh
}

final class TalentCreateBundlingViewModel: ObservableObject {
    
    var backToHome: () -> Void
    var backToBundlingList: () -> Void
    
    @Published var route: HomeRouting?

	private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?
    
    private let authRepository: AuthenticationRepository
    
    private let getAvailableMeetingUseCase: GetAvailableMeetingUseCase
    private let getAvailableMeetingForEditUseCase: GetAvailableMeetingForEditUseCase

    private var cancellables = Set<AnyCancellable>()
    private var stateObservable = StateObservable.shared
	private let bundleId: String

    @Published var isShowAlert = false
    @Published var type: CreatorCreateBundlingAlert = .error
	@Published var isEdit: Bool
    
    @Published var isLoading = false
    @Published var isError = false
    @Published var error: String?
    @Published var isRefreshFailed = false
    
    @Published var allSelected = false
    
    @Published var meetingList = [MeetingDetailResponse]()
    @Published var meetingIdArray = [String]()
    
    init(
		bundleId: String = "",
		isEdit: Bool,
        backToHome: @escaping (() -> Void),
        backToBundlingList: @escaping (() -> Void),
        bundlingRepository: BundlingRepository = BundlingDefaultRepository(),
        authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
        getAvailableMeetingUseCase: GetAvailableMeetingUseCase = GetAvailableMeetingDefaultUseCase(),
        getAvailableMeetingForEditUseCase: GetAvailableMeetingForEditUseCase = GetAvailableMeetingForEditDefaultUseCase()
    ) {
		self.bundleId = bundleId
		self.isEdit = isEdit
        self.backToHome = backToHome
        self.backToBundlingList = backToBundlingList
        self.authRepository = authRepository
        self.getAvailableMeetingUseCase = getAvailableMeetingUseCase
        self.getAvailableMeetingForEditUseCase = getAvailableMeetingForEditUseCase
    }
    
    func onStartFetch() {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
            self?.isError = false
            self?.error = nil
            self?.isShowAlert = false
            self?.isRefreshFailed = false
        }
    }
    
    func handleDefaultError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            self?.isShowAlert = true

            if let error = error as? ErrorResponse {
                self?.error = error.message.orEmpty()

                if error.statusCode.orZero() == 401 {
                    self?.isRefreshFailed.toggle()
                    self?.type = .refresh
                } else {
                    self?.isError = true
                    self?.type = .error
                }
            } else {
                self?.isError = true
                self?.type = .error
                self?.error = error.localizedDescription
            }

        }
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
    
    func alertTitle() -> String {
        switch type {
        case .refresh:
            return LocaleText.attention
        case .error:
            return LocaleText.attention
        }
    }
    
    func alertContent() -> String {
        switch type {
        case .refresh:
            return LocaleText.sessionExpireText
        case .error:
            return error.orEmpty()
        }
    }
    
    func alertButtonText() -> String {
        switch type {
        case .refresh:
            return LocaleText.returnText
        case .error:
            return LocaleText.okText
        }
    }
    
    func alertAction() {
        switch type {
        case .refresh:
            routeToRoot()
        case .error:
            break
        }
    }
    
    func getAvailableMeeting() async {
        onStartFetch()
        
        let result = await getAvailableMeetingUseCase.execute()
        
        switch result {
        case .success(let value):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.meetingList = value.data ?? []
            }
            
        case .failure(let error):
            handleDefaultError(error: error)
        }
    }

	func getAvailableMeetingForEdit() async {
		onStartFetch()
        
        let result = await getAvailableMeetingForEditUseCase.execute(with: bundleId)
        
        switch result {
        case .success(let value):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.meetingList = value.data ?? []
            }
            
        case .failure(let error):
            handleDefaultError(error: error)
        }
	}
    
    func addMeeting(id: String) {
        if meetingIdArray.contains(where: {
            $0 == id
        }) {
            guard let index = meetingIdArray.firstIndex(of: id) else { return }
            meetingIdArray.remove(at: index)
        } else {
            meetingIdArray.append(id)
        }
    }
    
    func selectAllSession() {
        if !allSelected {
            meetingIdArray.removeAll()
        } else {
            meetingIdArray = meetingList.map({
                $0.id.orEmpty()
            })
        }
    }
    
    func isAllSelectedManually() -> Bool {
        meetingIdArray.count == meetingList.count
    }
    
    func routeToBundlingForm() {
		let viewModel = BundlingFormViewModel(meetingIdArray: self.meetingIdArray, isEdit: false, backToHome: self.backToHome, backToBundlingList: self.backToBundlingList)
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .bundlingForm(viewModel: viewModel)
        }
    }

	func use(for scrollView: UIScrollView, onValueChanged: @escaping ((UIRefreshControl) -> Void)) {
		DispatchQueue.main.async {
			let refreshControl = UIRefreshControl()
			refreshControl.addTarget(
				self,
				action: #selector(self.onValueChangedAction),
				for: .valueChanged
			)
			scrollView.refreshControl = refreshControl
			self.onValueChanged = onValueChanged
		}

	}

	@objc private func onValueChangedAction(sender: UIRefreshControl) {
		Task.init {
			self.onValueChanged?(sender)
		}
	}
}
