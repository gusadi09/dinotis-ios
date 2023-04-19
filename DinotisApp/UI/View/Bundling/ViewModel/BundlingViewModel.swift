//
//  BundlingViewModel.swift
//  DinotisApp
//
//  Created by Garry on 30/09/22.
//

import Foundation
import Combine
import UIKit
import SwiftUI
import DinotisData

final class BundlingViewModel: ObservableObject {

	private let bundlingRepository: BundlingRepository
	private let authRepository: AuthenticationRepository

	private var cancellables = Set<AnyCancellable>()
	private var stateObservable = StateObservable.shared
	private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?
    
    var backToRoot: () -> Void
    var backToHome: () -> Void

	@Published var query = BundlingListFilter()

	@Published var isLoading = false
	@Published var isError = false
	@Published var error: String?
	@Published var isRefreshFailed = false
    
    @Published var isShowConfirmAlert = false
    @Published var idToDelete = ""

	@Published var bundlingListData = [BundlingData]()
	@Published var filterList = [BundlingFilterOptions]()
    
    @Published var route: HomeRouting?
    
    @Published var filterSelection = ""
    
    init(
		backToRoot: @escaping (() -> Void),
		backToHome: @escaping (() -> Void),
		bundlingRepository: BundlingRepository = BundlingDefaultRepository(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository()
	) {
        self.backToRoot = backToRoot
        self.backToHome = backToHome
		self.bundlingRepository = bundlingRepository
		self.authRepository = authRepository
    }
    
    func changeFilter(filter: String) {
		DispatchQueue.main.async {[weak self] in
			if let optionLabel = self?.filterList.firstIndex(where: { query in
				query.label.orEmpty() == filter
			}) {
				if filter == (self?.filterList[optionLabel].label).orEmpty() {
					if let isAvail = self?.filterList[optionLabel].queries?.firstIndex(where: { option in
						option.name.orEmpty() == "is_available"
					}) {
						self?.query.isAvailable = (self?.filterList[optionLabel].queries?[isAvail].value).orEmpty()
					} else {
						self?.query.isAvailable = ""
					}
				}

				self?.bundlingListData = []
				self?.query.skip = 0
				self?.query.take = 15
				self?.getBundlingList()
			}
		}
    }

	func onStartRequest() {
		DispatchQueue.main.async {[weak self] in
			self?.isLoading = true
			self?.isError = false
			self?.error = nil
			self?.isRefreshFailed = false
		}

	}
    
    func getBundlingList() {
        onStartRequest()
        
        bundlingRepository.provideGetBundlingList(query: query)
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
                DispatchQueue.main.async {[weak self] in
                    withAnimation {
                        if self?.filterSelection.isEmpty ?? false {
                            self?.filterSelection = (response.filters?.options?.first?.label).orEmpty()
                        }
                        
                        self?.bundlingListData += response.data ?? []
                        self?.filterList = response.filters?.options ?? []
                        
                        if response.nextCursor == nil {
                            self?.query.skip = 0
                            self?.query.take = 15
                        }
                    }
                }
                
            }
            .store(in: &cancellables)
    }
    
    func deleteBundling(bundleId: String) {
        onStartRequest()
        
        bundlingRepository.provideDeleteBundling(by: bundleId)
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
                        withAnimation {
                            self?.isLoading = false
                            self?.bundlingListData = []
                            self?.getBundlingList()
                        }
                    }
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }

    func onAppear() {
        DispatchQueue.main.async {[weak self] in
            self?.getBundlingList()
        }
    }
    
    func routeToCreateBundling() {
		let viewModel = TalentCreateBundlingViewModel(isEdit: false, backToRoot: self.backToRoot, backToHome: self.backToHome, backToBundlingList: {self.route = nil})
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .createBundling(viewModel: viewModel)
        }
    }
    
	func talentRouteToBundlingDetail(bundleId: String) {
		let viewModel = BundlingDetailViewModel(bundleId: bundleId, meetingIdArray: [], backToRoot: self.backToRoot, backToHome: {self.route = nil}, isTalent: true, isActive: false)
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .bundlingDetail(viewModel: viewModel)
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

	func routeToBundlingForm(bundleId: String) {
		let viewModel = BundlingFormViewModel(bundleId: bundleId, meetingIdArray: [], isEdit: true, backToRoot: self.backToRoot, backToHome: self.backToHome, backToBundlingList: { self.route = nil })

		DispatchQueue.main.async { [weak self] in
			self?.route = .bundlingForm(viewModel: viewModel)
		}
	}
}
