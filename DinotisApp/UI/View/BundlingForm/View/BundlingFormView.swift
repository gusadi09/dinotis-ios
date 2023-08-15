//
//  BundlingFormView.swift
//  DinotisApp
//
//  Created by Gus Adi on 30/09/22.
//

import DinotisDesignSystem
import SwiftUI
import SwiftUINavigation

struct BundlingFormView: View {

	@ObservedObject var viewModel: BundlingFormViewModel

	@Environment(\.presentationMode) var presentationMode

    var body: some View {
		GeometryReader { geo in
            
            NavigationLink(
                unwrapping: $viewModel.route,
                case: /HomeRouting.bundlingDetail,
                destination: { viewModel in
                    BundlingDetailView(viewModel: viewModel.wrappedValue, isPreview: true, tabValue: .constant(.agenda))
                },
                onNavigate: { _ in },
                label: {
                    EmptyView()
                }
            )

			NavigationLink(
				unwrapping: $viewModel.route,
				case: /HomeRouting.createBundling,
				destination: { viewModel in
					TalentCreateBundlingView(viewModel: viewModel.wrappedValue, meetingArray: $viewModel.meetingIdArray)
				},
				onNavigate: { _ in },
				label: {
					EmptyView()
				}
			)
            
			ZStack {
				Image.Dinotis.linearGradientBackground
					.resizable()
					.edgesIgnoringSafeArea(.all)
                    .alert(isPresented: $viewModel.isBundleCreated) {
                        Alert(
                            title: Text(LocaleText.bundleSuccessTitle),
                            message: Text(LocaleText.bundleSuccessDesc),
                            dismissButton: .default(Text(LocaleText.okText), action: {
                                viewModel.backToBundlingList()
                            })
                        )
                    }

				
				VStack(spacing: 0) {
					HeaderView(viewModel: viewModel)
                        .alert(isPresented: $viewModel.isError) {
                            Alert(
                                title: Text(LocaleText.attention),
                                message: Text(viewModel.error.orEmpty()),
                                dismissButton: .default(Text(LocaleText.okText))
                            )
                        }

					ScrollView(.vertical, showsIndicators: false) {
						VStack {
							FormView(viewModel: viewModel, isEdit: viewModel.isEdit)
								.padding()
								.alert(isPresented: $viewModel.isBundleUpdated) {
									Alert(
										title: Text(LocaleText.successTitle),
										message: Text(LocaleText.successUpdateBundle),
										dismissButton: .default(Text(LocaleText.okText), action: {
											presentationMode.wrappedValue.dismiss()
										})
									)
								}

							Button {
								if viewModel.isEdit {
									viewModel.routeToCreateBundling()
								} else {
									viewModel.routeToBundlingDetail()
								}
							} label: {
								HStack {
                                    Text(
										viewModel.isEdit ?
										LocaleText.chooseSession:
										LocaleText.seeSelectedMeetingBundling(viewModel.meetingIdArray.count)
									)
										.font(.robotoRegular(size: 12))
										.foregroundColor(.DinotisDefault.primary)

									Spacer()

									Image(systemName: "chevron.right")
										.foregroundColor(.DinotisDefault.primary)
										.font(.system(size: 20, weight: .semibold, design: .rounded))
								}
								.padding()
								.background(
									RoundedRectangle(cornerRadius: 12)
										.foregroundColor(.secondaryViolet)
								)
								.overlay(
									RoundedRectangle(cornerRadius: 12)
										.stroke(Color.DinotisDefault.primary, lineWidth: 1)
								)

							}
							.padding(.horizontal)

						}
					}

					Button {
						if !viewModel.isEdit {
							viewModel.createBundle()
						} else {
							viewModel.updateBundle()
						}
					} label: {
						HStack {
                            Spacer()
                            if viewModel.isLoading {
                                if #available(iOS 15.0, *) {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .tint(.white)
                                } else {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                            } else {

								Text(viewModel.isEdit ? LocaleText.editBundling : LocaleText.bundlingCreateText)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(viewModel.isFieldEmpty() ? Color(.systemGray3) : .white)

                            }
                            Spacer()
						}
                        .padding(.vertical, viewModel.isLoading ? 12.5 : 15)
						.background(
							RoundedRectangle(cornerRadius: 12)
								.foregroundColor(viewModel.isFieldEmpty() ? Color(.systemGray5) : .DinotisDefault.primary)
						)
					}
                    .disabled(viewModel.isFieldEmpty() || viewModel.isLoading)
					.padding()
					.background(
						Rectangle()
							.foregroundColor(.white)
							.shadow(color: .black.opacity(0.1), radius: 25, x: 0, y: -4)
							.edgesIgnoringSafeArea(.bottom)
					)

				}
                
                DinotisLoadingView(.fullscreen, hide: !viewModel.isLoadingDetail)
			}
			.onAppear {
				if viewModel.meetingIdArray.isEmpty {
					viewModel.onAppear()
				}
			}
            .navigationBarHidden(true)
            .navigationBarTitle("")
		}
    }
}

