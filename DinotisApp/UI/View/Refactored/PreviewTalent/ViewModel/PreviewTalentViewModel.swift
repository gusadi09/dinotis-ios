//
//  PreviewTalentViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 23/04/22.
//

import Foundation
import Combine
import UIKit

final class PreviewTalentViewModel: ObservableObject {

	var backToRoot: () -> Void

	private var cancellables = Set<AnyCancellable>()
	private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?

	private var stateObservable = StateObservable.shared
	private let userRepository: UsersRepository
	private let authRepository: AuthenticationRepository

	@Published var photoProfile: String?
	@Published var profileBanner = [Highlights]()
	@Published var profileBannerContent = [ProfileBannerImage]()

	@Published var isRefreshFailed = false

	@Published var nameOfUser: String?
	@Published var userData: Users?

	@Published var showingPasswordAlert = false

	@Published var route: HomeRouting?

	@Published var showMenuCard = false

	@Published var isError: Bool = false
	@Published var error: HMError?
	@Published var success: Bool = false

	@Published var isLoading = false

	init(
		backToRoot: @escaping (() -> Void),
		userRepository: UsersRepository = UsersDefaultRepository(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository()
	) {
		self.backToRoot = backToRoot
		self.userRepository = userRepository
		self.authRepository = authRepository
	}

	func onStartedFetch() {
		DispatchQueue.main.async {[weak self] in
			self?.isError = false
			self?.isLoading = true
			self?.error = nil
			self?.success = false
		}
	}

	func onStartRefresh() {
		self.isRefreshFailed = false
		self.isLoading = true
		self.success = false
		self.error = nil
	}

	func refreshToken(onComplete: @escaping (() -> Void)) {
		onStartRefresh()

		let refreshToken = authRepository.loadFromKeychain(forKey: KeychainKey.refreshToken)

		authRepository
			.refreshToken(with: refreshToken)
			.sink { result in
				switch result {
				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.success = true
						self?.isLoading = false
						onComplete()
					}

				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						self?.isRefreshFailed = true
						self?.isLoading = false
						self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
					}
				}
			} receiveValue: { value in
				self.stateObservable.refreshToken = value.refreshToken
				self.stateObservable.accessToken = value.accessToken
			}
			.store(in: &cancellables)

	}

	func getUsers() {
		onStartedFetch()

		userRepository
			.provideGetUsers()
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.getUsers ?? {})
						} else {
							self?.isError = true
							self?.isLoading = false

							self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						}
					}

				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.success = true
						self?.isLoading = false
					}
				}
			} receiveValue: { value in
				self.userData = value
				self.nameOfUser = value.name
				self.photoProfile = value.profilePhoto

				self.profileBanner = value.userHighlights ?? []
				var temp = [ProfileBannerImage]()

				if !(value.userHighlights ?? []).isEmpty {
					for item in value.userHighlights ?? [] {
						temp.append(
							ProfileBannerImage(
								content: item
							)
						)
					}

					self.profileBannerContent = temp
				}
			}
			.store(in: &cancellables)

	}

	@objc func onScreenAppear() async {
		getUsers()
	}

	func use(for scrollView: UIScrollView, onValueChanged: @escaping ((UIRefreshControl) -> Void)) {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(
			self,
			action: #selector(self.onValueChangedAction),
			for: .valueChanged
		)
		scrollView.refreshControl = refreshControl
		self.onValueChanged = onValueChanged
	}

	@objc private func onValueChangedAction(sender: UIRefreshControl) {
		Task.init {
			await onScreenAppear()
			self.onValueChanged?(sender)
		}
	}
}
