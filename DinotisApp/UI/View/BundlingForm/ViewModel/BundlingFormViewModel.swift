//
//  BundlingFormViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 30/09/22.
//

import Foundation
import Combine
import DinotisData

final class BundlingFormViewModel: ObservableObject {
    
    private let bundlingRepository: BundlingRepository
    private let authRepository: AuthenticationRepository
	private let bundleId: String

    private var cancellables = Set<AnyCancellable>()
    private var stateObservable = StateObservable.shared
    
    var backToRoot: () -> Void
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
    
    init(
		bundleId: String = "",
        meetingIdArray: [String],
		isEdit: Bool,
        backToRoot: @escaping (() -> Void),
        backToHome: @escaping (() -> Void),
        backToBundlingList: @escaping (() -> Void),
        bundlingRepository: BundlingRepository = BundlingDefaultRepository(),
        authRepository: AuthenticationRepository = AuthenticationDefaultRepository()
    ) {
		self.bundleId = bundleId
        self.meetingIdArray = meetingIdArray
		self.isEdit = isEdit
        self.backToRoot = backToRoot
        self.backToHome = backToHome
        self.backToBundlingList = backToBundlingList
        self.bundlingRepository = bundlingRepository
        self.authRepository = authRepository
    }
    
    func onStartFetch() {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
            self?.isError = false
            self?.error = nil
            self?.isRefreshFailed = false
			self?.isBundleUpdated = false
        }
    }
    
    func createBundle() {
        onStartFetch()
        
        let body = CreateBundling(
            title: title,
            description: desc,
            price: Int(price).orZero(),
            meetings: meetingIdArray
        )
        
        bundlingRepository.provideCreateBundling(body: body)
            .sink { result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async { [weak self] in
                        if error.statusCode.orZero() == 401 {
                            
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
                            self?.isBundleCreated = false
                            self?.error = error.message.orEmpty()
                        }
                    }
                case .finished:
                    DispatchQueue.main.async { [weak self] in
                        self?.isLoading = false
                        self?.isBundleCreated = true
                    }
                }
            } receiveValue: { value in
                
            }
            .store(in: &cancellables)

    }

	func updateBundle() {
		onStartFetch()

		let body = UpdateBundlingBody(
			title: title,
			description: desc,
			price: Int(price).orZero(),
			meetingIds: meetingIdArray
		)

		bundlingRepository.provideUpdateBundling(by: (detailData?.id).orEmpty(), body: body)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async { [weak self] in
						if error.statusCode.orZero() == 401 {
							
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
							self?.isBundleUpdated = false
							self?.error = error.message.orEmpty()
						}
					}
				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.isLoading = false
						self?.isBundleUpdated = true
					}
				}
			} receiveValue: { value in

			}
			.store(in: &cancellables)

	}

	func isFieldEmpty() -> Bool {
		title.isEmpty || desc.isEmpty
	}
    
    func routeToBundlingDetail() {
		let viewModel = BundlingDetailViewModel(bundleId: "", meetingIdArray: self.meetingIdArray, backToRoot: self.backToRoot, backToHome: self.backToHome, isTalent: true, isActive: false)
        
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

	func getBundleDetail() {
		onStartRequest()

		bundlingRepository.provideGetDetailBundling(by: bundleId)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							
						} else {
							self?.isLoadingDetail = false
							self?.isErrorDetail = true

							self?.errorDetail = error.message.orEmpty()
						}
					}

				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.isLoadingDetail = false
					}
				}
			} receiveValue: { response in
				DispatchQueue.main.async {[weak self] in
					self?.detailData = response
					self?.title = response.title.orEmpty()
					self?.desc = response.description.orEmpty()
					self?.price = response.price.orEmpty()
					self?.meetingIdArray = (response.meetings ?? []).map({
						$0.id.orEmpty()
					})
				}

			}
			.store(in: &cancellables)
	}

	func onAppear() {
		if isEdit {
			getBundleDetail()
		}
	}

	func routeToCreateBundling() {
		let viewModel = TalentCreateBundlingViewModel(bundleId: self.bundleId, isEdit: true, backToRoot: self.backToRoot, backToHome: self.backToHome, backToBundlingList: {})

		DispatchQueue.main.async { [weak self] in
			self?.route = .createBundling(viewModel: viewModel)
		}
	}
}
