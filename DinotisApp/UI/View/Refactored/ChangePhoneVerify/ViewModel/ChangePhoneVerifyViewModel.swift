//
//  ChangePhoneVerifyViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 24/02/22.
//

import Foundation
import Combine

final class ChangePhoneVerifyViewModel: ObservableObject {
	
	private let repository: AuthenticationRepository
	
	private var cancellables = Set<AnyCancellable>()
	
	private var stateObservable = StateObservable.shared
	
	@Published var timeRemaining = 60
	@Published var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	@Published var isActive = false
	@Published var timesUp = false
	@Published var selectedChannel: DeliveryOTPVia = .whatsapp
	
	@Published var isLoading: Bool = false
	@Published var isError: Bool = false
	@Published var error: HMError?
	@Published var success: Bool = false
	
	@Published var phoneNumber: String
	
	@Published var isRefreshFailed = false
	
	var onBackToRoot: () -> Void
	var backToEditProfile: () -> Void
	
	init(
		phoneNumber: String,
		onBackToRoot: @escaping (() -> Void),
		backToEditProfile: @escaping (() -> Void),
		repository: AuthenticationRepository = AuthenticationDefaultRepository(),
		userRepository: UsersRepository = UsersDefaultRepository()
	) {
		self.phoneNumber = phoneNumber
		self.onBackToRoot = onBackToRoot
		self.backToEditProfile = backToEditProfile
		self.repository = repository
		
	}
	
	func onReceiveTimer() {
		if self.timeRemaining > 0 {
			self.timeRemaining -= 1
		} else {
			self.isActive = true
		}
	}
	
	func validateOTP(by otp: String) {
		if otp.count == 6 {
			
			let body = VerifyBody(phone: phoneNumber, otp: otp)
			
			otpVerification(body: body)
		}
	}
	
	func onStartFetch() {
		DispatchQueue.main.async {[weak self] in
			self?.isLoading = true
			self?.isError = false
			self?.error = nil
			self?.success = false
		}
	}
	
	func otpVerification(body: VerifyBody) {
		onStartFetch()
		
		repository
			.changePhoneVerify(params: body)
			.sink { result in
				switch result {
				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.success = true
						self?.isLoading = false
						
						self?.backToEditProfile()
					}
					
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						
						if error.statusCode == 401 {
							self?.refreshToken(onComplete: {
								self?.otpVerification(body: body)
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
	
	func resendOtp() {
		onStartFetch()
		
		let phone = ResendOTPChannel(phone: phoneNumber, channel: selectedChannel.name)
		
		repository
			.resendOtp(with: phone)
			.sink { result in
				switch result {
				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.success = true
						self?.isLoading = false
					}
					
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						self?.isError = true
						self?.isLoading = false
						self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						
					}
				}
			} receiveValue: { _ in
				self.timeRemaining = 60
				self.isActive = false
			}
			.store(in: &cancellables)
	}
	
	func onStartRefresh() {
		self.isRefreshFailed = false
		self.isLoading = true
		self.success = false
		self.error = nil
	}
	
	func refreshToken(onComplete: @escaping (() -> Void)) {
		onStartRefresh()
		
		let refreshToken = repository.loadFromKeychain(forKey: KeychainKey.refreshToken)
		
		repository
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
}
