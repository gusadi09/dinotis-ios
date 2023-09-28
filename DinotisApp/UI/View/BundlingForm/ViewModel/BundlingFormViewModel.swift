//
//  BundlingFormViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 30/09/22.
//

import Foundation
import Combine
import DinotisData
import OneSignal

enum BundleAlertType {
    case error
    case refreshFailed
    case created
    case updated
}

final class BundlingFormViewModel: ObservableObject {
    
    private let authRepository: AuthenticationRepository
	private let bundleId: String
    
    private let createBundlingUseCase: CreateBundlingUseCase
    private let updateBundlingUseCase: UpdateBundlingUseCase
    private let getBundlingDetailUseCase: GetBundlingDetailUseCase

    private var cancellables = Set<AnyCancellable>()
    private var stateObservable = StateObservable.shared
    
    var backToHome: () -> Void
    var backToBundlingList: () -> Void
    
    @Published var route: HomeRouting?
	@Published var isEdit: Bool
    
    @Published var isLoading = false
    @Published var isError = false
    @Published var error: String?
    @Published var isRefreshFailed = false

	@Published var isLoadingDetail = false
	@Published var isErrorDetail = false
	@Published var errorDetail: String?
	@Published var detailData: DetailBundlingResponse?
    
    @Published var titleError: String?
    @Published var descError: String?
    
    @Published var isBundleCreated = false
	@Published var isBundleUpdated = false
    
    @Published var meetingIdArray = [String]()
	@Published var title = ""
	@Published var desc = ""
	@Published var price = ""
    
    @Published var isShowAlert = false
    @Published var type: BundleAlertType = .error
    
    init(
		bundleId: String = "",
        meetingIdArray: [String],
		isEdit: Bool,
        backToHome: @escaping (() -> Void),
        backToBundlingList: @escaping (() -> Void),
        bundlingRepository: BundlingRepository = BundlingDefaultRepository(),
        authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
        createBundlingUseCase: CreateBundlingUseCase = CreateBundlingDefaultUseCase(),
        updateBundlingUseCase: UpdateBundlingUseCase = UpdateBundlingDefaultUseCase(),
        getBundlingDetailUseCase: GetBundlingDetailUseCase = GetBundlingDetailDefaultUseCase()
    ) {
		self.bundleId = bundleId
        self.meetingIdArray = meetingIdArray
		self.isEdit = isEdit
        self.backToHome = backToHome
        self.backToBundlingList = backToBundlingList
        self.authRepository = authRepository
        self.createBundlingUseCase = createBundlingUseCase
        self.updateBundlingUseCase = updateBundlingUseCase
        self.getBundlingDetailUseCase = getBundlingDetailUseCase
    }
    
