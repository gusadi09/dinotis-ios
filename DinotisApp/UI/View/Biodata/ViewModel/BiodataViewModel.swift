//
//  BiodataViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/02/22.
//

import Foundation
import Combine
import SwiftUI
import DinotisDesignSystem
import DinotisData

final class BiodataViewModel: ObservableObject {

	private let stateObservable = StateObservable()

	private let getUserUseCase: GetUserUseCase
    private let editUserUseCase: EditUserUseCase
    private let usernameAvailabilityCheckingUseCase: UsernameAvailabilityCheckingUseCase
    private let usernameSuggestionUseCase: UsernameSuggestionUseCase
	private let professionListUseCase: ProfessionListUseCase

	private var usernameTimer: Timer?
	private var availTimer: Timer?

	private var cancellables = Set<AnyCancellable>()

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
	@Published var error: String?
	@Published var success: Bool = false
    @Published var isSuccessUpdated = false

	@Published var isUsernameAvail = false
    
    @Published var isSecure = true
    @Published var isRepasswordSecure = true

	@Published var nameError: [String]?
    @Published var usernameError: [String]?
    @Published var passwordError: [String]?
	@Published var repasswordError: [String]?
	@Published var bioError: [String]?
	@Published var professionError: [String]?

	@Published var isRefreshFailed = false

	@Published var professionData: ProfessionResponse?
	@Published var userData: UserResponse?
	@Published var usernameInvalid = false
    @Published var isPassShow = false
    @Published var isRepeatPassShow = false

