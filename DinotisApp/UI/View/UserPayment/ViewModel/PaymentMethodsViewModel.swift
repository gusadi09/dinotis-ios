//
//  PaymentMethodViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 04/03/22.
//

import Foundation
import Combine
import UIKit
import SwiftUI
import OneSignal
import DinotisData
import DinotisDesignSystem

final class PaymentMethodsViewModel: ObservableObject {
	
	var backToRoot: () -> Void
	var backToHome: () -> Void
	
	private var stateObservable = StateObservable.shared

	private let paymentMethodUseCase: GetPaymentMethodUseCase
	private let coinPaymentUseCase: CoinPaymentUseCase
	private let promoCodeCheckingUseCase: PromoCodeCheckingUseCase
	private let extraFeeUseCase: GetExtraFeeUseCase
	private let bookingPaymentUseCase: BookingPaymentUseCase
	private let authRepository: AuthenticationRepository
    private let requestSessionUseCase: RequestSessionUseCase
	
	private var cancellables = Set<AnyCancellable>()
	
	@Published var route: HomeRouting?
	
	@Published var isLoading = false
	@Published var isError = false
	@Published var success = false
	@Published var error: String?
	@Published var isSuccessSend = false
	@Published var discount = 0
  
  @Published var isShowAlert = false
  @Published var alert = AlertAttribute()

	@Published var promoCodeSuccess = false
	@Published var promoCodeError = false
	@Published var promoCodeData: PromoCodeResponse?

	@Published var promoCode = ""
	
	@Published var price: String
	
	@Published var paymentMethodData = [PaymentMethodData]()
	
	@Published var isRefreshFailed = false
	
	@Published var total = 0
	
	@Published var serviceFee = 0.0
	@Published var actualServiceFee = ""
	@Published var isPercentage = false
	
	@Published var extraFee = 0
	
	@Published var selected = false
	@Published var selectedString: String?
	@Published var selectItem: Int = 0
	@Published var selectedIcon: String?
	
	@Published var meetingId: String
    @Published var isRateCard: Bool
    @Published var rateCardMessage: String
	
	@Published var bookData: UserBookingData?
	
	@Published var bookId = ""
	@Published var isQR = false
	@Published var isEwallet = false
	
	@Published var redirectUrl: String?
	@Published var qrCodeUrl: String?

	@Published var contentOffset: CGFloat = 0
	@Published var colorTab = Color.clear
	@Published var successFree = false

	@Published var promoCodeTextArray = [String]()
	