    func onStartFetch() {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
            self?.isError = false
            self?.isShowAlert = false
            self?.error = nil
            self?.isRefreshFailed = false
			self?.isBundleUpdated = false
        }
    }
    
    func alertTitle() -> String {
        switch type {
        case .error:
            return LocaleText.attention
        case .created:
            return LocaleText.bundleSuccessTitle
        case .updated:
            return LocaleText.successTitle
        case .refreshFailed:
            return LocaleText.attention
        }
    }
    
    func alertContent() -> String {
        switch type {
        case .error:
            return error.orEmpty()
        case .created:
            return LocaleText.bundleSuccessDesc
        case .updated:
            return LocaleText.successUpdateBundle
        case .refreshFailed:
            return LocaleText.sessionExpireText
        }
    }
    
    func alertButtonText() -> String {
        switch type {
        case .error:
            return LocaleText.okText
        case .created:
            return LocaleText.okText
        case .updated:
            return LocaleText.okText
        case .refreshFailed:
            return LocaleText.returnText
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
    
    func alertAction(completion: () -> Void) {
        switch type {
        case .error:
            break
        case .created:
            backToBundlingList()
        case .updated:
            completion()
        case .refreshFailed:
            routeToRoot()
        }
    }
    
    func createBundle() async {
        onStartFetch()
        
        let body = CreateBundling(
            title: title,
            description: desc,
            price: Int(price).orZero(),
            meetings: meetingIdArray
        )
        
        let result = await createBundlingUseCase.execute(body: body)
        
        switch result {
        case .success:
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.isBundleCreated = true
                self?.isShowAlert = true
                self?.type = .created
            }
            
        case .failure(let error):
            guard let error = error as? ErrorResponse else { return }
            DispatchQueue.main.async { [weak self] in
                if error.statusCode.orZero() == 401 {
                    self?.type = .refreshFailed
                    self?.isShowAlert = true
                } else if error.statusCode.orZero() == 422 {
                    if let titleError = error.fields?.filter({
                        $0.name == "title"
                    }).first {
                        self?.titleError = titleError.error
                    }
                    
                    if let descError = error.fields?.filter({
                        $0.name == "description"
                    }).first {
                        self?.descError = descError.error
                    }
                    self?.isLoading = false
                } else {
                    self?.isLoading = false
                    self?.isError = true
                    self?.isShowAlert = true
                    self?.type = .error
                    self?.isBundleCreated = false
                    self?.error = error.message.orEmpty()
                }
            }
        }
    }

	func updateBundle() async {
		onStartFetch()

		let body = UpdateBundlingBody(
			title: title,
			description: desc,
			price: Int(price).orZero(),
			meetingIds: meetingIdArray
		)
        
        let result = await updateBundlingUseCase.execute(by: (detailData?.id).orEmpty(), body: body)
        
        switch result {
        case .success:
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.isBundleUpdated = true
                self?.isShowAlert = true
                self?.type = .updated
            }
        case .failure(let error):
            guard let error = error as? ErrorResponse else { return }
            DispatchQueue.main.async { [weak self] in
                if error.statusCode.orZero() == 401 {
                    self?.isRefreshFailed = true
                    self?.type = .refreshFailed
                } else if error.statusCode.orZero() == 422 {
                    print(body)
                    print(error)
                    if let titleError = error.fields?.filter({
                        $0.name == "title"
                    }).first {
                        self?.titleError = titleError.error
                    }

                    if let descError = error.fields?.filter({
                        $0.name == "description"
                    }).first {
                        self?.descError = descError.error
                    }
                    self?.isLoading = false
                } else {
                    self?.isLoading = false
                    self?.isError = true
                    self?.isShowAlert = true
                    self?.type = .error
                    self?.isBundleUpdated = false
                    self?.error = error.message.orEmpty()
                }
            }
        }
	}

	func isFieldEmpty() -> Bool {
		title.isEmpty || desc.isEmpty
	}
    
    func routeToBundlingDetail() {
		let viewModel = BundlingDetailViewModel(bundleId: "", meetingIdArray: self.meetingIdArray, backToHome: self.backToHome, isTalent: true, isActive: false)
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .bundlingDetail(viewModel: viewModel)
        }
    }

	func onStartRequest() {
		DispatchQueue.main.async {[weak self] in
			self?.isLoadingDetail = true
			self?.isErrorDetail = false
			self?.errorDetail = nil
			self?.isRefreshFailed = false
		}
	}

	func getBundleDetail() async {
		onStartRequest()
        
        let result = await getBundlingDetailUseCase.execute(by: bundleId)
        
        switch result {
        case .success(let response):
            DispatchQueue.main.async {[weak self] in
                self?.isLoadingDetail = false
                self?.detailData = response
                self?.title = response.title.orEmpty()
                self?.desc = response.description.orEmpty()
                self?.price = response.price.orEmpty()
                self?.meetingIdArray = (response.meetings ?? []).map({
                    $0.id.orEmpty()
                })
            }
            
        case .failure(let error):
            guard let error = error as? ErrorResponse else { return }
            DispatchQueue.main.async {[weak self] in
                if error.statusCode.orZero() == 401 {
                    
                } else {
                    self?.isLoadingDetail = false
                    self?.isErrorDetail = true

                    self?.errorDetail = error.message.orEmpty()
                }
            }
        }
	}

	func onAppear() {
		if isEdit {
            Task {
                await getBundleDetail()
            }
		}
	}

	func routeToCreateBundling() {
		let viewModel = TalentCreateBundlingViewModel(bundleId: self.bundleId, isEdit: true, backToHome: self.backToHome, backToBundlingList: {})

		DispatchQueue.main.async { [weak self] in
			self?.route = .createBundling(viewModel: viewModel)
		}
	}
}