	init(
		getUserUseCase: GetUserUseCase = GetUserDefaultUseCase(),
        editUserUseCase: EditUserUseCase = EditUserDefaultUseCase(),
        usernameSuggestionUseCase: UsernameSuggestionUseCase = UsernameSuggestionDefaultUseCase(),
        usernameAvailabilityCheckingUseCase: UsernameAvailabilityCheckingUseCase = UsernameAvailabilityCheckingDefaultUseCase(),
        professionListUseCase: ProfessionListUseCase = ProfessionListDefaultUseCase()
	) {
		self.getUserUseCase = getUserUseCase
        self.editUserUseCase = editUserUseCase
        self.usernameSuggestionUseCase = usernameSuggestionUseCase
        self.usernameAvailabilityCheckingUseCase = usernameAvailabilityCheckingUseCase
		self.professionListUseCase = professionListUseCase

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
            self?.isSuccessUpdated = false
            self?.usernameError = nil
            self?.passwordError = nil
			self?.repasswordError = nil
			self?.nameError = nil
		}
	}

	func startCheckingTimer() {
		if let timer = usernameTimer {
			timer.invalidate()
		}

		onStartCheckingUsername()

		usernameTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(usernameSuggestion), userInfo: nil, repeats: false)
	}
    
    func openWhatsApp() {
        if let waurl = URL(string: "https://wa.me/6281318506068") {
            if UIApplication.shared.canOpenURL(waurl) {
                UIApplication.shared.open(waurl, options: [:], completionHandler: nil)
            }
        }
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
		self.usernameError = nil
	}
    
    func handleDefaultErrorUsernameChecking(error: Error) {
        DispatchQueue.main.async { [weak self] in
            
            if let error = error as? ErrorResponse {

                if error.statusCode.orZero() == 401 {
                    self?.error = error.message.orEmpty()
                    self?.isRefreshFailed.toggle()
                } else {
                    self?.isUsernameAvail = false
                    self?.usernameError = [LocalizableText.alertFormUsernameTaken]
                }
            } else {
                self?.isError = true
                self?.error = error.localizedDescription
            }

        }
    }
    
    func checkUsernameAvailable() async {
        let usernameBody = UsernameAvailabilityRequest(username: url)
        
        let result = await usernameAvailabilityCheckingUseCase.execute(with: usernameBody)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.isUsernameAvail = true
                self?.isUsernameAvail = !(success.message.orEmpty()).isEmpty
            }
        case .failure(let failure):
            handleDefaultErrorUsernameChecking(error: failure)
        }
    }
	
	@objc func usernameAvailabilityChecking() {
		onStartCheckingUsername()
		
		if url.isValidUsername() {
			if url.isEmpty {
				self.isUsernameAvail = false
            } else {
                Task {
                    await checkUsernameAvailable()
                }
            }
		} else {
			self.usernameInvalid = true
		}

	}

	func isAvailableToSaveTalent() -> Bool {
        withAnimation {
            !(name.isEmpty) && !url.isEmpty && (isUsernameAvail && !usernameInvalid) && !password.isEmpty && !confirmPassword.isEmpty
        }
	}

	func isAvailableToSaveUser() -> Bool {
        withAnimation {
			!(name.isEmpty) && !password.isEmpty && !confirmPassword.isEmpty
        }
	}
    
    func isPasswordSame() -> Bool {
        password == confirmPassword
    }
    
    func addUsernameError() {
        if name.count < 3 {
			usernameError?.append(LocalizableText.alertFormNameCharacterMinimum)
        } else {
            usernameError = nil
        }
    }

	func usernameAvailabilityCheck(by username: UsernameAvailabilityResponse) {
		onStartCheckingUsername()

        if username.username.orEmpty().isEmpty {
			self.isUsernameAvail = false
		} else {
            Task {
                await checkUsernameAvailable()
            }
		}

	}
    
    func checkUsernameSuggest() async {
        let suggestBody = UsernameSuggestionRequest(name: name)
        
        let result = await usernameSuggestionUseCase.execute(with: suggestBody)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.url = success.username.orEmpty()
                self?.usernameAvailabilityCheck(by: success)
            }
            
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    func onCheckSuggest() {
        Task {
            await checkUsernameSuggest()
        }
    }

	@objc func usernameSuggestion() {
		onStartCheckingUsername()

		if name.isEmpty {
			url = ""
			isUsernameAvail = false
		} else {
            onCheckSuggest()
		}

	}

	func getProfession() async {
		onStartRequest()
        
        let result = await professionListUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoading = false
                self?.professionData = success
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
	}
    
    func handleDefaultErrorEdit(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false

            if let error = error as? ErrorResponse {

                if error.statusCode.orZero() == 401 {
                    self?.error = error.message.orEmpty()
                    self?.isRefreshFailed.toggle()
                } else if error.statusCode.orZero() == 422 {
                    if let nameError = error.fields?.filter({ $0.name.orEmpty() == "name" }) {
                        self?.nameError = nameError.compactMap({
                            $0.error.orEmpty()
                        })
                    }

                    if let bioError = error.fields?.filter({ $0.name.orEmpty() == "profileDescription" }) {
                        self?.bioError = bioError.compactMap({
                            $0.error.orEmpty()
                        })
                    }

                    if let professionError = error.fields?.filter({ $0.name.orEmpty() == "profession" }) {
                        self?.professionError = professionError.compactMap({
                            $0.error.orEmpty()
                        })
                    }

                    if let usernameError = error.fields?.filter({ $0.name.orEmpty() == "username" }) {
                        self?.usernameError = usernameError.compactMap({
                            $0.error.orEmpty()
                        })
                    }

                    if let passwordError = error.fields?.filter({ $0.name.orEmpty() == "password" }) {
                        self?.passwordError = passwordError.compactMap({
                            $0.error.orEmpty()
                        })
                    }

                    if let repasswordError = error.fields?.filter({ $0.name.orEmpty() == "confirmPassword"}) {
                        self?.repasswordError = repasswordError.compactMap({
                            $0.error.orEmpty()
                        })
                    }
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

	func updateUsers() async {
		onStartRequest()

        let body = EditUserRequest(
            name: name,
            username: url.isEmpty ? nil : url,
            profilePhoto: nil,
            profileDescription: bio,
            userHighlights: nil,
            professions: profesionSelectID.isEmpty ? nil : profesionSelectID,
            password: password.isEmpty ? nil : password,
            confirmPassword: confirmPassword.isEmpty ? nil : confirmPassword
        )
        
        let result = await editUserUseCase.execute(with: body)
        
        switch result {
        case .success(_):
            DispatchQueue.main.async { [weak self] in
                withAnimation {
                    self?.success = true
                    self?.isLoading = false
                    self?.isSuccessUpdated = true
                    self?.stateObservable.isVerified = "Verified"
                }
            }
        case .failure(let failure):
            handleDefaultErrorEdit(error: failure)
        }
	}

	func routingToHome() {
		DispatchQueue.main.async { [weak self] in

			if self?.stateObservable.userType == 2 {
                let viewModel = TalentHomeViewModel(isFromUserType: true)
				self?.route = .homeTalent(viewModel: viewModel)
			} else {
				let vm = TabViewContainerViewModel(
                    isFromUserType: true,
                    userHomeVM: UserHomeViewModel(),
                    profileVM: ProfileViewModel(backToHome: {}),
					searchVM: SearchTalentViewModel(backToHome: {}),
                    scheduleVM: ScheduleListViewModel(backToHome: {}, currentUserId: (self?.userData?.id).orEmpty())
				)

				DispatchQueue.main.async { [weak self] in
					self?.route = .tabContainer(viewModel: vm)
				}
			}
		}

	}

	func onStartRefresh() {
		self.isRefreshFailed = false
		self.isLoading = true
		self.success = false
		self.error = nil
	}

	func getUsers() async {
		onStartRequest()

        let result = await getUserUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoading = false
                
                self?.userData = success

                if success.name == nil {
                    self?.name = ""
                } else {
                    self?.name = success.name.orEmpty()
                }

                if success.profileDescription == nil {
                    self?.bio = ""
                } else {
                    self?.bio = success.profileDescription.orEmpty()
                }
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
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
}
