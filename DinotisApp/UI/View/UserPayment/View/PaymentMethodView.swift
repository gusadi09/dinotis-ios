//
//  PaymentMethodView.swift
//  DinotisApp
//
//  Created by Gus Adi on 06/09/21.
//

import DinotisData
import DinotisDesignSystem
import SwiftUI
import SwiftUITrackableScrollView
import SwiftUINavigation

struct PaymentMethodView: View {
	
	@ObservedObject var stateObservable = StateObservable.shared
	
	@ObservedObject var viewModel: PaymentMethodsViewModel
	
	@Environment(\.dismiss) var dismiss
    
    @Binding var mainTabValue: TabRoute
	
	var body: some View {
		ZStack {
			Image.Dinotis.userTypeBackground
				.resizable()
				.edgesIgnoringSafeArea(.all)
			
			VStack(spacing: 0) {
				VStack(spacing: 0) {
					viewModel.colorTab
						.frame(height: 20)

					NavigationHeader(colorTab: $viewModel.colorTab)
				}
				
				TrackableScrollView(.vertical, showIndicators: false, contentOffset: $viewModel.contentOffset) {
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
					}
					.padding()
					.valueChanged(value: viewModel.contentOffset) { val in
						viewModel.changeColorTab(value: val)
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
                            viewModel: viewModel.wrappedValue, mainTabValue: $mainTabValue
						)
					},
					onNavigate: {_ in},
					label: {
						EmptyView()
					}
				)

				NavigationLink(
					unwrapping: $viewModel.route,
					case: /HomeRouting.bookingInvoice
				) { viewModel in
                    UserInvoiceBookingView(viewModel: viewModel.wrappedValue, mainTabValue: $mainTabValue)
				} onNavigate: { _ in } label: {
					EmptyView()
				}
			}
			.edgesIgnoringSafeArea(.vertical)
			.onAppear {
				Task {
					await viewModel.loadPaymentMethod()
				}
			}
			
            DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
		}
    .dinotisAlert(
      isPresent: $viewModel.isShowAlert,
      title: viewModel.alert.title,
      isError: viewModel.alert.isError,
      message: viewModel.alert.message,
      primaryButton: viewModel.alert.primaryButton,
      secondaryButton: viewModel.alert.secondaryButton
    )
		.onChange(of: stateObservable.isShowInvoice) { newValue in
			if newValue {
				viewModel.routeToInvoice()
			}
		}
		.onAppear {
			Task {
				await viewModel.extraFees()
			}
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
        PaymentMethodView(viewModel: PaymentMethodsViewModel(price: "", meetingId: "", rateCardMessage: "", requestTime: "", isRateCard: false, backToHome: {}), mainTabValue: .constant(.agenda))
	}
}
