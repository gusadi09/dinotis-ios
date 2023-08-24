//
//  ScheduleListViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 01/03/22.
//

import Combine
import DinotisData
import DinotisDesignSystem
import Foundation
import UIKit
import SwiftUI
import OneSignal

enum ScheduleTab {
    case all
    case waiting
    case upcoming
    case finished
    case canceled
}

enum SessionStatus: String {
    case waitingForPayment = "waiting_for_payment"
    case paid = "paid"
    case upcoming = "upcoming"
    case notReviewed = "not_reviewed"
    case done = "done"
    case canceled = "canceled"
}

final class ScheduleListViewModel: ObservableObject {
	
	var backToHome: () -> Void

	private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?
	private var cancellables = Set<AnyCancellable>()
	private let getUserBookingsUseCase: GetUserBookingsUseCase
	private let getTodayAgendasUseCase: GetTodayAgendasUseCase
    private let giveReviewUseCase: GiveReviewUseCase
    private let counterUseCase: GetCounterUseCase
	
	private var stateObservable = StateObservable.shared
	@Published var currentUserId: String
	
	@Published var route: HomeRouting?
	
	@Published var paymentName = ""
	
	@Published var showMenuCard = false
	
	@Published var username = ""
	
	@Published var meetingID = ""
    
    @Published var reviewRequest = ReviewRequestBody()
    @Published var reviewImage: String? = ""
    @Published var reviewCreatorName: String? = ""
    @Published var reviewTitle: String? = ""
    @Published var reviewMessage = ""
    @Published var reviewRating = 0
	
	@Published var bookingID = ""
	@Published var invoicePrice = 0
	@Published var methodId = 0
	@Published var methodName = ""
	@Published var methodIcon = ""
	
	@Published var contentOffset = CGFloat.zero
	@Published var isLoading = false
    @Published var isLoadMoreData = false
	@Published var isError = false
	@Published var success = false
	@Published var error: String?
    @Published var successReview = false
  
  @Published var isShowAlert = false
  @Published var alert = AlertAttribute()
    
    @Published var showReviewSheet = false

	@Published var bookingData = [UserBookingData]()
    @Published var todaysAgenda = [UserBookingData]()
	
	@Published var price = ""
	@Published var meetingId = ""
	
	@Published var redirectUrl: String?
	@Published var qrCodeUrl: String?
	
	@Published var isQr = false
	@Published var isEwallet = false
    
    @Published var takeItem = 8
    @Published var nextCursor: Int? = 0
    @Published var status = ""
	
	@Published var isRefreshFailed = false
    
    @Published var tab: [ScheduleTab] = [
        .all, .waiting, .upcoming, .finished, .canceled
    ]
    
    @Published var currentTab: ScheduleTab = .all
    @Published var hasNewNotif = false
	
	init(
		backToHome: @escaping (() -> Void),
		currentUserId: String,
		getUserBookingsUseCase: GetUserBookingsUseCase = GetUserBookingsDefaultUseCase(),
		getTodayAgendasUseCase: GetTodayAgendasUseCase = GetTodayAgendasDefaultUseCase(),
        giveReviewUseCase: GiveReviewUseCase = GiveReviewDefaultUseCase(),
        counterUseCase: GetCounterUseCase = GetCounterDefaultUseCase()
	) {
		self.backToHome = backToHome
		self.currentUserId = currentUserId
		self.getUserBookingsUseCase = getUserBookingsUseCase
		self.getTodayAgendasUseCase = getTodayAgendasUseCase
        self.giveReviewUseCase = giveReviewUseCase
        self.counterUseCase = counterUseCase
	}
    
    func labelColor(_ data: UserBookingData) -> Color {
        if data.status == SessionStatus.canceled.rawValue {
            return .DinotisDefault.red
        } else if data.status == SessionStatus.done.rawValue || data.status == SessionStatus.notReviewed.rawValue {
            return .DinotisDefault.green
        } else if data.status == SessionStatus.waitingForPayment.rawValue {
            return .DinotisDefault.orange
        } else {
            return .DinotisDefault.primary
        }
    }
    
    func sessionStatus(_ data: UserBookingData) -> String {
        if data.status == SessionStatus.canceled.rawValue {
            return LocalizableText.scheduleTabCancel
        } else if data.status == SessionStatus.done.rawValue || data.status == SessionStatus.notReviewed.rawValue {
            return LocalizableText.doneLabel
        } else if data.status == SessionStatus.waitingForPayment.rawValue {
            return LocalizableText.scheduleTabWaiting
        } else {
            return LocalizableText.scheduleTabUpcoming
        }
    }
    
