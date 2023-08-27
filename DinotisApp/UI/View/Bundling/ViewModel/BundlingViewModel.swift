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

	private let authRepository: AuthenticationRepository
    
    private let getBundlingListUseCase: GetBundlingListUseCase
    private let deleteBundlingUseCase: DeleteBundlingUseCase

	private var cancellables = Set<AnyCancellable>()
	private var stateObservable = StateObservable.shared
	private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?
    
    var backToHome: () -> Void

	@Published var query = BundlingListFilter(take: 15, skip: 0)

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
		backToHome: @escaping (() -> Void),
		bundlingRepository: BundlingRepository = BundlingDefaultRepository(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
        getBundlingListUseCase: GetBundlingListUseCase = GetBundlingListDefaultUseCase(),
        deleteBundlingUseCase: DeleteBundlingUseCase = DeleteBundlingDefaultUseCase()
	) {
        self.backToHome = backToHome
		self.authRepository = authRepository
        self.getBundlingListUseCase = getBundlingListUseCase
        self.deleteBundlingUseCase = deleteBundlingUseCase
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
                Task {
                    await self?.getBundlingList()
                }
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
    
    func handleDefaultError(error: ErrorResponse) {
        DispatchQueue.main.async {[weak self] in
            if error.statusCode.orZero() == 401 {
                
            } else {
                self?.isLoading = false
                self?.isError = true

                self?.error = error.message.orEmpty()
            }
        }
    }
    
    func getBundlingList() async {
        onStartRequest()
        
        let result = await getBundlingListUseCase.execute(query: query)
        
        switch result {
        case .success(let response):
            DispatchQueue.main.async {[weak self] in
                withAnimation {
                    self?.isLoading = false
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
        case .failure(let error):
            guard let error = error as? ErrorResponse else { return }
            handleDefaultError(error: error)
        }
    }
    
    func defaultDeleteBundling(bundleId: String) {
        Task {
            await deleteBundling(bundleId: bundleId)
        }
    }
    
    func deleteBundling(bundleId: String) async {
        onStartRequest()
        
        let result = await deleteBundlingUseCase.execute(by: bundleId)
        
        switch result {
        case .success:
            DispatchQueue.main.async { [weak self] in
                withAnimation {
                    self?.isLoading = false
                    self?.bundlingListData = []
                    Task {
                        await self?.getBundlingList()
                    }
                }
            }
            
        case .failure(let error):
            guard let error = error as? ErrorResponse else { return }
            handleDefaultError(error: error)
        }
    }

    func onAppear() {
        DispatchQueue.main.async {[weak self] in
            Task {
                await self?.getBundlingList()
            }
        }
    }
    
    func routeToCreateBundling() {
		let viewModel = TalentCreateBundlingViewModel(isEdit: false, backToHome: self.backToHome, backToBundlingList: {self.route = nil})
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .createBundling(viewModel: viewModel)
        }
    }
    
	func talentRouteToBundlingDetail(bundleId: String) {
		let viewModel = BundlingDetailViewModel(bundleId: bundleId, meetingIdArray: [], backToHome: {self.route = nil}, isTalent: true, isActive: false)
        
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
		let viewModel = BundlingFormViewModel(bundleId: bundleId, meetingIdArray: [], isEdit: true, backToHome: self.backToHome, backToBundlingList: { self.route = nil })

		DispatchQueue.main.async { [weak self] in
			self?.route = .bundlingForm(viewModel: viewModel)
		}
	}
}