	init(
		price: String,
		meetingId: String,
        rateCardMessage: String,
        isRateCard: Bool,
		backToRoot: @escaping (() -> Void),
		backToHome: @escaping (() -> Void),
		coinPaymentUseCase: CoinPaymentUseCase = CoinPaymentDefaultUseCase(),
		promoCodeCheckingUseCase: PromoCodeCheckingUseCase = PromoCodeCheckingDefaultUseCase(),
		paymentMethodUseCase: GetPaymentMethodUseCase = GetPaymentMethodDefaultUseCase(),
		extraFeeUseCase: GetExtraFeeUseCase = GetExtraFeeDefaultUseCase(),
		bookingPaymentUseCase: BookingPaymentUseCase = BookingPaymentDefaultUseCase(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
        requestSessionUseCase: RequestSessionUseCase = RequestSessionDefaultUseCase()
	) {
		self.price = price
		self.meetingId = meetingId
        self.isRateCard = isRateCard
		self.backToRoot = backToRoot
		self.backToHome = backToHome
		self.paymentMethodUseCase = paymentMethodUseCase
		self.coinPaymentUseCase = coinPaymentUseCase
		self.promoCodeCheckingUseCase = promoCodeCheckingUseCase
		self.extraFeeUseCase = extraFeeUseCase
		self.bookingPaymentUseCase = bookingPaymentUseCase
		self.authRepository = authRepository
        self.requestSessionUseCase = requestSessionUseCase
        self.rateCardMessage = rateCardMessage
	}

	func routeToInvoice() {
		let viewModel = InvoicesBookingViewModel(
			bookingId: stateObservable.bookId,
			backToRoot: self.backToRoot,
			backToHome: self.backToHome,
			backToChoosePayment: {self.route = nil}
		)

		DispatchQueue.main.async {[weak self] in
			self?.route = .bookingInvoice(viewModel: viewModel)
		}
	}

	func resetStateCode() {
		DispatchQueue.main.async { [weak self] in
			self?.promoCode = ""
			self?.promoCodeError = false
			self?.promoCodeSuccess = false
			self?.promoCodeData = nil
			self?.promoCodeTextArray = []
		}
	}

	func onStartCheckCode() {
		DispatchQueue.main.async { [weak self] in
			self?.promoCodeError = false
			self?.promoCodeSuccess = false
			self?.isLoading = true
			self?.promoCodeData = nil
			self?.promoCodeTextArray = []
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

	func handleDefaultErrorPromoCodeChecking(error: Error) {
		DispatchQueue.main.async { [weak self] in
			self?.isLoading = false

			if let error = error as? ErrorResponse {
				self?.error = error.message.orEmpty()

				if error.statusCode.orZero() == 401 {
					self?.isRefreshFailed.toggle()
          self?.alert.isError = true
          self?.alert.message = LocalizableText.alertSessionExpired
          self?.alert.primaryButton = .init(
            text: LocalizableText.okText,
            action: { self?.backToRoot() }
          )
          self?.isShowAlert = true
				} else {
					self?.promoCodeError = true
				}
			} else {
				self?.promoCodeError = true
				self?.error = error.localizedDescription
			}

		}
	}

	func checkPromoCode() async {
		onStartCheckCode()

		let body = PromoCodeRequest(code: promoCode, meetingId: meetingId, paymentMethodId: selectItem)

		let result = await promoCodeCheckingUseCase.execute(with: body)

		switch result {
		case .success(let success):

			DispatchQueue.main.async { [weak self] in
				self?.promoCodeSuccess = true
				self?.isLoading = false

				self?.promoCodeData = success

				self?.discount = success.discountTotal.orZero()

				self?.promoCodeTextArray = success.defineDiscountString()
			}
		case .failure(let failure):
			handleDefaultErrorPromoCodeChecking(error: failure)
		}
	}
	
	func getTotal(extraFee: Int) {
		DispatchQueue.main.async { [weak self] in
			let totalTemp = extraFee + (Int((self?.price).orEmpty()) ?? 0)
			var percentage = 0.0

			if self?.isPercentage ?? false {
				percentage = Double(totalTemp) * ((self?.serviceFee).orZero()/100)
			} else {
				percentage = (self?.serviceFee).orZero()
			}

			self?.actualServiceFee = String(Int(percentage)).toCurrency()

			let totalBeforeDisc = totalTemp + Int(percentage)

			if (self?.promoCodeData?.discountTotal).orZero() > totalBeforeDisc {
				self?.total = 0
			} else {
				self?.total = totalBeforeDisc - (self?.promoCodeData?.discountTotal).orZero()
			}
		}

	}

	func virtualAccountData() -> [PaymentMethodData] {
		self.paymentMethodData.filter({ value in
			!(value.isQr ?? false) && !(value.isEwallet ?? false)
		})
	}

	func resetPrice() {
		self.price = ""
	}

	func eWalletData() -> [PaymentMethodData] {
		self.paymentMethodData.filter({ value in
			!(value.isQr ?? false) && (value.isEwallet ?? false)
		})
	}

	func changeColorTab(value: CGFloat) {
		self.colorTab = value > 0 ? Color.white : Color.clear
	}

	func expireTokenAction() {
		self.backToRoot()
		self.stateObservable.userType = 0
		self.stateObservable.isVerified = ""
		self.stateObservable.refreshToken = ""
		self.stateObservable.accessToken = ""
		stateObservable.isAnnounceShow = false
		OneSignal.setExternalUserId("")
	}

	func qrData() -> [PaymentMethodData] {
		self.paymentMethodData.filter({ value in
			(value.isQr ?? false) && !(value.isEwallet ?? false)
		})
	}

	func radioButtonSelection(itemId: Int) -> Image {
		selectItem == itemId ? Image.Dinotis.radioSelectedIcon : Image.Dinotis.radioUnselectIcon
	}
	
	func routeToInvoice(id: String) {
		let viewModel = DetailPaymentViewModel(
			backToRoot: self.backToRoot,
			backToHome: self.backToHome,
			backToChoosePayment: {self.route = nil},
			bookingId: id,
            subtotal: self.price,
            extraFee: String(self.extraFee),
            serviceFee: self.actualServiceFee
		)
		
		DispatchQueue.main.async { [weak self] in
			self?.route = .detailPayment(viewModel: viewModel)
		}
	}
	
	func onStartFetch() {
		DispatchQueue.main.async {[weak self] in
			self?.success = false
			self?.isLoading = true
			self?.isError = false
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

	func handleDefaultErrorFreePayment(error: Error) {
		DispatchQueue.main.async { [weak self] in
			self?.isLoading = false

			if let error = error as? ErrorResponse {
				self?.error = error.message.orEmpty()


				if error.statusCode.orZero() == 401 {
					self?.isRefreshFailed.toggle()
          self?.alert.isError = true
          self?.alert.message = LocalizableText.alertSessionExpired
          self?.alert.primaryButton = .init(
            text: LocalizableText.okText,
            action: { self?.backToRoot() }
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
	
	func loadPaymentMethod() async {
		onStartFetch()

		let result = await paymentMethodUseCase.execute()

		switch result {
		case .success(let success):
			DispatchQueue.main.async {[weak self] in
				self?.paymentMethodData = success
			}

		case .failure(let failure):
			handleDefaultErrorFreePayment(error: failure)
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
	
	func onStartSend() {
		DispatchQueue.main.async {[weak self] in
			self?.isSuccessSend = false
			self?.isLoading = true
			self?.isError = false
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

	func openURL(url: String) {
		if let url = URL(string: url) {
			UIApplication.shared.open(url, options: [:])
		}
	}
    
    func routeToSuccess(id: String) {
        let viewModel = InvoicesBookingViewModel(
            bookingId: id,
            backToRoot: self.backToRoot,
            backToHome: self.backToHome,
            backToChoosePayment: { self.route = nil })
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .bookingInvoice(viewModel: viewModel)
        }
    }

	func sendPayment() async {
		onStartSend()
        
        if isRateCard {
            let body = RequestSessionRequest(
                paymentMethod: selectItem,
                rateCardId: meetingId,
                message: rateCardMessage
            )

			let result = await requestSessionUseCase.execute(with: body)

			switch result {
			case .success(let success):
				DispatchQueue.main.async { [weak self] in
					self?.isLoading = false

					self?.bookData = success
					self?.bookId = success.id.orEmpty()
					self?.redirectUrl = success.bookingPayment?.redirectUrl
					self?.qrCodeUrl = success.bookingPayment?.qrCodeUrl
					self?.isQR = (success.bookingPayment?.paymentMethod?.isQr).orFalse()
					self?.isEwallet = (success.bookingPayment?.paymentMethod?.isEwallet).orFalse()

					if (self?.isEwallet).orFalse() {

						self?.openURL(url: (success.bookingPayment?.redirectUrl).orEmpty())

					} else if (self?.total).orZero() == 0 {
						self?.routeToSuccess(id: (success.bookingPayment?.bookingID).orEmpty())
					} else {
						self?.routeToInvoice(id: (success.bookingPayment?.bookingID).orEmpty())
					}
				}
			case .failure(let failure):
				handleDefaultErrorFreePayment(error: failure)
			}
        } else {
            
            let params = BookingPaymentRequest(paymentMethod: selectItem, meetingId: meetingId, voucherCode: promoCode.isEmpty && (promoCodeData?.isActive ?? false) ? nil : promoCode)

			let result = await bookingPaymentUseCase.execute(with: params)

			switch result {
			case .success(let success):
				DispatchQueue.main.async { [weak self] in
					self?.isSuccessSend = true
					self?.isLoading = false

					self?.bookData = success
					self?.bookId = success.id.orEmpty()
					self?.redirectUrl = success.bookingPayment?.redirectUrl
					self?.qrCodeUrl = success.bookingPayment?.qrCodeUrl
					self?.isQR = success.bookingPayment?.paymentMethod?.isQr ?? false
					self?.isEwallet = success.bookingPayment?.paymentMethod?.isEwallet ?? false

					if self?.isEwallet ?? false {
						if let url = URL(string: (success.bookingPayment?.redirectUrl).orEmpty()) {
							UIApplication.shared.open(url, options: [:])
						}

					} else if (self?.total).orZero() == 0 {
                        self?.routeToSuccess(id: (success.bookingPayment?.bookingID).orEmpty())
					} else {
						self?.routeToInvoice(id: (success.bookingPayment?.bookingID).orEmpty())
					}
				}
			case .failure(let failure):
				handleDefaultErrorFreePayment(error: failure)
			}
        }
		
	}
	
	func extraFees() async {
		onStartFetch()
        
        let body = PaymentExtraFeeRequest(meetingId: isRateCard ? nil : meetingId, rateCardId: isRateCard ? meetingId : nil)

		let result = await extraFeeUseCase.execute(by: body)

		switch result {
		case .success(let success):
			DispatchQueue.main.async { [weak self] in
				self?.success = true
				self?.isLoading = false
				self?.extraFee = success
			}
		case .failure(let failure):
			handleDefaultErrorFreePayment(error: failure)
		}
	}
}
