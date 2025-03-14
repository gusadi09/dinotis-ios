//
//  EditProfileViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 23/02/22.
//

import Combine
import DinotisData
import CountryPicker
import DinotisDesignSystem
import OneSignal
import SwiftUI
import UIKit

final class EditProfileViewModel: ObservableObject {
    
    var backToHome: () -> Void
    
    private var cancellables = Set<AnyCancellable>()
    private let config = Configuration.shared
    private var stateObservable = StateObservable.shared
    
    private var singlePhotoUseCase: SinglePhotoUseCase
    private var multiplePhotoUseCase: MultiplePhotoUseCase
    
    private let getUserUseCase: GetUserUseCase
    private let usernameAvailabilityCheckingUseCase: UsernameAvailabilityCheckingUseCase
    private let editUserUseCase: EditUserUseCase
    private let authRepository: AuthenticationRepository
    private let professionListUseCase: ProfessionListUseCase
    
    private var availTimer: Timer?
    
    @Published var showDropDown = false
    
    @Published var route: HomeRouting?
    
    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var error: String?
    @Published var success: Bool = false
    
    @Published var isLoadingUserName = false
    
    @Published var alert = AlertAttribute()
    
    @Published var professionData: ProfessionResponse?
    @Published var userData: UserResponse?
    
    @Published var constUrl = Configuration.shared.environment.usernameURL
    
    @Published var professionSelectString = [String]()
    @Published var professionSelectID = [Int]()
    @Published var userPhoto: String?
    @Published var phone = ""
    
    @Published var draggedImage: UIImage?
    @Published var userHighlightsImage: [UIImage] = Array(repeating: UIImage(), count: 3)
    var userHighlightImageCount: Int {
        userHighlightsImage.filter({ $0 != UIImage() }).count
    }
    
    @Published var userHighlights : [String]?
    @Published var userHighlight : String?
    @Published var highlights: [HighlightData]?
    
    @Published var name: String?
    @Published var names = ""
    @Published var username = ""
    @Published var bio = ""
    
    @Published var isShowPhotoLibrary = false
    @Published var isShowPhotoLibraryHG: [Bool] = Array(repeating: false, count: 6)
    @Published var image = UIImage()
    
    @Published var isSuccessUpdate = false
    @Published var isFailedUpdate = false
    
    @Published var isRefreshFailed = false
    @Published var isUsernameAvail = false
    @Published var usernameInvalid = false
    
    @Published var alertTitle: String?
    @Published var isShowAlert = false
    
    init(
        backToHome: @escaping (() -> Void),
        getUserUseCase: GetUserUseCase = GetUserDefaultUseCase(),
        usernameAvailabilityCheckingUseCase: UsernameAvailabilityCheckingUseCase = UsernameAvailabilityCheckingDefaultUseCase(),
        editUserUseCase: EditUserUseCase = EditUserDefaultUseCase(),
        authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
        professionListUseCase: ProfessionListUseCase = ProfessionListDefaultUseCase(),
        singlePhotoUseCase: SinglePhotoUseCase = SinglePhotoDefaultUseCase(),
        multiplePhotoUseCase: MultiplePhotoUseCase = MultiplePhotoDefaultUseCase()
    ) {
        self.backToHome = backToHome
        self.getUserUseCase = getUserUseCase
        self.usernameAvailabilityCheckingUseCase = usernameAvailabilityCheckingUseCase
        self.editUserUseCase = editUserUseCase
        self.authRepository = authRepository
        self.professionListUseCase = professionListUseCase
        self.singlePhotoUseCase = singlePhotoUseCase
        self.multiplePhotoUseCase = multiplePhotoUseCase
    }
    
    func openWhatsApp() {
        if let waurl = URL(string: "https://wa.me/6281318506068") {
            if UIApplication.shared.canOpenURL(waurl) {
                UIApplication.shared.open(waurl, options: [:], completionHandler: nil)
            }
        }
    }
    
    func onStartFetch() {
        DispatchQueue.main.async {[weak self] in
            self?.isError = false
            self?.isLoading = true
            self?.success = false
            self?.isSuccessUpdate = false
            self?.error = nil
            self?.isShowAlert = false
            self?.alert = .init(
                isError: false,
                title: LocalizableText.attentionText,
                message: "",
                primaryButton: .init(
                    text: LocalizableText.closeLabel,
                    action: {}
                ),
                secondaryButton: nil
            )
        }
    }
    