    func buttonLabel(_ data: UserBookingData) -> String {
        if data.status == SessionStatus.notReviewed.rawValue {
            return LocalizableText.giveReviewLabel
        } else if data.status == SessionStatus.waitingForPayment.rawValue {
            return LocalizableText.payNowLabel
        } else if data.status == SessionStatus.done.rawValue {
            return LocalizableText.generalOrderAgain
        } else if data.status == SessionStatus.canceled.rawValue {
            return LocalizableText.generalOrderAgain
        } else {
            return LocalizableText.seeText
        }
    }
    
    func buttonAction(_ data: UserBookingData) {
        if data.status == SessionStatus.paid.rawValue {
            routeToUsertDetailSchedule(bookingId: data.id.orEmpty(), talentName: (data.meeting?.user?.name).orEmpty(), talentPhoto: (data.meeting?.user?.profilePhoto).orEmpty())
        } else if data.status == SessionStatus.upcoming.rawValue {
            routeToUsertDetailSchedule(bookingId: data.id.orEmpty(), talentName: (data.meeting?.user?.name).orEmpty(), talentPhoto: (data.meeting?.user?.profilePhoto).orEmpty())
        } else if data.status == SessionStatus.canceled.rawValue {
            routeToTalentProfile(username: (data.meeting?.user?.username).orEmpty())
        } else if data.status == SessionStatus.done.rawValue {
            routeToTalentProfile(username: (data.meeting?.user?.username).orEmpty())
        } else if data.status == SessionStatus.notReviewed.rawValue {
            routeToUsertDetailSchedule(bookingId: data.id.orEmpty(), talentName: (data.meeting?.user?.name).orEmpty(), talentPhoto: (data.meeting?.user?.profilePhoto).orEmpty())
        } else if data.status == SessionStatus.waitingForPayment.rawValue {
			routeToInvoice(id: data.id.orEmpty())
        } else {
            routeToTalentProfile(username: (data.meeting?.user?.username).orEmpty())
        }
    }
	
	func routeToSearch() {
		let viewModel = SearchTalentViewModel(backToHome: {self.route = nil})
		
		DispatchQueue.main.async {[weak self] in
			self?.route = .searchTalent(viewModel: viewModel)
		}
	}
	
	func routeToInvoiceBooking(id: String) {
        let viewModel = InvoicesBookingViewModel(bookingId: id, backToHome: {self.route = nil}, backToChoosePayment: {self.route = nil})
		
		DispatchQueue.main.async {[weak self] in
			self?.route = .bookingInvoice(viewModel: viewModel)
		}
	}
	
	func routeToTalentProfile(username: String) {
		let viewModel = TalentProfileDetailViewModel(backToHome: {self.route = nil}, username: username)
		
		DispatchQueue.main.async { [weak self] in
			self?.route = .talentProfileDetail(viewModel: viewModel)
		}
	}
	
    func routeToUsertDetailSchedule(bookingId: String, talentName: String, talentPhoto: String) {
        let viewModel = ScheduleDetailViewModel(isActiveBooking: true, bookingId: bookingId, backToHome: {self.route = nil}, talentName: talentName, talentPhoto: talentPhoto, isDirectToHome: false)
		
		DispatchQueue.main.async { [weak self] in
			self?.route = .userScheduleDetail(viewModel: viewModel)
		}
	}
	
    func routeToInvoice(id: String) {
		let viewModel = DetailPaymentViewModel(
            backToHome: {self.route = nil},
			backToChoosePayment: {},
			bookingId: id,
            subtotal: "",
            extraFee: "",
            serviceFee: ""
		)
		
		DispatchQueue.main.async { [weak self] in
			self?.route = .detailPayment(viewModel: viewModel)
		}
	}
	
	func routeToPayment(price: String) {
        let viewModel = PaymentMethodsViewModel(price: price, meetingId: meetingId, rateCardMessage: "", isRateCard: false, backToHome: {self.route = nil})
		
		DispatchQueue.main.async { [weak self] in
			self?.route = .paymentMethod(viewModel: viewModel)
		}
	}
    
    func routeToNotification() {
        let viewModel = NotificationViewModel(backToHome: { self.route = nil })

        DispatchQueue.main.async { [weak self] in
            self?.route = .notification(viewModel: viewModel)
        }
    }
    
    func openWhatsApp() {
        if let waurl = URL(string: "https://wa.me/6281318506068") {
            if UIApplication.shared.canOpenURL(waurl) {
                UIApplication.shared.open(waurl, options: [:], completionHandler: nil)
            }
        }
    }

