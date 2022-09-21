//
//  EditProfileViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 23/02/22.
//

import Foundation
import UIKit
import Combine
import SwiftUI
import OneSignal

final class EditProfileViewModel: ObservableObject {

	var backToRoot: () -> Void
	var backToHome: () -> Void

	private var cancellables = Set<AnyCancellable>()
	private let config = Configuration.shared
	private var stateObservable = StateObservable.shared

	private var uploadService: UploadService

	private let userRepository: UsersRepository
	private let authRepository: AuthenticationRepository
	private let professionRepository: ProfessionRepository

	private var availTimer: Timer?

	@Published var showDropDown = false

	@Published var route: HomeRouting?

	@Published var isLoading: Bool = false
	@Published var isError: Bool = false
	@Published var error: HMError?
	@Published var success: Bool = false

	@Published var professionData: ProfessionResponse?
	@Published var userData: Users?

	@Published var constUrl = Configuration.shared.environment.usernameURL

	@Published var professionSelectString = [String]()
	@Published var professionSelectID = [Int]()
	@Published var userPhoto: String?
	@Published var phone = ""

	@Published var userHighlightsImage =  [UIImage(), UIImage(), UIImage()]

	@Published var userHighlights : [String]?
	@Published var userHighlight : String?
	@Published var highlights: [Highlights]?

	@Published var name: String?
	@Published var names = ""
	@Published var username = ""
	@Published var bio = ""

	@Published var isShowPhotoLibrary = false
	@Published var isShowPhotoLibraryHG = [false, false, false]
	@Published var image = UIImage()

	@Published var isSuccessUpdate = false

	@Published var isRefreshFailed = false
	@Published var isUsernameAvail = false
	@Published var usernameInvalid = false

	init(
		backToRoot: @escaping (() -> Void),
		backToHome: @escaping (() -> Void),
		userRepository: UsersRepository = UsersDefaultRepository(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
		professionRepository: ProfessionRepository = ProfessionDefaultRepository(),
		uploadService: UploadService = UploadService()
	) {
		self.backToHome = backToHome
		self.backToRoot = backToRoot
		self.userRepository = userRepository
		self.authRepository = authRepository
		self.professionRepository = professionRepository
		self.uploadService = uploadService

	}

	func onStartFetch() {
		DispatchQueue.main.async {[weak self] in
			self?.isError = false
			self?.isLoading = true
			self?.success = false
			self?.isSuccessUpdate = false
			self?.error = nil
		}
	}

	func startCheckAvail() {
		if username.isValidUsername() {
			if let availTimer = availTimer {
				availTimer.invalidate()
			}
			
			onStartCheckingUsername()

			availTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(usernameAvailabilityChecking), userInfo: nil, repeats: false)
		} else {
			if let availTimer = availTimer {
				availTimer.invalidate()
			}

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

		if username.isValidUsername() {
			if username.isEmpty {
				self.isUsernameAvail = false
			} else {
				let usernameBody = UsernameBody(username: username)

				userRepository
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

	func isAvailableToSaveUser() -> Bool {
		!names.isEmpty
	}

	func isAvailableToSaveTalent() -> Bool {
		!names.isEmpty && (!username.isEmpty && (!usernameInvalid && isUsernameAvail)) || username == userData?.username
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

	func uploadSingleImage() {
		onStartFetch()

		if image != UIImage() {
			uploadService.uploadSingle(image: image) { response, error in
				if error == nil {

					self.uploadService.uploadUserHighlight(image: self.userHighlightsImage) { responses, error in
						if error == nil {
							self.isLoading = false
							self.success = true
							self.updateUser(imageUrl: (response?.url).orEmpty(), userHighlight: responses?.urls ?? [])
						} else {
							self.isError = true
							self.isLoading = false
							self.error = .serverError(code: (error?.statusCode).orZero(), message: (error?.message).orEmpty())
						}
					}

				} else {
					self.isError = true
					self.isLoading = false
					self.error = .serverError(code: (error?.statusCode).orZero(), message: (error?.message).orEmpty())
				}
			}
		} else {
			self.uploadService.uploadUserHighlight(image: self.userHighlightsImage) { responses, error in
				if error == nil {
					self.isLoading = false
					self.success = true
					self.updateUser(imageUrl: "", userHighlight: responses?.urls ?? [])
				} else {
					self.isError = true
					self.isLoading = false
					self.error = .serverError(code: (error?.statusCode).orZero(), message: (error?.message).orEmpty())
				}
			}
		}
	}

	func updateUser(imageUrl: String, userHighlight: [String]) {
		onStartFetch()

		let body = UpdateUser(
			name: names,
			username: username.isEmpty ? nil : username,
			profilePhoto: imageUrl.isEmpty ? nil : imageUrl,
			profileDescription: bio,
			userHighlights: userHighlight.isEmpty ? userHighlights ?? [] : userHighlight,
			professions: professionSelectID.isEmpty ? nil : professionSelectID
		)

		userRepository
			.provideUpdateUser(with: body)
			.sink { result in
				switch result {
				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.isSuccessUpdate = true
						self?.isLoading = false
					}

				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: {
								self?.updateUser(imageUrl: imageUrl, userHighlight: userHighlight)
							})
						} else {
							self?.isError = true
							self?.isLoading = false

							self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						}
					}
				}
			} receiveValue: { _ in

			}
			.store(in: &cancellables)
	}

	func getProfession() {
		onStartFetch()

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

	func onViewAppear(user: Users?) {
		self.username = (user?.username).orEmpty()
		self.names = (user?.name).orEmpty()
		self.name = user?.name
		self.userPhoto = user?.profilePhoto
		self.bio = (user?.profileDescription).orEmpty()
		self.phone = (self.userData?.phone).orEmpty()
	}

	func getUsers() {
		onStartFetch()

		userRepository
			.provideGetUsers()
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.getUsers ?? {})
						} else {
							self?.isLoading = false
							self?.isError = true

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
				self.onViewAppear(user: value)



				if !(value.userHighlights ?? []).isEmpty {
					var tempHG = [UIImage]()
					
					for i in 0..<(value.userHighlights?.count).orZero() {
						self.highlights?.append(value.userHighlights?[i] ?? Highlights())
						self.userHighlight?.append((value.userHighlights?[i].imgUrl).orEmpty())
						tempHG.append((value.userHighlights?[i].imgUrl).orEmpty().load())
					}
					
					if tempHG.count < 3 {
						tempHG.append(UIImage())
						self.userHighlightsImage = tempHG
					} else {
						self.userHighlightsImage = tempHG
					}
				}

			}
			.store(in: &cancellables)

	}

	func routeToChangePhone() {
		let viewModel = ChangePhoneViewModel(backToRoot: self.backToRoot, backToHome: self.backToHome, backToEditProfile: {self.route = nil})

		DispatchQueue.main.async {[weak self] in
			self?.route = .changePhone(viewModel: viewModel)
		}
	}

	func autoLogout() {
		self.backToRoot()
		stateObservable.userType = 0
		stateObservable.isVerified = ""
		stateObservable.refreshToken = ""
		stateObservable.accessToken = ""
		stateObservable.isAnnounceShow = false
		OneSignal.setExternalUserId("")
	}
}
