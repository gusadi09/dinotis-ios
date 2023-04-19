//
//  TalentAddBankAccountView.swift
//  DinotisApp
//
//  Created by Gus Adi on 30/08/21.
//

import DinotisDesignSystem
import SDWebImageSwiftUI
import SwiftUI
import SwiftKeychainWrapper

struct TalentAddBankAccountView: View {
	@ObservedObject var viewModel: TalentAddBankAccountViewModel
	
	@Environment(\.presentationMode) var presentationMode

	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
	
	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}
	
	var body: some View {
		ZStack {
			
			ZStack(alignment: .top) {
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
					HStack(alignment: . center) {
						Button(action: {
							presentationMode.wrappedValue.dismiss()
						}, label: {
							Image.Dinotis.arrowBackIcon
								.padding()
								.background(Color.white)
								.clipShape(Circle())
						})
						.padding(.leading)
						.padding(.trailing, 20)
						
						HStack {
							Text(viewModel.headerTitle())
								.font(.robotoBold(size: 14))
								.foregroundColor(.black)
							
							Spacer()
						}
						.padding()
						
					}
					.padding(.top, 5)
					.alert(isPresented: $viewModel.isError) {
						Alert(
							title: Text(LocaleText.attention),
							message: Text(viewModel.error.orEmpty()),
							dismissButton: .default(Text(LocaleText.returnText))
						)
					}

					ScrollView(.vertical, showsIndicators: false) {
						VStack(spacing: 15) {
							VStack(alignment: .leading) {
								Text(LocaleText.bankNameText)
									.font(.robotoMedium(size: 12))
									.foregroundColor(.black)
									.alert(isPresented: $viewModel.success) {
										Alert(
											title: Text(LocaleText.successTitle),
											message: Text(LocaleText.bankAccountUpdateSuccessText),
											dismissButton: .default(
												Text(LocaleText.returnText),
												action: {
													presentationMode.wrappedValue.dismiss()
												}
											)
										)
									}

								Button(action: {
									viewModel.isPresentBank.toggle()
								}, label: {
									HStack {
										Text(viewModel.selectionBank == nil ? LocaleText.selectBankAlt : (viewModel.selectionBank?.name).orEmpty())
											.font(.robotoRegular(size: 12))
											.foregroundColor(viewModel.selectionBank == nil ? Color(.systemGray4) : .black)
											.padding(.horizontal)
											.padding(.vertical, 15)

										Spacer()

										Image.Dinotis.chevronBottomIcon
											.resizable()
											.scaledToFit()
											.frame(height: 20)
											.padding(.trailing, 10)
									}
									.overlay(
										RoundedRectangle(cornerRadius: 6)
											.stroke(Color(.systemGray4), lineWidth: 1.0)
									)
								})
							}

							VStack(alignment: .leading) {
								Text(LocaleText.accountNumberText)
									.font(.robotoMedium(size: 12))
									.foregroundColor(.black)

								TextField(LocaleText.accountNumberPlaceholder, text: $viewModel.accountNumber)
									.font(.robotoRegular(size: 12))
									.keyboardType(.numberPad)
									.foregroundColor(.black)
									.accentColor(.black)
									.padding(.horizontal)
									.padding(.vertical, 15)
									.overlay(
										RoundedRectangle(cornerRadius: 6)
											.stroke(Color(.systemGray4), lineWidth: 1.0)
									)
							}

							VStack(alignment: .leading) {
								Text(LocaleText.accountNameTitle)
                                    .font(.robotoMedium(size: 12))
									.foregroundColor(.black)

								TextField(LocaleText.accountNamePlaceholder, text: $viewModel.accountName)
									.font(.robotoRegular(size: 12))
									.autocapitalization(.words)
									.disableAutocorrection(true)
									.foregroundColor(.black)
									.accentColor(.black)
									.padding(.horizontal)
									.padding(.vertical, 15)
									.overlay(
										RoundedRectangle(cornerRadius: 6)
											.stroke(Color(.systemGray4), lineWidth: 1.0)
									)
							}
						}
						.padding(.horizontal)
						.padding(.vertical, 25)
						.background(Color.white)
						.cornerRadius(12)
						.padding()
					}

					VStack(spacing: 0) {
						Button(action: {
                            Task {
                                if viewModel.bankData.first != nil {
                                    await viewModel.editBankAccount()
                                } else {
                                    await viewModel.addBankAccount()
                                }
                            }
						}, label: {
							HStack {
								Spacer()
								Text(LocaleText.saveAccountText)
									.font(.robotoMedium(size: 12))
									.foregroundColor(.white)
									.padding(10)
									.padding(.horizontal, 5)
									.padding(.vertical, 5)

								Spacer()
							}
							.background(Color.DinotisDefault.primary)
							.clipShape(RoundedRectangle(cornerRadius: 8))
						})
						.padding()
						.background(
							Color.white
								.edgesIgnoringSafeArea(.vertical)
						)
					}
				}
			}
			
            DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
		}
		.sheet(isPresented: $viewModel.isPresentBank) {
			VStack {
				HStack {
					Text(LocaleText.selectBankText)
						.font(.robotoMedium(size: 14))

					Spacer()
					Button(action: {
						viewModel.isPresentBank.toggle()
					}, label: {
						Image(systemName: "xmark")
							.resizable()
							.scaledToFit()
							.frame(height: 10)
							.font(.system(size: 10, weight: .bold, design: .rounded))
							.foregroundColor(.black)
					})
				}
				.padding(.horizontal)
				.padding(.top)

				HStack(spacing: 15) {
					Image.Dinotis.magnifyingIcon

					TextField(LocaleText.searchBankText, text: $viewModel.searchBank)
						.font(.robotoRegular(size: 12))
						.autocapitalization(.words)
						.disableAutocorrection(true)
						.accentColor(.black)
				}
				.padding()
				.background(Color.backgroundProfile)
				.cornerRadius(8)
				.overlay(
					RoundedRectangle(cornerRadius: 8)
						.stroke(Color.gray.opacity(0.3), lineWidth: 1.0)
				)
				.padding(.horizontal)
				.padding(.top, 10)

                ScrollView(.vertical, showsIndicators: false, content: {
                    ForEach(viewModel.bankList.filter({ val in
                        viewModel.searchBank.isEmpty ? true : (val.name.orEmpty()).contains(viewModel.searchBank)
                    }), id: \.id) { items in
                        VStack {
                            HStack {
                                WebImage(url: URL(string: items.iconUrl.orEmpty()))
                                    .resizable()
                                    .customLoopCount(1)
                                    .playbackRate(2.0)
                                    .placeholder {
                                        Image(systemName: "creditcard.fill")
                                            .foregroundColor(Color(.systemGray3))
                                            .frame(width: 45, height: 25)
                                    }
                                    .indicator(.activity)
                                    .transition(.fade(duration: 0.5))
                                    .scaledToFit()
                                    .frame(height: 14)
                                
                                Text(items.name.orEmpty())
                                    .font(.robotoRegular(size: 12))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 10)
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(.black)
                            }
                            .padding(.vertical, 15)
                            
                            Divider()
                        }
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectionBank = items
                            viewModel.isPresentBank.toggle()
                        }
                    }
                })
            }
		}
		.onAppear {
			viewModel.onAppear()
		}
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}
