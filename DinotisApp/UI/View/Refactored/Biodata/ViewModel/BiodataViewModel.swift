//
//  BiodataViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/02/22.
//

import Foundation
import Combine
import SwiftUI

final class BiodataViewModel: ObservableObject {

	private let stateObservable = StateObservable()

	private let repository: UsersRepository
	private let authRepository: AuthenticationRepository
	private let professionRepository: ProfessionRepository

	private var usernameTimer: Timer?
	private var availTimer: Timer?

	private var cancellables = Set<AnyCancellable>()

	var backToRoot: () -> Void

	@Published var name = ""
	@Published var bio = ""
    @Published var password = ""
    @Published var confirmPassword = ""

	@Published var profesionSelect = [String]()
	@Published var profesionSelectID = [Int]()
	@Published var url = ""
	@Published var otherJob = ""

	@Published var constUrl = Configuration.shared.environment.usernameURL

	@Published var showDropDown = false

	@Published var route: PrimaryRouting?

	@Published var isLoading: Bool = false
	@Published var isError: Bool = false
	@Published var error: HMError?
	@Published var success: Bool = false

	@Published var isUsernameAvail = false

	@Published var isRefreshFailed = false

	@Published var professionData: ProfessionResponse?
	@Published var userData: Users?
	@Published var usernameInvalid = false
    @Published var isPassShow = false
    @Published var isRepeatPassShow = false

	init(
		backToRoot: @escaping (() -> Void),
		repository: UsersRepository = UsersDefaultRepository(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
		professionRepository: ProfessionRepository = ProfessionDefaultRepository()
	) {
		self.backToRoot = backToRoot
		self.repository = repository
		self.authRepository = authRepository
		self.professionRepository = professionRepository

	}

	func showingDropdown() {
		withAnimation(.spring()) {
			self.showDropDown.toggle()
		}
	}

	func onStartRequest() {
		DispatchQueue.main.async {[weak self] in
			self?.isLoading = true
			self?.isError = false
			self?.error = nil
			self?.success = false
		}
	}

	func startCheckingTimer() {
		if let timer = usernameTimer {
			timer.invalidate()
		}

		onStartCheckingUsername()

		usernameTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(usernameSuggestion), userInfo: nil, repeats: false)
	}

