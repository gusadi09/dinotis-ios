//
//  TalentProfileDetailViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 01/03/22.
//

import Foundation
import Combine
import SwiftUI
import UIKit

final class TalentProfileDetailViewModel: ObservableObject {
    
	var backToRoot: () -> Void
	var backToHome: () -> Void
	
	private var stateObservable = StateObservable.shared
	
	@Published var route: HomeRouting?
	
	@Published var showMenuCard = false
	
	@Published var isLoading = false
	@Published var isError = false
	@Published var success = false
	@Published var error: HMError?
	
	@Published var methodName = ""
	@Published var methodIcon = ""
	
	@Published var isRefreshFailed = false
    @Published var freeTrans = false

	@Published var redirectUrl: String?
	@Published var qrCodeUrl: String?

    private let authRepository: AuthenticationRepository
    private let talentRepository: TalentRepository
    private let userRepository: UsersRepository
    private var cancellables = Set<AnyCancellable>()
    private let config = Configuration.shared
    
    @Published var userData: Users?
    @Published var userName: String?
    @Published var userPhoto: String?
    
    @Published var talentData: TalentFromSearch?
    @Published var talentName: String?
    @Published var talentPhoto: String?
    
    @Published var profileBanner = [Highlights]()
    @Published var profileBannerContent = [ProfileBannerImage]()
    
    @Published var countPart = 0
    @Published var totalPart = 0
    @Published var title = ""
    @Published var desc = ""
    @Published var date = ""
    @Published var timeStart = ""
    @Published var timeEnd = ""
    @Published var price = ""
    @Published var meetingId = ""
    
    @Published var isPresent = false
    @Published var bookingId = ""
    
    @Published var payments = UserBookingPayment(
        id: "",
        amount: "",
        bookingID: "",
        paymentMethodID: 0,
        externalId: nil,
        redirectUrl: nil,
        qrCodeUrl: nil
    )
    
    init(
        backToRoot: @escaping (() -> Void),
        backToHome: @escaping (() -> Void),
        authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
        talentRepository: TalentRepository = TalentDefaultRepository(),
        userRepository: UsersRepository = UsersDefaultRepository()
    ) {
        self.backToRoot = backToRoot
        self.backToHome = backToHome
        self.authRepository = authRepository
        self.talentRepository = talentRepository
        self.userRepository = userRepository
    }
    
    func onScreenAppear(geo: GeometryProxy, username: String) {
        getTalentFromSearch(by: username, geo: geo)
        getUsers()
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
    
    // MARK: - Hilmy
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
                self.userPhoto = value.profilePhoto
                self.userName = value.name
            }
            .store(in: &cancellables)

    }
    
    func getTalentFromSearch(by username: String, geo: GeometryProxy) {
        onStartedFetch()

        talentRepository.provideGetDetailTalent(by: username)
            .sink { result in
                switch result {
                    case .failure(let error):
                        DispatchQueue.main.async {[weak self] in
                            if error.statusCode.orZero() == 401 {
                                self?.refreshToken(onComplete: {
                                    self?.getTalentFromSearch(by: username, geo: geo)
                                })
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
                self.talentData = value
                self.talentPhoto = value.profilePhoto
                self.talentName = value.name
                
                self.profileBanner = value.userHighlights ?? []
                
                if !value.userHighlights!.isEmpty {
                    for item in value.userHighlights ?? [] {
                        self.profileBannerContent.append(
                            ProfileBannerImage(
                                content: item,
                                action: {
                                    guard let url = URL(string: item.imgUrl.orEmpty()) else { return }
                                    UIApplication.shared.open(url)
                                },
                                geo: geo
                            )
                        )
                    }
                }
            }
            .store(in: &cancellables)
        
    }
    
    func routeToPaymentMethod(price: String, meetingId: String) {
        let viewModel = PaymentMethodsViewModel(price: price, meetingId: meetingId, backToRoot: self.backToRoot, backToHome: self.backToHome)
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .paymentMethod(viewModel: viewModel)
        }
    }
    
    func routeToUserScheduleDetail() {
        let viewModel = ScheculeDetailViewModel(backToRoot: self.backToRoot, backToHome: self.backToHome)
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .userScheduleDetail(viewModel: viewModel)
        }
    }
    
    func isHaveMeeting(meet: Meeting, current: String) -> Bool {

        for itemsOfBook in meet.bookings.filter({ value in
            value.userID == current && value.bookingPayment.failedAt == nil && value.bookingPayment.paidAt != nil
        }) where current == itemsOfBook.userID {
            return true
        }
        
        return false
    }
    
    func isMeetingId(currentUser: String, bookings: [Booking]) -> String {
        
        for item in bookings where item.userID == currentUser {
            return item.bookingPayment.bookingID
        }
        
        return ""
    }
    
    func shareSheet(url: String) {
        let url = URL(string: url)
        let activityView = UIActivityViewController(activityItems: [url!], applicationActivities: nil)

        let allScenes = UIApplication.shared.connectedScenes
        let scene = allScenes.first { $0.activationState == .foregroundActive }

        if let windowScene = scene as? UIWindowScene {
            if #available(iOS 15.0, *) {
                windowScene.keyWindow?.rootViewController?.present(activityView, animated: true, completion: nil)
            } else {
                UIApplication.shared.windows.first?.rootViewController!.present(activityView, animated: true, completion: nil)
            }
        }

    }

}
