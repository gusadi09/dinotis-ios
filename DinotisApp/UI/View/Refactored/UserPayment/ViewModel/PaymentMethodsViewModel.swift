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

final class PaymentMethodsViewModel: ObservableObject {
	
	var backToRoot: () -> Void
	var backToHome: () -> Void
	
	private var stateObservable = StateObservable.shared
	
	private let paymentRepository: PaymentRepository
	private let authRepository: AuthenticationRepository
	
	private var cancellables = Set<AnyCancellable>()
	
	@Published var route: HomeRouting?
	
	@Published var isLoading = false
	@Published var isError = false
	@Published var success = false
	@Published var error: HMError?
	@Published var isSuccessSend = false
	@Published var discount = 0

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
	
	@Published var bookData: BookingData?
	
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
		backToRoot: @escaping (() -> Void),
		backToHome: @escaping (() -> Void),
		paymentRepository: PaymentRepository = PaymentDefaultRepository(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository()
	) {
		self.price = price
		self.meetingId = meetingId
		self.backToRoot = backToRoot
		self.backToHome = backToHome
		self.paymentRepository = paymentRepository
		self.authRepository = authRepository
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
		}
	}

	func checkPromoCode() {
		onStartCheckCode()

		let body = PromoCodeBody(code: promoCode, meetingId: meetingId, paymentMethodId: selectItem)

		paymentRepository.provideCheckPromoCode(by: body)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.checkPromoCode ?? {})
						} else {
							self?.promoCodeError = true
							self?.isLoading = false

							self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						}
					}

				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.promoCodeSuccess = true
						self?.isLoading = false
					}
				}
			} receiveValue: { value in
				self.promoCodeData = value

				self.discount = value.discountTotal.orZero()

				if value.percentageAmount.orZero() != 0 &&
						value.cashbackPercentageAmount.orZero() == 0 &&
						value.cashbackAmount.orZero() == 0 &&
						value.amount.orZero() == 0
				{
					self.promoCodeTextArray.append(LocaleText.discountPercentageText("\(value.percentageAmount.orZero())"))

				} else if value.percentageAmount.orZero() == 0 &&
										value.cashbackPercentageAmount.orZero() == 0 &&
										value.cashbackAmount.orZero() == 0 &&
										value.amount.orZero() != 0
				{
					self.promoCodeTextArray.append( LocaleText.discountPriceText("\(value.amount.orZero())".toCurrency()))
				} else if value.percentageAmount.orZero() == 0 &&
										value.cashbackPercentageAmount.orZero() != 0 &&
										value.cashbackAmount.orZero() == 0 &&
										value.amount.orZero() == 0
				{
					self.promoCodeTextArray.append(LocaleText.cashbackPercentageText("\(value.cashbackPercentageAmount.orZero())"))
				} else if value.percentageAmount.orZero() == 0 &&
										value.cashbackPercentageAmount.orZero() == 0 &&
										value.cashbackAmount.orZero() != 0 &&
										value.amount.orZero() == 0
				{
					self.promoCodeTextArray.append(LocaleText.cashbackCoinText("\(value.cashbackAmount.orZero())".toPriceFormat()))
				} else if value.percentageAmount.orZero() != 0 &&
										value.cashbackPercentageAmount.orZero() != 0 &&
										value.cashbackAmount.orZero() == 0 &&
										value.amount.orZero() == 0
				{
					self.promoCodeTextArray.append(LocaleText.discountPercentageText("\(value.percentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.cashbackPercentageText("\(value.cashbackPercentageAmount.orZero())"))
				} else if value.percentageAmount.orZero() == 0 &&
										value.cashbackPercentageAmount.orZero() == 0 &&
										value.cashbackAmount.orZero() != 0 &&
										value.amount.orZero() != 0 {
					self.promoCodeTextArray.append(LocaleText.discountPriceText("\(value.amount.orZero())".toCurrency()))
					self.promoCodeTextArray.append(LocaleText.cashbackCoinText("\(value.cashbackAmount.orZero())".toPriceFormat()))
				} else if value.percentageAmount.orZero() != 0 &&
										value.cashbackPercentageAmount.orZero() == 0 &&
										value.cashbackAmount.orZero() != 0 &&
										value.amount.orZero() == 0 {
					self.promoCodeTextArray.append(LocaleText.discountPercentageText("\(value.percentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.cashbackCoinText("\(value.cashbackAmount.orZero())".toPriceFormat()))
				} else if value.percentageAmount.orZero() != 0 &&
										value.cashbackPercentageAmount.orZero() == 0 &&
										value.cashbackAmount.orZero() == 0 &&
										value.amount.orZero() != 0 {
					self.promoCodeTextArray.append(LocaleText.discountPercentageText("\(value.percentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.discountPriceText("\(value.amount.orZero())".toCurrency()))
				} else if value.percentageAmount.orZero() == 0 &&
										value.cashbackPercentageAmount.orZero() != 0 &&
										value.cashbackAmount.orZero() != 0 &&
										value.amount.orZero() == 0 {
					self.promoCodeTextArray.append(LocaleText.cashbackPercentageText("\(value.cashbackPercentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.cashbackCoinText("\(value.cashbackAmount.orZero())".toPriceFormat()))
				} else if value.percentageAmount.orZero() == 0 &&
										value.cashbackPercentageAmount.orZero() != 0 &&
										value.cashbackAmount.orZero() == 0 &&
										value.amount.orZero() != 0 {
					self.promoCodeTextArray.append(LocaleText.cashbackPercentageText("\(value.cashbackPercentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.discountPriceText("\(value.amount.orZero())".toCurrency()))
				} else if value.percentageAmount.orZero() == 0 &&
										value.cashbackPercentageAmount.orZero() != 0 &&
										value.cashbackAmount.orZero() != 0 &&
										value.amount.orZero() != 0 {
					self.promoCodeTextArray.append(LocaleText.cashbackPercentageText("\(value.cashbackPercentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.cashbackCoinText("\(value.cashbackAmount.orZero())".toPriceFormat()))
					self.promoCodeTextArray.append(LocaleText.discountPriceText("\(value.amount.orZero())".toCurrency()))
				} else if value.percentageAmount.orZero() != 0 &&
										value.cashbackPercentageAmount.orZero() == 0 &&
										value.cashbackAmount.orZero() != 0 &&
										value.amount.orZero() != 0 {
					self.promoCodeTextArray.append(LocaleText.discountPercentageText("\(value.percentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.cashbackCoinText("\(value.cashbackAmount.orZero())".toPriceFormat()))
					self.promoCodeTextArray.append(LocaleText.discountPriceText("\(value.amount.orZero())".toCurrency()))
				} else if value.percentageAmount.orZero() != 0 &&
										value.cashbackPercentageAmount.orZero() != 0 &&
										value.cashbackAmount.orZero() == 0 &&
										value.amount.orZero() != 0 {
					self.promoCodeTextArray.append(LocaleText.discountPercentageText("\(value.percentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.cashbackPercentageText("\(value.cashbackPercentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.discountPriceText("\(value.amount.orZero())".toCurrency()))
				} else if value.percentageAmount.orZero() != 0 &&
										value.cashbackPercentageAmount.orZero() != 0 &&
										value.cashbackAmount.orZero() != 0 &&
										value.amount.orZero() == 0 {
					self.promoCodeTextArray.append(LocaleText.discountPercentageText("\(value.percentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.cashbackPercentageText("\(value.cashbackPercentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.cashbackCoinText("\(value.cashbackAmount.orZero())".toPriceFormat()))
				} else {
					self.promoCodeTextArray.append(LocaleText.discountPercentageText("\(value.percentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.cashbackPercentageText("\(value.cashbackPercentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.cashbackCoinText("\(value.cashbackAmount.orZero())".toPriceFormat()))
					self.promoCodeTextArray.append(LocaleText.discountPriceText("\(value.amount.orZero())".toCurrency()))
				}
			}
			.store(in: &cancellables)

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
	
	func routeToInvoice() {
		let viewModel = DetailPaymentViewModel(
			backToRoot: self.backToRoot,
			backToHome: self.backToHome,
			methodName: selectedString.orEmpty(),
			methodIcon: selectedIcon.orEmpty(),
			redirectUrl: self.redirectUrl,
			qrCodeUrl: self.qrCodeUrl,
			bookingId: self.bookId,
			isQR: self.isQR,
			isEwallet: self.isEwallet
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
		}
	}
	
	func loadPaymentMethod() {
		onStartFetch()
		
		paymentRepository
			.provideGetPaymentMethod()
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.loadPaymentMethod ?? {})
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
				self.paymentMethodData = value.data ?? []
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
	
	func onStartSend() {
		DispatchQueue.main.async {[weak self] in
			self?.isSuccessSend = false
			self?.isLoading = true
			self?.isError = false
			self?.error = nil
		}
	}
	
	func sendPayment() {
		onStartSend()
		
		let params = BookingPay(paymentMethod: total == 0 ? 99 : selectItem, meetingId: meetingId, voucherCode: promoCode.isEmpty ? nil : promoCode)
		
		paymentRepository
			.provideSendBookingPayment(by: params)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.sendPayment ?? {})
						} else {
							self?.isError = true
							self?.isLoading = false
							
							self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						}
					}
					
				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.isSuccessSend = true
						self?.isLoading = false
					}
				}
			} receiveValue: { value in
				self.bookData = value
				self.bookId = value.id
				self.redirectUrl = value.bookingPayment.redirectUrl
				self.qrCodeUrl = value.bookingPayment.qrCodeUrl
				self.isQR = value.bookingPayment.paymentMethod?.isQr ?? false
				self.isEwallet = value.bookingPayment.paymentMethod?.isEwallet ?? false
				
				if self.isEwallet {
					self.backToHome()
					if let url = URL(string: value.bookingPayment.redirectUrl.orEmpty()) {
						UIApplication.shared.open(url, options: [:])
					}

				} else if self.total == 0 {
					self.successFree.toggle()
				} else {
					self.routeToInvoice()
				}
				
			}
			.store(in: &cancellables)
		
	}
	
	func extraFees() {
		onStartFetch()
		
		paymentRepository
			.provideExtraFee(with: meetingId)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.extraFees ?? {})
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
				self.extraFee = value.extraFee.orZero()
			}
			.store(in: &cancellables)
		
	}
}
