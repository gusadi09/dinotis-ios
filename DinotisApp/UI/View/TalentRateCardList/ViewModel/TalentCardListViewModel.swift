//
//  TalentCardListViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 03/10/22.
//

import Foundation
import Combine
import OneSignal
import SwiftUI
import DinotisData

final class TalentCardListViewModel: ObservableObject {

	private let deleteRateCardUseCase: DeleteRateCardUseCase
	private let getRateCardUseCase: GetRateCardUseCase
	private let authRepository: AuthenticationRepository
	private var cancellables = Set<AnyCancellable>()
	private var stateObservable = StateObservable.shared
	private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?
    
    var backToRoot: () -> Void
    var backToHome: () -> Void

	@Published var isLoading = false
	@Published var isLoadingDelete = false
	@Published var isError = false
	@Published var success = false
	@Published var error: String?

	@Published var isShowDeleteAlert = false
	@Published var deleteId = ""

	@Published var isRefreshFailed = false

	@Published var query = GeneralParameterRequest(skip: 0, take: 15)

	@Published var rateCardList = [RateCardResponse]()
    
    @Published var route: HomeRouting?
    
	init(
		backToRoot: @escaping (() -> Void),
		backToHome: @escaping (() -> Void),
		deleteRateCardUseCase: DeleteRateCardUseCase = DeleteRateCardDefaultUseCase(),
		getRateCardUseCase: GetRateCardUseCase = GetRateCardDefaultUseCase(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository()
	) {
		self.backToRoot = backToRoot
		self.backToHome = backToHome
		self.deleteRateCardUseCase = deleteRateCardUseCase
		self.getRateCardUseCase = getRateCardUseCase
		self.authRepository = authRepository
	}
    
	func routeToCreateRateCardForm(isEdit: Bool, id: String) {
		let viewModel = CreateTalentRateCardFormViewModel(isEdit: isEdit, rateCardId: id, backToRoot: self.backToRoot, backToHome: self.backToHome)
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .talentCreateRateCardForm(viewModel: viewModel)
        }
    }

	func routeToRoot() {
		stateObservable.userType = 0
		stateObservable.isVerified = ""
		stateObservable.refreshToken = ""
		stateObservable.accessToken = ""
		stateObservable.isAnnounceShow = false
		OneSignal.setExternalUserId("")
		backToRoot()
	}

	func onStartRequest(isDelete: Bool) {
		DispatchQueue.main.async {[weak self] in
			self?.isLoading = true
			if isDelete {
				self?.isLoadingDelete = true
			}
			self?.isError = false
			self?.error = nil
			self?.success = false
			self?.isRefreshFailed = false
		}

	}

	func handleDefaultError(error: Error) {
		DispatchQueue.main.async { [weak self] in
			self?.isLoading = false

			if let error = error as? ErrorResponse {

				if error.statusCode.orZero() == 401 {
					self?.error = error.message.orEmpty()
					self?.isRefreshFailed.toggle()
				} else {
					self?.error = error.message.orEmpty()
					self?.isError = true
				}
			} else {
				self?.isError = true
				self?.error = error.localizedDescription
			}

		}
	}

	func getRateCardList() async {
		onStartRequest(isDelete: false)

		let result = await getRateCardUseCase.execute(with: query)

		switch result {
		case .success(let success):
			DispatchQueue.main.async { [weak self] in
				self?.isLoading = false

				withAnimation {
					self?.rateCardList += success.data ?? []

					if success.nextCursor == nil {
						self?.query.skip = 0
						self?.query.take = 15
					}
				}
			}
		case .failure(let failure):
			handleDefaultError(error: failure)
		}
	}

	func handleDefaultErrorDelete(error: Error) {
		DispatchQueue.main.async { [weak self] in
			self?.isLoadingDelete = false

			if let error = error as? ErrorResponse {

				if error.statusCode.orZero() == 401 {
					self?.error = error.message.orEmpty()
					self?.isRefreshFailed.toggle()
				} else {
					self?.error = error.message.orEmpty()
					self?.isError = true
				}
			} else {
				self?.isError = true
				self?.error = error.localizedDescription
			}

		}
	}

	func onDeleteCard() {
		Task {
			await deleteRateCard()
		}
	}

	func deleteRateCard() async {
		onStartRequest(isDelete: true)

		let result = await deleteRateCardUseCase.execute(for: deleteId)

		switch result {
		case .success(_):
			DispatchQueue.main.async { [weak self] in
				self?.isLoadingDelete = false
				self?.success = true

				withAnimation {
					self?.rateCardList = []
					self?.query.take = 15
					self?.query.skip = 0
				}
			}

			await getRateCardList()
		case .failure(let failure):
			handleDefaultErrorDelete(error: failure)
		}
	}

	func onAppear() {
		Task {
			await getRateCardList()
		}
	}

	func onRefresh() async {
		await getRateCardList()
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