struct BundlingFormView_Previews: PreviewProvider {
    static var previews: some View {
		BundlingFormView(viewModel: BundlingFormViewModel(meetingIdArray: ["",""], isEdit: false, backToHome: {}, backToBundlingList: {}))
    }
}

extension BundlingFormView {
	struct FormView: View {

		@ObservedObject var viewModel: BundlingFormViewModel
		let isEdit: Bool

		var body: some View {
			VStack(spacing: 15) {

				VStack(spacing: 10) {
					HStack {
						Image.Dinotis.videoCallFormIcon
							.resizable()
							.scaledToFit()
							.frame(height: 11)

						Text(LocaleText.titleDescriptionFormTitle)
							.font(.robotoMedium(size: 12))
							.foregroundColor(.black)

						Spacer()
					}

					VStack {
                        VStack {
                            TextField(LocaleText.exampleFormTitlePlaceholder, text: $viewModel.title)
                                .font(.robotoRegular(size: 12))
                                .autocapitalization(.words)
                                .disableAutocorrection(true)
                                .foregroundColor(.black)
                                .accentColor(.black)
                                .padding(.horizontal)
                                .padding(.vertical, 15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                                )
                            
                            if viewModel.titleError != nil {
                                HStack {
                                    Image.Dinotis.exclamationCircleIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 10)
                                        .foregroundColor(.red)
                                    Text(viewModel.titleError.orEmpty())
                                        .font(.robotoRegular(size: 10))
                                        .foregroundColor(.red)
										.multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                            }
                        }
                        
                        VStack {
                            MultilineTextField(text: $viewModel.desc)
                                .foregroundColor(.black)
                                .accentColor(.black)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                                )
                            
                            if viewModel.descError != nil {
                                HStack {
                                    Image.Dinotis.exclamationCircleIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 10)
                                        .foregroundColor(.red)
                                    Text(viewModel.descError.orEmpty())
                                        .font(.robotoRegular(size: 10))
                                        .foregroundColor(.red)
										.multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                            }
                        }
					}
				}

				VStack(spacing: 10) {
					HStack {
						Image.Dinotis.priceTagIcon
							.resizable()
							.scaledToFit()
							.frame(height: 20)

						Text(LocaleText.setCostTitle)
							.font(.robotoMedium(size: 12))
							.foregroundColor(.black)

						Spacer()
					}

					VStack {
						HStack {
							Text("Rp")
                                .font(.robotoMedium(size: 12))
								.foregroundColor(.black)

							TextField(LocaleText.enterCostLabelPlaceholder, text: $viewModel.price)
							.font(.robotoRegular(size: 12))
							.autocapitalization(.words)
							.disableAutocorrection(true)
							.keyboardType(.numberPad)
							.foregroundColor(.black)
							.accentColor(.black)
							.disabled(isEdit)

						}
						.padding(.horizontal)
						.padding(.vertical, 15)
						.background(
							RoundedRectangle(cornerRadius: 6)
								.foregroundColor(isEdit ? .gray.opacity(0.1) : .white)
						)
						.overlay(
							RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
						)
					}
				}

			}
			.padding()
			.background(
				RoundedRectangle(cornerRadius: 12)
					.foregroundColor(.white)
					.shadow(color: .black.opacity(0.06), radius: 10)
			)
		}
	}

	struct HeaderView: View {

		@ObservedObject var viewModel: BundlingFormViewModel
		@Environment(\.presentationMode) var presentationMode

		var body: some View {
			HStack {
				Button(action: {
					self.presentationMode.wrappedValue.dismiss()

				}, label: {
					Image.Dinotis.arrowBackIcon
						.padding()
				})
				.background(Color.white)
				.clipShape(Circle())
				.shadow(color: .black.opacity(0.1), radius: 20)

				Spacer()

				Text(viewModel.isEdit ? LocaleText.editBundling : LocaleText.bundlingCreateText)
					.font(.robotoBold(size: 14))
					.foregroundColor(.black)
					.padding(.trailing)

				Spacer()
			}
			.padding()
			.padding(.trailing)
		}
	}
}