  func onStartRequest() {
    DispatchQueue.main.async {[weak self] in
      withAnimation(.spring()) {
        self?.isError = false
        self?.error = nil
        self?.isRefreshFailed = false
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
  }

	func handleDefaultError(error: Error) {
		DispatchQueue.main.async { [weak self] in
			self?.isLoading = false
			self?.isLoadMoreData = false

			if let error = error as? ErrorResponse {
				self?.error = error.message.orEmpty()

				if error.statusCode.orZero() == 401 {
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
                OneSignal.setExternalUserId("") }
          )
          self?.isShowAlert = true
				} else {
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
    
    func getCounter() async {
        onStartRequest()
        
        let result = await counterUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoading = false
                self?.hasNewNotif = success.unreadNotificationCount.orZero() > 0
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    func onAppear() {
        onGetCounter()
        
        guard todaysAgenda.isEmpty else { return }
        onGetTodaysAgenda()
        
        guard bookingData.isEmpty else { return }
        onGetBooking()
    }
    
    func onGetCounter() {
        Task {
            await getCounter()
        }
    }
    
    func onGetTodaysAgenda() {
        Task {
            await getTodayAgendaList()
        }
    }
    
    func onGetBooking() {
        Task {
            await getBookingsList(isMore: false)
        }
    }

    func getBookingsList(isMore: Bool) async {
		onStartRequest()
        DispatchQueue.main.async { [weak self] in
            withAnimation(.spring()) {
                if isMore {
                    self?.isLoadMoreData = true
                } else {
                    self?.isLoading = true
                }
            }
        }
        
        let query = UserBookingQueryParam(
            skip: takeItem-8,
            take: takeItem,
            status: status
        )

		let result = await getUserBookingsUseCase.execute(with: query)

		switch result {
		case .success(let success):
			DispatchQueue.main.async { [weak self] in
				withAnimation(.spring()) {
					self?.isLoading = false
					self?.isLoadMoreData = false
				}

				if isMore {
					self?.bookingData += success.data ?? []
				} else {
					self?.bookingData = success.data ?? []
				}

				self?.nextCursor = success.nextCursor
			}
		case .failure(let failure):
			handleDefaultError(error: failure)
		}
	}
    
    func getTodayAgendaList() async {
        onStartRequest()
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
        }

		let result = await getTodayAgendasUseCase.execute()

		switch result {
		case .success(let success):
			DispatchQueue.main.async { [weak self] in
				withAnimation(.spring()) {
					self?.isLoading = false
					self?.todaysAgenda = success.data ?? []
				}
			}
		case .failure(let failure):
			handleDefaultError(error: failure)
		}
    }
    
    func giveReview() async {
        onStartRequest()
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
        }
        
        let body = ReviewRequestBody(rating: self.reviewRating, review: self.reviewMessage, meetingId: self.meetingId)
        let result = await giveReviewUseCase.execute(with: body)
        
        switch result {
        case .success(_):
            DispatchQueue.main.async { [weak self] in
                withAnimation(.spring()) {
                    self?.isError = false
                    self?.isLoading = false
                    self?.error = nil
                    self?.showReviewSheet = false
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) { [weak self] in
                withAnimation(.spring()) {
                  self?.alert.isError = false
                  self?.alert.title = LocalizableText.reviewSuccessTitle
                  self?.alert.message = LocalizableText.reviewSuccessMessage
                  self?.alert.primaryButton = .init(
                    text: LocalizableText.okText,
                    action: {
                      Task {
                        self?.takeItem = 8
                        await self?.getBookingsList(isMore: false)
                        await self?.getTodayAgendaList()
                      }
                    }
                  )
                  self?.isShowAlert = true
                }
            }
        case .failure(let failure):
            if let failure = failure as? ErrorResponse {
                DispatchQueue.main.async { [weak self] in
                  withAnimation(.spring()) {
                    self?.isError = true
                    self?.isLoading = false
                    self?.error = failure.message.orEmpty()
                    self?.showReviewSheet = false
                    self?.alert.isError = true
                    self?.alert.message = failure.message.orEmpty()
                    self?.isShowAlert = true
                  }
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                  withAnimation(.spring()) {
                    self?.isError = true
                    self?.isLoading = false
                    self?.error = failure.localizedDescription
                    self?.alert.isError = true
                    self?.alert.message = failure.localizedDescription
                    self?.isShowAlert = true
                  }
                }
            }
        }
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