	func startCheckAvail() {
		if let availTimer = availTimer {
			availTimer.invalidate()
		}

		if url.isValidUsername() {
			onStartCheckingUsername()

			availTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(usernameAvailabilityChecking), userInfo: nil, repeats: false)
		} else {
			self.usernameInvalid = true
		}
	}

	func onStartCheckingUsername() {
		self.success = false
		self.isError = false
		self.error = nil
		self.isUsernameAvail = false
		self.usernameInvalid = false
	}
	
	@objc func usernameAvailabilityChecking() {
		onStartCheckingUsername()
		
		if url.isValidUsername() {
			if url.isEmpty {
				self.isUsernameAvail = false
			} else {
				let usernameBody = UsernameBody(username: url)
				
				repository
					.provideUsernameAvailability(with: usernameBody)
					.sink { result in
						switch result {
							case .finished:
								DispatchQueue.main.async { [weak self] in
									self?.isUsernameAvail = true
								}
								
							case .failure(let error):
								DispatchQueue.main.async {[weak self] in
									if error.statusCode.orZero() == 401 {
										self?.refreshToken(onComplete: self?.usernameAvailabilityChecking ?? {})
									} else {
										self?.isUsernameAvail = false
									}
								}
						}
					} receiveValue: { value in
						self.isUsernameAvail = !value.message.isEmpty
					}
					.store(in: &cancellables)
			}
		} else {
			self.usernameInvalid = true
		}

	}

	func isAvailableToSaveTalent() -> Bool {
		!name.isEmpty && !url.isEmpty && (isUsernameAvail && !usernameInvalid) && !password.isEmpty && !confirmPassword.isEmpty && isPasswordSame()
	}

	func isAvailableToSaveUser() -> Bool {
        !name.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && isPasswordSame()
	}
    
    func isPasswordSame() -> Bool {
        password == confirmPassword
    }

	func usernameAvailabilityCheck(by username: UsernameBody) {
		onStartCheckingUsername()

		if username.username.isEmpty {
			self.isUsernameAvail = false
		} else {
			repository
				.provideUsernameAvailability(with: username)
				.sink { result in
					switch result {
						case .finished:
							DispatchQueue.main.async { [weak self] in
								self?.isUsernameAvail = true
							}

						case .failure(let error):
							DispatchQueue.main.async {[weak self] in
								if error.statusCode.orZero() == 401 {
									self?.refreshToken(onComplete: {
										self?.usernameAvailabilityCheck(by: username)
									})
								} else {
									self?.isUsernameAvail = false

								}
							}
					}
				} receiveValue: { value in
					self.isUsernameAvail = !value.message.isEmpty
				}
				.store(in: &cancellables)
		}

	}

	@objc func usernameSuggestion() {
		onStartCheckingUsername()

		if name.isEmpty {
			url = ""
			isUsernameAvail = false
		} else {
			let suggestBody = SuggestionBody(name: name)

			repository
				.provideUsernameSuggest(with: suggestBody)
				.sink { result in
					switch result {
						case .finished:
							DispatchQueue.main.async { [weak self] in
								self?.success = true
							}

						case .failure(let error):
							DispatchQueue.main.async {[weak self] in
								if error.statusCode.orZero() == 401 {
									self?.refreshToken(onComplete: self?.usernameSuggestion ?? {})
								} else {
									self?.isError = true

									self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
								}
							}
					}
				} receiveValue: {[weak self] value in
					self?.url = value.username

					self?.usernameAvailabilityCheck(by: value)
				}
				.store(in: &cancellables)
		}

	}

	func getProfession() {
		onStartRequest()

		professionRepository
			.provideGetProfession()
			.sink { result in
				switch result {
					case .finished:
						DispatchQueue.main.async { [weak self] in
							self?.success = true
							self?.isLoading = false
						}

					case .failure(let error):
						DispatchQueue.main.async {[weak self] in
							if error.statusCode.orZero() == 401 {
								self?.refreshToken(onComplete: self?.getProfession ?? {})
							} else {
								self?.isError = true
								self?.isLoading = false

								self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
							}
						}
				}
			} receiveValue: { value in
				self.professionData = value
			}
			.store(in: &cancellables)

	}

	func updateUsers() {
		onStartRequest()

        let body = UpdateUser(
            name: name,
            username: url.isEmpty ? nil : url,
            profileDescription: bio,
            professions: profesionSelectID.isEmpty ? nil : profesionSelectID,
            password: password.isEmpty ? nil : password,
            confirmPassword: confirmPassword.isEmpty ? nil : confirmPassword
        )

		repository
			.provideUpdateUser(with: body)
			.sink { result in
				switch result {
					case .finished:
						DispatchQueue.main.async { [weak self] in
							self?.success = true
							self?.isLoading = false
						}

					case .failure(let error):
						DispatchQueue.main.async {[weak self] in
							if error.statusCode.orZero() == 401 {
								self?.refreshToken(onComplete: self?.updateUsers ?? {})
							} else {
								self?.isError = true
								self?.isLoading = false
								
								self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
							}
						}
				}
			} receiveValue: { _ in
				self.routingToHome()
			}
			.store(in: &cancellables)

	}

	func routingToHome() {
		DispatchQueue.main.async { [weak self] in

			if self?.stateObservable.userType == 2 {
				let viewModel = TalentHomeViewModel(backToRoot: self?.backToRoot ?? {})
				self?.route = .homeTalent(viewModel: viewModel)
			} else {
				let viewModel = UserHomeViewModel(backToRoot: self?.backToRoot ?? {})
				self?.route = .homeUser(viewModel: viewModel)
			}
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
		onStartRequest()

		repository
			.provideGetUsers()
			.sink { result in
				switch result {
					case .finished:
						DispatchQueue.main.async { [weak self] in
							self?.success = true
							self?.isLoading = false
						}

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
				}
			} receiveValue: { value in
				self.userData = value

				if value.name.orEmpty().isEmpty {
					self.name = ""
				} else {
					self.name = value.name.orEmpty()
				}

				if value.profileDescription.orEmpty().isEmpty {
					self.bio = ""
				} else {
					self.bio = value.profileDescription.orEmpty()
				}
			}
			.store(in: &cancellables)

	}
}