    func startCheckAvail() {
        if username.isValidUsername() && username.count >= 6 {
            if let availTimer = availTimer {
                availTimer.invalidate()
            }
            
            onStartCheckingUsername()
            
            availTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(usernameAvailabilityChecking), userInfo: nil, repeats: false)
        } else {
            if let availTimer = availTimer {
                availTimer.invalidate()
            }
            
            self.isLoadingUserName = false
            self.isUsernameAvail = false
            self.usernameInvalid = true
        }
        
    }
    
    func handleDefaultErrorUsernameChecking(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoadingUserName = false
            
            if let error = error as? ErrorResponse {
                self?.isUsernameAvail = error.statusCode.orZero() == 409
                
                if error.statusCode.orZero() == 401 {
                    self?.error = error.message.orEmpty()
                    self?.isRefreshFailed.toggle()
                    self?.alert.isError = true
                    self?.alert.message = LocalizableText.alertSessionExpired
                    self?.alert.primaryButton = .init(
                        text: LocalizableText.okText,
                        action: {
                            NavigationUtil.popToRootView()
                            self?.stateObservable.userType = 0
                            self?.stateObservable.isVerified = ""
                            self?.stateObservable.refreshToken = ""
                            self?.stateObservable.accessToken = ""
                            self?.stateObservable.isAnnounceShow = false
                            OneSignal.setExternalUserId("")
                        }
                    )
                    self?.isShowAlert = true
                } else if error.statusCode != 409 {
                    self?.isUsernameAvail = false
                }
            } else {
                self?.isError = true
                self?.error = error.localizedDescription
                self?.alert.isError = true
                self?.alert.message = error.localizedDescription
                self?.isShowAlert = true
            }
            
        }
    }
    
    func onStartCheckingUsername() {
        DispatchQueue.main.async { [weak self] in
            self?.success = false
            self?.isLoadingUserName = true
            self?.isError = false
            self?.error = nil
            self?.isUsernameAvail = false
            self?.usernameInvalid = false
            self?.isShowAlert = false
            self?.alert = .init(
                isError: false,
                title: LocalizableText.attentionText,
                message: "",
                primaryButton: .init(
                    text: LocalizableText.closeLabel,
                    action: {}
                ),
                secondaryButton: nil
            )
        }
    }
    
    func onCheckUsername() async {
        onStartCheckingUsername()
        let usernameBody = UsernameAvailabilityRequest(username: username)
        
        let result = await usernameAvailabilityCheckingUseCase.execute(with: usernameBody)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.isLoadingUserName = false
                self?.isUsernameAvail = true
                self?.isUsernameAvail = !success.message.orEmpty().isEmpty
            }
        case .failure(let failure):
            handleDefaultErrorUsernameChecking(error: failure)
        }
    }
    
    @objc func usernameAvailabilityChecking() {
        onStartCheckingUsername()
        
        if username.isValidUsername() {
            if username.isEmpty {
                self.isUsernameAvail = false
            } else {
                Task {
                    await onCheckUsername()
                }
            }
        } else {
            self.usernameInvalid = true
        }
        
    }
    
    func isAvailableToSaveUser(_ isAudience: Bool = true) -> Bool {
        if !isAudience {
            return !names.isEmpty && !bio.isEmpty && (!username.isEmpty && (!usernameInvalid && isUsernameAvail))
            
        } else {
            return !names.isEmpty
        }
    }
    
    func limitUsernameText(_ upper: Int = 32) {
        if username.count > upper {
            username = String(username.prefix(upper))
        }
    }
    
    func limitBioText(_ upper: Int = 256) {
        if bio.count > upper {
            bio = String(bio.prefix(upper))
        }
    }
    
    func onStartRefresh() {
        DispatchQueue.main.async { [weak self] in
            self?.isRefreshFailed = false
            self?.isLoading = true
            self?.success = false
            self?.error = nil
            self?.isShowAlert = false
            self?.alert = .init(
                isError: false,
                title: LocalizableText.attentionText,
                message: "",
                primaryButton: .init(
                    text: LocalizableText.closeLabel,
                    action: {}
                ),
                secondaryButton: nil
            )
        }
    }
    
    @MainActor
    func deleteHighlightImage(at index: Int) {
        withAnimation {
            userHighlightsImage.remove(at: index)
            userHighlightsImage.append(UIImage())
        }
    }
    
    func onUpload(dismiss: @escaping () -> Void) {
        Task {
            await uploadSingleImage(dismiss: dismiss)
        }
    }
    
    func routeToPreviewProfile() {
        let viewModel = PreviewTalentViewModel()

        DispatchQueue.main.async { [weak self] in
            self?.route = .previewTalent(viewModel: viewModel)
        }
    }
    
    func uploadSingleImage(dismiss: @escaping () -> Void) async {
        onStartFetch()
        
        if image != UIImage() {
            
            let result = await singlePhotoUseCase.execute(with: image)
            
            switch result {
            case .success(let success):
                    let multipleHighlight = self.userHighlightsImage.compactMap { item in
                        if item != UIImage() {
                            return item
                        } else {
                            return nil
                        }
                    }
                    
                    guard !multipleHighlight.isEmpty else {
                        DispatchQueue.main.async {[weak self] in
                            self?.isLoading = false
                            self?.success = true
                        }
                        
                        Task {
                            await self.updateUser(imageUrl: success, userHighlight: [], dismiss: dismiss)
                        }
                        
                        return
                    }
                    
                    let resultMultiple = await multiplePhotoUseCase.execute(with: multipleHighlight)
                    
                    switch resultMultiple {
                    case .success(let successMultiple):
                        DispatchQueue.main.async {[weak self] in
                            self?.isLoading = false
                            self?.success = true
                            
                        }
                        
                        Task {
                            await self.updateUser(imageUrl: success, userHighlight: successMultiple, dismiss: dismiss)
                        }
                        
                    case .failure(let failure):
                        withAnimation {
                            DispatchQueue.main.async {[weak self] in
                                self?.isError = true
                                self?.isLoading = false
                                self?.alertTitle = LocalizableText.attentionText
                                
                                if let error = failure as? ErrorResponse {
                                    self?.error = (error.message).orEmpty()
                                    self?.alert.message = (error.message).orEmpty()
                                } else {
                                    self?.error = failure.localizedDescription
                                    self?.alert.message = failure.localizedDescription
                                }
                                
                                self?.isShowAlert = true
                            }
                        }
                    }
//                } else {
//                    DispatchQueue.main.async {[weak self] in
//                        self?.isLoading = false
//                        self?.success = true
//                    }
//                    
//                    Task {
//                        await self.updateUser(imageUrl: success, userHighlight: [], dismiss: dismiss)
//                    }
//                }
            case .failure(let failure):
                withAnimation {
                    DispatchQueue.main.async {[weak self] in
                        self?.isError = true
                        self?.isLoading = false
                        self?.alertTitle = LocalizableText.attentionText
                        
                        if let error = failure as? ErrorResponse {
                            self?.error = (error.message).orEmpty()
                            self?.alert.message = (error.message).orEmpty()
                        } else {
                            self?.error = failure.localizedDescription
                            self?.alert.message = failure.localizedDescription
                        }
                        
                        self?.isShowAlert = true
                    }
                }
            }
        } else {
                let multipleHighlight = self.userHighlightsImage.compactMap { item in
                    if item != UIImage() {
                        return item
                    } else {
                        return nil
                    }
                }
                
                guard !multipleHighlight.isEmpty else {
                    DispatchQueue.main.async {[weak self] in
                        self?.isLoading = false
                        self?.success = true
                    }
                    
                    Task {
                        await self.updateUser(imageUrl: "", userHighlight: [], dismiss: dismiss)
                    }
                    
                    return
                }
                
                let resultMultiple = await multiplePhotoUseCase.execute(with: multipleHighlight)
                
                switch resultMultiple {
                case .success(let successMulti):
                    DispatchQueue.main.async {[weak self] in
                        self?.isLoading = false
                        self?.success = true
                        
                    }
                    
                    Task {
                        await self.updateUser(imageUrl: "", userHighlight: successMulti, dismiss: dismiss)
                    }
                case .failure(let failure):
                    withAnimation {
                        DispatchQueue.main.async {[weak self] in
                            self?.isError = true
                            self?.isLoading = false
                            self?.alertTitle = LocalizableText.attentionText
                            
                            if let error = failure as? ErrorResponse {
                                self?.error = (error.message).orEmpty()
                                self?.alert.message = (error.message).orEmpty()
                            } else {
                                self?.error = failure.localizedDescription
                                self?.alert.message = failure.localizedDescription
                            }
                            
                            self?.isShowAlert = true
                        }
                    }
                }
        }
    }
    
    func handleDefaultError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            
            if let error = error as? ErrorResponse {
                
                if error.statusCode.orZero() == 401 {
                    self?.error = error.message.orEmpty()
                    self?.isRefreshFailed.toggle()
                    self?.alert.isError = true
                    self?.alert.message = LocalizableText.alertSessionExpired
                    self?.alert.primaryButton = .init(
                        text: LocalizableText.okText,
                        action: {
                            NavigationUtil.popToRootView()
                            self?.stateObservable.userType = 0
                            self?.stateObservable.isVerified = ""
                            self?.stateObservable.refreshToken = ""
                            self?.stateObservable.accessToken = ""
                            self?.stateObservable.isAnnounceShow = false
                            OneSignal.setExternalUserId("")
                        }
                    )
                    self?.isShowAlert = true
                } else {
                    self?.error = error.message.orEmpty()
                    self?.isError = true
                    self?.alert.isError = true
                    self?.alert.message = error.message.orEmpty()
                    self?.isShowAlert = true
                }
            } else {
                self?.isError = true
                self?.error = error.localizedDescription
                self?.alert.isError = true
                self?.alert.message = error.localizedDescription
                self?.isShowAlert = true
            }
            
        }
    }
    
    func updateUser(imageUrl: String, userHighlight: [String], dismiss: @escaping () -> Void) async {
        onStartFetch()
        
        let body = EditUserRequest(
            name: names,
            username: username.isEmpty ? nil : username,
            profilePhoto: imageUrl.isEmpty ? nil : imageUrl,
            profileDescription: bio,
            userHighlights: userHighlight.isEmpty ? userHighlights ?? [] : userHighlight,
            professions: professionSelectID.isEmpty ? nil : professionSelectID,
            password: nil,
            confirmPassword: nil
        )
        
        let result = await editUserUseCase.execute(with: body)
        
        switch result {
        case .success(_):
            DispatchQueue.main.async { [weak self] in
                self?.isSuccessUpdate = true
                self?.isLoading = false
                self?.alert.isError = false
                self?.alert.title = LocalizableText.alertSuccessChangeProfileTitle
                self?.alert.message = LocalizableText.alertSuccessChangeProfileMessage
                self?.alert.primaryButton = .init(
                    text: LocalizableText.okText,
                    action: dismiss
                )
                self?.isShowAlert = true
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    func getProfession() async {
        onStartFetch()
        
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
    
    func onViewAppear(user: UserResponse?) {
        self.username = (user?.username).orEmpty()
        self.names = (user?.name).orEmpty()
        self.name = user?.name
        self.userPhoto = user?.profilePhoto
        self.bio = (user?.profileDescription).orEmpty()
        self.phone = (user?.phone).orEmpty()
    }
    
    @MainActor
    func getUsers() async {
        onStartFetch()
        
        let result = await getUserUseCase.execute()
        
        switch result {
        case .success(let success):
                self.success = true
                self.isLoading = false
                
                self.userData = success
                self.onViewAppear(user: success)
                
                if !(success.userHighlights ?? []).isEmpty {
                    var tempHG = [UIImage]()
                    
                    for i in 0..<(success.userHighlights?.count).orZero() {
                        if let image = success.userHighlights?[i] {
                            self.highlights?.append(image)
                            self.userHighlight?.append(image.imgUrl.orEmpty())
                            tempHG.append(await image.imgUrl.orEmpty().load())
                        }
                    }
                    
                    self.userHighlightsImage = tempHG
                    for _ in 1...6-userHighlightsImage.count {
                        self.userHighlightsImage.append(UIImage())
                    }
                }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    func onAppearLoad() {
        Task {
            await getProfession()
            await getUsers()
        }
    }
    
    func phoneTrimming() -> String {
        let possibleCountry = CountryManager.shared.getCountries().compactMap {
            "+" + $0.phoneCode
        }
        
        let phoneNumber = (self.userData?.phone).orEmpty()
        
        var trimmedPhoneNumber = phoneNumber
        
        for code in possibleCountry {
            if phoneNumber.hasPrefix(code) {
                let index = phoneNumber.index(phoneNumber.startIndex, offsetBy: code.count)
                trimmedPhoneNumber = String(phoneNumber[index...])
                break
            }
        }
        
        return trimmedPhoneNumber
    }
    
    func routeToChangePhone() {
        let viewModel = ChangePhoneViewModel(backToHome: self.backToHome, backToEditProfile: {self.route = nil}, phone: phoneTrimming())
        
        DispatchQueue.main.async {[weak self] in
            self?.route = .changePhone(viewModel: viewModel)
        }
    }
    
    func autoLogout() {
        NavigationUtil.popToRootView()
        self.stateObservable.userType = 0
        self.stateObservable.isVerified = ""
        self.stateObservable.refreshToken = ""
        self.stateObservable.accessToken = ""
        self.stateObservable.isAnnounceShow = false
        OneSignal.setExternalUserId("")
    }
}
