//
//  ChangePhoneViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 24/02/22.
//

import Foundation
import Combine
import CountryPicker

final class ChangePhoneViewModel: ObservableObject {
	
	var backToRoot: () -> Void
	var backToHome: () -> Void
	var backToEditProfile: () -> Void
	
	private var cancellables = Set<AnyCancellable>()
	
	private var stateObservable = StateObservable.shared
	
	private let authRepository: AuthenticationRepository
	
	@Published var route: HomeRouting?

	@Published var countrySelected: Country = Country(phoneCode: "62", isoCode: "ID")
	@Published var isShowingCountryPicker = false
    @Published var isShowSelectChannel = false
	
	@Published var isLoading: Bool = false
	@Published var isError: Bool = false
	@Published var error: HMError?
	@Published var success: Bool = false
	
	@Published var phone = ""
	@Published var isRefreshFailed = false
	
	@Published var fieldError: [FieldError]?
	@Published var isShowError = false

	@Published var selectedChannel: DeliveryOTPVia = .whatsapp
	
	init(
		backToRoot: @escaping (() -> Void),
		backToHome: @escaping (() -> Void),
		backToEditProfile: @escaping (() -> Void),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository()
	) {
		self.backToHome = backToHome
		self.backToRoot = backToRoot
		self.backToEditProfile = backToEditProfile
		self.authRepository = authRepository
		
	}
	
	func onStartRequest() {
		DispatchQueue.main.async {[weak self] in
			self?.success = false
			self?.isLoading = true
			self?.isError = false
			self?.error = nil
			self?.fieldError = nil
			self?.isShowError = false
		}
	}
	
	func getOtpCode() {
		onStartRequest()
		
		var tempPhone = phone
		
		if self.phone.first == "0" {
			tempPhone = tempPhone.replacingCharacters(in: ...phone.startIndex, with: "")
		}
		
		let phones = "+\(countrySelected.phoneCode)" + tempPhone
		let body = ResendOTPChannel(phone: phones, channel: selectedChannel.name)
		
		authRepository
			.changePhone(phone: body)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async { [weak self] in
						if error.statusCode.orZero() != 401 {
							self?.isLoading = false
							self?.isError = true
							
							self?.error = HMError.serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
							
							if error.statusCode.orZero() != 422 && error.statusCode.orZero() != 0 {
								self?.isShowError = true
							}
							
							if error.fields != nil {
								self?.fieldError = error.fields
							}
						} else {
							self?.refreshToken(onComplete: self?.getOtpCode ?? {})
						}
					}
					
				case .finished:
					DispatchQueue.main.async {[weak self] in
						self?.isLoading = false
						self?.success = true
						
						self?.routeToOtp()
					}
				}
			} receiveValue: { _ in
				
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
	
	func routeToOtp() {
		var tempPhone = phone
		
		if self.phone.first == "0" {
			tempPhone = tempPhone.replacingCharacters(in: ...phone.startIndex, with: "")
		}
		
		let phones = "+\(countrySelected.phoneCode)" + tempPhone
		
		let viewModel = ChangePhoneVerifyViewModel(phoneNumber: phones, onBackToRoot: self.backToRoot, backToEditProfile: self.backToEditProfile)
		
		DispatchQueue.main.async {[weak self] in
			self?.route = .changePhoneOtp(viewModel: viewModel)
		}
	}
}
