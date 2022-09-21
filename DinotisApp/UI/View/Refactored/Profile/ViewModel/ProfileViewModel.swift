//
//  ProfileViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 23/02/22.
//

import Foundation
import Combine
import SwiftUI
import OneSignal

final class ProfileViewModel: ObservableObject {

	private let userRepository: UsersRepository
	private let authRepository: AuthenticationRepository

	var backToRoot: () -> Void
	var backToHome: () -> Void

	@Published var urlLinked = Configuration.shared.environment.usernameURL
	@Published var isPresentDeleteModal = false

	private var cancellables = Set<AnyCancellable>()

	private var stateObservable = StateObservable.shared

	@Published var route: HomeRouting?
	@Published var data: Users?

	@Published var isLoading: Bool = false
	@Published var isError: Bool = false
	@Published var error: HMError?
	@Published var success: Bool = false

	@Published var showCopied = false

	@Published var userPhotos: String?
	@Published var names: String?

	@Published var isRefreshFailed = false

	@Published var logoutPresented = false

	@Published var profesionSelect = [ProfessionElement]()
	@Published var successDelete = false

	init(
		backToRoot: @escaping (() -> Void),
		backToHome: @escaping (() -> Void),
		userRepository: UsersRepository = UsersDefaultRepository(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository()
	) {
		self.backToHome = backToHome
		self.backToRoot = backToRoot
		self.userRepository = userRepository
		self.authRepository = authRepository

	}

	func toggleDeleteModal() {
		self.isPresentDeleteModal.toggle()
	}

	func onStartedFetch() {
		DispatchQueue.main.async {[weak self] in
			self?.isError = false
			self?.isLoading = true
			self?.error = nil
			self?.success = false
			self?.successDelete = false
		}
	}

	func copyURL() {
		UIPasteboard.general.string = userLink()

		withAnimation {
			showCopied = true
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
				withAnimation {
					self?.showCopied = false
				}
			}
		}
	}

	func presentLogout() {
		self.logoutPresented.toggle()
	}

	func userLink() -> String {
		urlLinked + (data?.username).orEmpty()
	}

	func nameOfUser() -> String {
		(self.data?.name).orEmpty()
	}

	func isUserVerified() -> Bool {
		(self.data?.isVerified) ?? false
	}

	func userPhoto() -> String {
		(self.data?.profilePhoto).orEmpty()
	}
	
	func userProfession() -> [ProfessionElement] {
		(self.data?.professions) ?? []
	}

	func userBio() -> String {
		(self.data?.profileDescription).orEmpty()
	}

	func openWhatsApp() {
		if let waurl = URL(string: "https://wa.me/6281318506068") {
			if UIApplication.shared.canOpenURL(waurl) {
				UIApplication.shared.open(waurl, options: [:], completionHandler: nil)
			}
		}
	}

	func routeToChangePass() {
		let viewModel = ChangesPasswordViewModel(backToRoot: self.backToRoot)

		DispatchQueue.main.async { [weak self] in
			self?.route = .changePassword(viewModel: viewModel)
		}
	}

	func routeToPreviewProfile() {
		let viewModel = PreviewTalentViewModel(backToRoot: self.backToRoot)

		DispatchQueue.main.async { [weak self] in
			self?.route = .previewTalent(viewModel: viewModel)
		}
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
				self.data = value
				self.userPhotos = value.profilePhoto
				self.names = value.name
			}
			.store(in: &cancellables)

	}

	func deleteAccount() {
		onStartedFetch()

		userRepository
			.provideDeleteUserAccount()
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.deleteAccount ?? {})
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
			} receiveValue: { [weak self] _ in
				self?.successDelete.toggle()
			}
			.store(in: &cancellables)

	}

	func routeBackLogout() {
		backToRoot()
		stateObservable.userType = 0
		stateObservable.isVerified = ""
		stateObservable.refreshToken = ""
		stateObservable.accessToken = ""
		stateObservable.isAnnounceShow = false
		OneSignal.setExternalUserId("")
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

	func routeToEditProfile() {

		let viewModel = EditProfileViewModel(backToRoot: self.backToRoot, backToHome: self.backToHome)

		DispatchQueue.main.async { [weak self] in
			if self?.stateObservable.userType == 2 {
				self?.route = .editTalentProfile(viewModel: viewModel)
			} else {
				self?.route = .editUserProfile(viewModel: viewModel)
			}
		}
	}

	func routeToWallet() {
		let viewModel = TalentWalletViewModel(backToRoot: self.backToRoot, backToHome: {self.route = nil})

		DispatchQueue.main.async { [weak self] in
			self?.route = .talentWallet(viewModel: viewModel)
		}
	}
}
