//
//  PaymentMethodView.swift
//  DinotisApp
//
//  Created by Gus Adi on 06/09/21.
//

import SwiftUI
import SwiftUITrackableScrollView
import SwiftUINavigation

struct PaymentMethodView: View {
	
	@ObservedObject var stateObservable = StateObservable.shared
	
	@ObservedObject var viewModel: PaymentMethodsViewModel
	
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		ZStack {
			Image.Dinotis.userTypeBackground
				.resizable()
				.edgesIgnoringSafeArea(.all)
			
			VStack(spacing: 0) {
				VStack(spacing: 0) {
					viewModel.colorTab
						.frame(height: 20)
						.alert(isPresented: $viewModel.successFree) {
							Alert(
								title: Text(LocaleText.successTitle),
								message: Text(LocaleText.successLabels),
								dismissButton: .default(Text(LocaleText.okText), action: {
									viewModel.backToHome()
								}))
						}

					NavigationHeader(colorTab: $viewModel.colorTab)
						.alert(isPresented: $viewModel.isRefreshFailed) {
							Alert(
								title: Text(LocaleText.attention),
								message: Text(LocaleText.sessionExpireText),
								dismissButton: .default(Text(LocaleText.returnText), action: {
									viewModel.expireTokenAction()
								}))
						}
				}
				
				TrackableScrollView(.vertical, showIndicators: false, contentOffset: $viewModel.contentOffset) {
					if #available(iOS 14.0, *) {
						LazyVStack {
							PaymentMethodGroup(
								title: LocaleText.virtualAccountText,
								serviceFee: String(4500).toCurrency(),
								isEwallet: false,
								paymentMethodData: viewModel.virtualAccountData(),
								viewModel: viewModel
							)

							PaymentMethodGroup(
								title: LocaleText.ewalletText,
								serviceFee: "1.5%",
								isEwallet: true,
								paymentMethodData: viewModel.eWalletData(),
								viewModel: viewModel
							)

							PaymentMethodGroup(
								title: LocaleText.qrisText,
								serviceFee: "0.7%",
								isEwallet: true,
								paymentMethodData: viewModel.qrData(),
								viewModel: viewModel
							)

							Group {
								if viewModel.selectItem != 0 {
									PromoCodeEntry(viewModel: viewModel)
								}
							}
							.padding(.bottom)
						}
						.padding()
						.valueChanged(value: viewModel.contentOffset) { val in
							viewModel.changeColorTab(value: val)
						}
					} else {
						VStack {
							PaymentMethodGroup(
								title: LocaleText.virtualAccountText,
								serviceFee: String(4500).toCurrency(),
								isEwallet: false,
								paymentMethodData: viewModel.virtualAccountData(),
								viewModel: viewModel
							)

							PaymentMethodGroup(
								title: LocaleText.ewalletText,
								serviceFee: "1.5%",
								isEwallet: true,
								paymentMethodData: viewModel.eWalletData(),
								viewModel: viewModel
							)

							PaymentMethodGroup(
								title: LocaleText.qrisText,
								serviceFee: "0.7%",
								isEwallet: true,
								paymentMethodData: viewModel.qrData(),
								viewModel: viewModel
							)

							PromoCodeEntry(viewModel: viewModel)
								.padding(.bottom)
						}
						.padding()
						.valueChanged(value: viewModel.contentOffset) { val in
							viewModel.changeColorTab(value: val)
						}
					}
				}
				
				BottomSide(viewModel: viewModel)
					.onChange(of: viewModel.selectItem) { _ in
						viewModel.resetStateCode()
					}
				
				NavigationLink(
					unwrapping: $viewModel.route,
					case: /HomeRouting.detailPayment,
					destination: {viewModel in
						DetailPaymentView(
							methodId: $viewModel.selectItem,
							price: $viewModel.total,
							viewModel: viewModel.wrappedValue
						)
					},
					onNavigate: {_ in},
					label: {
						EmptyView()
					}
				)
			}
			.edgesIgnoringSafeArea(.vertical)
			.onAppear {
				viewModel.loadPaymentMethod()
			}
			
			LoadingView(isAnimating: $viewModel.isLoading)
				.isHidden(!viewModel.isLoading, remove: !viewModel.isLoading)
		}
		.onAppear {
			viewModel.extraFees()
		}
		.valueChanged(value: viewModel.extraFee, onChange: { value in
			viewModel.getTotal(extraFee: value)
		})
		.valueChanged(value: viewModel.serviceFee, onChange: { _ in
			viewModel.getTotal(extraFee: viewModel.extraFee)
		})
		.valueChanged(value: viewModel.promoCodeSuccess, onChange: { _ in
			viewModel.getTotal(extraFee: viewModel.extraFee)
		})
		.onDisappear {
			viewModel.resetPrice()
		}
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}

struct PaymentMethodView_Previews: PreviewProvider {
	static var previews: some View {
		PaymentMethodView(viewModel: PaymentMethodsViewModel(price: "", meetingId: "", backToRoot: {}, backToHome: {}))
	}
}
