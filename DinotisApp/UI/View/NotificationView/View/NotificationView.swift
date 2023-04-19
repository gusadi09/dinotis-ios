//
//  NotificationView.swift
//  DinotisApp
//
//  Created by Gus Adi on 04/08/21.
//

import SwiftUI
import DinotisDesignSystem

struct NotificationView: View {

	@ObservedObject var viewModel: NotificationViewModel
    @Environment(\.presentationMode) var presentationMode

	var body: some View {
		ZStack {

			Color.DinotisDefault.baseBackground
				.edgesIgnoringSafeArea(.all)

			VStack(spacing: 0) {
				HeaderView(
					type: .textHeader,
					title: LocalizableText.notificationTitle,
					headerColor: .white,
					leadingButton: {
						DinotisElipsisButton(
							icon: .generalBackIcon,
							iconColor: .DinotisDefault.black1,
							bgColor: .DinotisDefault.white,
							strokeColor: nil,
							iconSize: 12,
							type: .primary, {
								self.presentationMode.wrappedValue.dismiss()
							}
						)
						.shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 0)
					},
                    trailingButton: {
                        DinotisNudeButton(text: LocalizableText.notificationReadAll, textColor: .DinotisDefault.primaryActive, fontSize: 14) {
                            Task {
                                await viewModel.readAll()
                            }
                        }
                    }
				)
				.onChange(of: viewModel.type) { newValue in
                    Task {
                        viewModel.query.type = newValue
                        viewModel.query.skip = 0
                        viewModel.query.take = 15
                        
                        await viewModel.getNotifications(isReplacing: true)
                    }
				}
				.onChange(of: Locale.current.languageCode) { newValue in
                    Task {
                        viewModel.query.lang = newValue.orEmpty()
                        viewModel.query.skip = 0
                        viewModel.query.take = 15
                        
                        await viewModel.getNotifications(isReplacing: true)
                    }
				}

                if viewModel.stateObservable.userType == 3 {
                    HStack {
                        Button {
                            withAnimation {
                                viewModel.type = "general"
                            }
                            
                        } label: {
                            VStack(spacing: 0) {
                                HStack {
                                    Spacer()
                                    
                                    Text(LocalizableText.notificationGeneralTabText)
                                        .font(viewModel.type == "general" ? .robotoMedium(size: 14) : .robotoRegular(size: 14))
                                        .foregroundColor(.black)
                                        .padding(.bottom, 15)
                                    
                                    Spacer()
                                }
                                
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(viewModel.type == "general" ? .DinotisDefault.primary : .white)
                            }
                        }
                        
                        Button {
                            withAnimation {
                                viewModel.type = "transaction"
                            }
                            
                        } label: {
                            VStack(spacing: 0) {
                                HStack {
                                    Spacer()
                                    
                                    Text(LocalizableText.notificationTransactionTabText)
                                        .font(viewModel.type == "transaction" ? .robotoMedium(size: 14) : .robotoRegular(size: 14))
                                        .foregroundColor(.black)
                                        .padding(.bottom, 15)
                                    
                                    Spacer()
                                }
                                
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(viewModel.type == "transaction" ? .DinotisDefault.primary : .white)
                            }
                        }
                    }
                    .background(
                        Color.white
                    )
                }

				TabView(selection: $viewModel.type) {
					RefreshableScrollViews {
                        Task {
                            await viewModel.getNotifications(isReplacing: true)
                        }
					} content: {
						HStack {
							Spacer()

							ProgressView()
								.progressViewStyle(.circular)
								.padding(.vertical, 10)

							Spacer()
						}
						.isHidden(!viewModel.isLoading, remove: !viewModel.isLoading)

						LazyVStack(spacing: 0) {

							if viewModel.resultGeneral.isEmpty {
								VStack(spacing: 15) {
									Image.notificationEmptyImage
										.resizable()
										.scaledToFit()
										.frame(height: 182)

									Text(LocalizableText.notificationEmptyTitle)
										.font(.robotoBold(size: 14))
										.foregroundColor(.black)

									Text(LocalizableText.notificationEmptyDescription)
										.font(.robotoRegular(size: 12))
										.foregroundColor(.black)
								}
								.multilineTextAlignment(.center)
								.padding()
							} else {
								ForEach(viewModel.resultGeneral, id: \.?.id) { item in
									VStack(spacing: 0) {
										NotificationCard(data: viewModel.convertToNotificationModel(raw: item))
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                Task {
                                                    await viewModel.readById(id: item?.id)
                                                }
                                            }

										Divider()
											.padding(.horizontal)
									}
									.onAppear {
                                        Task {
                                            if item?.id == viewModel.resultGeneral.last??.id {
                                                if viewModel.nextCursor != nil {
                                                    viewModel.query.skip = viewModel.query.take
                                                    viewModel.query.take += 15
                                                    
                                                    await viewModel.getNotifications(isReplacing: false)
                                                }
                                            }
                                        }
									}
								}
							}
						}
					}
					.tag("general")

					RefreshableScrollViews {
						withAnimation {
							viewModel.isLoading.toggle()
						}

						DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
							withAnimation {
								viewModel.isLoading.toggle()
							}

						}
					} content: {
						HStack {
							Spacer()

							ProgressView()
								.progressViewStyle(.circular)
								.padding(.vertical, 10)

							Spacer()
						}
						.isHidden(!viewModel.isLoading, remove: !viewModel.isLoading)

						LazyVStack(spacing: 0) {

							if viewModel.resultTrans.isEmpty {
								VStack(spacing: 15) {
									Image.notificationEmptyImage
										.resizable()
										.scaledToFit()
										.frame(height: 182)

									Text(LocalizableText.notificationTransactionEmptyTitle)
										.font(.robotoBold(size: 14))
										.foregroundColor(.black)

									Text(LocalizableText.notificationTransactionEmptyDescription)
										.font(.robotoRegular(size: 12))
										.foregroundColor(.black)
								}
								.multilineTextAlignment(.center)
								.padding()
							} else {
								ForEach(viewModel.resultTrans, id: \.?.id) { item in
									VStack(spacing: 0) {
										NotificationCard(data: viewModel.convertToNotificationModel(raw: item))
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                Task {
                                                    await viewModel.readById(id: item?.id)
                                                }
                                            }


										Divider()
											.padding(.horizontal)
									}
									.onAppear {
                                        Task {
                                            if item?.id == viewModel.resultTrans.last??.id {
                                                if viewModel.nextCursor != nil {
                                                    viewModel.query.skip = viewModel.query.take
                                                    viewModel.query.take += 15
                                                    
                                                    await viewModel.getNotifications(isReplacing: false)
                                                }
                                            }
                                        }
									}
								}
							}
						}
					}
					.tag("transaction")
				}
				.tabViewStyle(.page(indexDisplayMode: .never))
			}
            
            DinotisLoadingView(.small, hide: !viewModel.isReadLoading)
		}
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
		.onAppear {
            Task {
                await viewModel.getNotifications(isReplacing: true)
            }
		}
    .dinotisAlert(
      isPresent: $viewModel.isShowAlert,
      title: viewModel.alert.title,
      isError: viewModel.alert.isError,
      message: viewModel.alert.message,
      primaryButton: viewModel.alert.primaryButton,
      secondaryButton: viewModel.alert.secondaryButton
    )
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
		NotificationView(viewModel: NotificationViewModel(backToRoot: {}, backToHome: {}))
    }
}
