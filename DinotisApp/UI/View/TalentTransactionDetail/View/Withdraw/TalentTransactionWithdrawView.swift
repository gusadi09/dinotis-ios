//
//  TalentTransactionWithdrawView.swift
//  DinotisApp
//
//  Created by Gus Adi on 09/09/21.
//

import CurrencyFormatter
import DinotisDesignSystem
import SwiftUI
import SwiftKeychainWrapper
import SwiftUITrackableScrollView

struct TalentTransactionWithdrawView: View {

	@Environment(\.presentationMode) var presentationMode

	@ObservedObject var viewModel: TalentTransactionDetailViewModel

	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
	
	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}
	
	var body: some View {
		ZStack {
			Image.Dinotis.userTypeBackground
				.resizable()
				.edgesIgnoringSafeArea(.all)
				.alert(isPresented: $viewModel.isRefreshFailed) {
					Alert(
						title: Text(LocaleText.attention),
						message: Text(LocaleText.sessionExpireText),
						dismissButton: .default(
							Text(LocaleText.returnText),
							action: {
								viewModel.routeToRoot()
							}
						)
					)
				}
			
			VStack(spacing: 0) {
				VStack(spacing: 0) {
					
					HStack {
						Button(action: {
							presentationMode.wrappedValue.dismiss()
						}, label: {
							Image.Dinotis.arrowBackIcon
								.padding()
								.background(Color.white)
								.clipShape(Circle())
						})
						
						Spacer()
						
						Text(LocaleText.withdrawText)
							.font(.robotoBold(size: 14))
							.padding(.horizontal)
							.padding(.trailing)

						Spacer()
					}
					.padding()
					.background(viewModel.colorTab.edgesIgnoringSafeArea(.vertical))
					.alert(isPresented: $viewModel.isError) {
						Alert(
							title: Text(LocaleText.attention),
							message: Text(viewModel.error.orEmpty()),
							dismissButton: .default(Text(LocaleText.returnText))
						)
					}
				}
				
				TrackableScrollView(.vertical, showIndicators: false, contentOffset: $viewModel.contentOffset) {
					VStack {
						VStack(alignment: .leading) {
							HStack {
								Image.Dinotis.withdrawTalentIcon
									.resizable()
									.scaledToFit()
									.frame(height: 40)
								
								VStack(alignment: .leading, spacing: 5) {
									Text(LocaleText.withdrawText)
										.font(.robotoBold(size: 14))
										.foregroundColor(.black)
									
									if let dateISO = viewModel.withdrawData?.createdAt {
                                        Text(DateUtils.dateFormatter(dateISO, forFormat: .EEEEddMMMMyyyy))
											.font(.robotoRegular(size: 12))
											.foregroundColor(.black)
									}
								}
								
								Spacer()
								
								Text("- \((viewModel.withdrawData?.amount?.numberString).orEmpty().toCurrency())")
									.font(.robotoBold(size: 14))
									.foregroundColor(.black)
							}
							
							Divider()
								.padding(.vertical, 10)
							
							HStack {
								VStack(alignment: .leading, spacing: 20) {
									
									HStack(spacing: 10) {
										Image.Dinotis.handPickedDebitCardIcon
											.resizable()
											.scaledToFit()
											.frame(height: 32)
										
										VStack(alignment: .leading, spacing: 5) {
											Text(LocaleText.bankNameText)
												.font(.robotoRegular(size: 12))
												.foregroundColor(.black)
											
											Text((viewModel.withdrawData?.bankAccount?.accountNumber).orEmpty())
												.font(.robotoBold(size: 14))
												.foregroundColor(.black)
										}
									}
									
									HStack(spacing: 10) {
										Image.Dinotis.peopleCircleIcon
											.resizable()
											.scaledToFit()
											.frame(height: 32)
										
										VStack(alignment: .leading, spacing: 5) {
											Text(LocaleText.accountNameTitle)
												.font(.robotoRegular(size: 12))
												.foregroundColor(.black)
											
											Text((viewModel.withdrawData?.bankAccount?.accountName).orEmpty())
												.font(.robotoBold(size: 14))
												.foregroundColor(.black)
										}
									}
									
									HStack(spacing: 10) {
										Image.Dinotis.calendarIcon
											.resizable()
											.scaledToFit()
											.frame(height: 32)
										
										VStack(alignment: .leading, spacing: 5) {
											Text(LocaleText.withdrawalDateText)
												.font(.robotoRegular(size: 12))
												.foregroundColor(.black)
											
											if let dateISO = viewModel.withdrawData?.createdAt {
                                                Text(DateUtils.dateFormatter(dateISO, forFormat: .EEEEddMMMMyyyy))
													.font(.robotoBold(size: 14))
													.foregroundColor(.black)
											}
										}
									}
									
									HStack(spacing: 10) {
										Image.Dinotis.clockIcon
											.resizable()
											.scaledToFit()
											.frame(height: 32)
										
										VStack(alignment: .leading, spacing: 5) {
											Text(LocaleText.withdrawalTimeText)
												.font(.robotoRegular(size: 12))
												.foregroundColor(.black)
											
											if let timeISO = viewModel.withdrawData?.createdAt {
                                                Text(DateUtils.dateFormatter(timeISO, forFormat: .HHmm))
													.font(.robotoBold(size: 14))
													.foregroundColor(.black)
											}
										}
									}
								}
								
								Spacer()
							}
							.padding(.bottom, 15)
							
							if viewModel.withdrawData?.doneAt == nil && !(viewModel.withdrawData?.isFailed ?? false) {
								HStack {
									Spacer()
									
									Text(LocaleText.inProcessText)
										.font(.robotoMedium(size: 12))
									
									Spacer()
								}
								.padding()
								.background(Color.secondaryViolet)
								.cornerRadius(8)
								.overlay(
									RoundedRectangle(cornerRadius: 8).stroke(Color.DinotisDefault.primary, lineWidth: 1.0)
								)
							} else if viewModel.withdrawData?.doneAt != nil {
								HStack {
									Spacer()
									
									Text(LocaleText.successTitle)
										.font(.robotoMedium(size: 12))
									
									Spacer()
								}
								.padding()
								.background(Color.completeGreen)
								.cornerRadius(8)
								.overlay(
									RoundedRectangle(cornerRadius: 8).stroke(Color.primaryGreen, lineWidth: 1.0)
								)
							} else if viewModel.withdrawData?.isFailed ?? false {
								HStack {
									Spacer()
									
									Text(LocaleText.failText)
										.font(.robotoMedium(size: 12))
									
									Spacer()
								}
								.padding()
								.background(Color.secondaryRed)
								.cornerRadius(8)
								.overlay(
									RoundedRectangle(cornerRadius: 8).stroke(Color.primaryRed, lineWidth: 1.0)
								)
							}
						}
						.padding()
						.background(Color.white)
						.clipShape(RoundedRectangle(cornerRadius: 12))
						.shadow(color: Color.dinotisShadow.opacity(0.1), radius: 10, x: 0.0, y: 0.0)
						.padding(.top, 10)
					}
					.padding()
					.valueChanged(value: viewModel.contentOffset) { val in
						viewModel.colorTab = val > 0 ? Color.white : Color.clear
					}
					.onAppear {
                        Task {
                            await viewModel.getTransactionDetail()
                        }
					}
				}
			}
			
            DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
		}
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}
