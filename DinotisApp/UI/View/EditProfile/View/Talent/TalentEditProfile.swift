//
//  TalentEditProfile.swift
//  DinotisApp
//
//  Created by Gus Adi on 12/08/21.
//

import DinotisData
import DinotisDesignSystem
import Moya
import SwiftUI
import SwiftUINavigation

struct TalentEditProfile: View {

	@Binding var profesionSelect: [ProfessionData]

	@Environment(\.dismiss) var dismiss

	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder

	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}

	@ObservedObject var viewModel: EditProfileViewModel
	@ObservedObject var stateObservable = StateObservable.shared

	var body: some View {
		GeometryReader { proxy in
			ZStack {
				NavigationLink(
					unwrapping: $viewModel.route,
					case: /HomeRouting.changePhone,
					destination: { viewModel in
						ChangePhoneView(viewModel: viewModel.wrappedValue)
					},
					onNavigate: {_ in },
					label: {
						EmptyView()
					}
				)

				ZStack(alignment: .top) {
                    Color.DinotisDefault.baseBackground
                        .edgesIgnoringSafeArea(.all)

                    VStack(spacing: 0) {
                        
                        HeaderView(
                            type: .textHeader,
                            title: LocalizableText.editProfileLabel,
                            headerColor: .clear,
                            textColor: .DinotisDefault.black1,
                            leadingButton:  {
                                Button {
                                    dismiss()
                                } label: {
                                    Image.generalBackIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .padding(12)
                                        .background(
                                            Circle()
                                                .fill(.white)
                                                .shadow(color: .black.opacity(0.03), radius: 5)
                                        )
                                }
                            }
                        )
                        
                        ScrollView(.vertical, showsIndicators: false, content: {
                            VStack {
                                
                                VStack(spacing: 24) {
                                    
                                    ProfilePicture(viewModel: viewModel)
                                    
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text(LocalizableText.mainProfileLabel)
                                            .font(.robotoBold(size: 18))
                                            .foregroundColor(.DinotisDefault.black1)
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(LocaleText.nameText)
                                                .font(.robotoMedium(size: 12))
                                                .foregroundColor(.DinotisDefault.black1)
                                            
                                            DinotisTextField(
                                                LocaleText.nameHint,
                                                label: nil,
                                                text: $viewModel.names,
                                                errorText: .constant(nil)
                                            )
                                            .autocapitalization(.words)
                                            .disableAutocorrection(true)
                                            
                                            if viewModel.names.isEmpty {
                                                HStack {
                                                    Image.Dinotis.exclamationCircleIcon
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: 10)
                                                        .foregroundColor(.red)
                                                    Text(LocalizableText.editProfileNameEmptyError)
                                                        .font(.robotoRegular(size: 10))
                                                        .foregroundColor(.red)
                                                        .multilineTextAlignment(.leading)
                                                    
                                                    Spacer()
                                                }
                                            }
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(LocalizableText.professionyWithCounter(with: profesionSelect.count))
                                                .font(.robotoMedium(size: 12))
                                                .foregroundColor(.DinotisDefault.black1)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            HStack {
                                                HStack {
                                                    ChipsContentView(viewModel: viewModel, profesionSelect: $profesionSelect, geo: proxy)
                                                        .frame(width: proxy.size.width/2, alignment: .leading)
                                                        .fixedSize(horizontal: true, vertical: false)
                                                    
                                                    if profesionSelect.isEmpty {
                                                        Rectangle()
                                                            .fill(Color.clear)
                                                            .frame(height: 45)
                                                    }
   
                                                    Spacer()
                                                    
                                                    Rectangle()
                                                        .fill(Color.DinotisDefault.lightPrimary)
                                                        .frame(width: 1)
                                                        .padding(.vertical, 8)
                                                    
                                                    Image(systemName: "chevron.down.circle.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: 24)
                                                        .foregroundColor(.DinotisDefault.primary)
                                                        .padding(.trailing)
                                                }
                                                .background(Color.white)
                                            }
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6).stroke(Color(red: 0.792, green: 0.8, blue: 0.812), lineWidth: 1)
                                            )
                                            .onTapGesture(perform: {
                                                withAnimation(.spring()) {
                                                    viewModel.showDropDown.toggle()
                                                }
                                                
                                            })
                                            
                                            if profesionSelect.isEmpty {
                                                HStack {
                                                    Image.Dinotis.exclamationCircleIcon
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: 10)
                                                        .foregroundColor(.red)
                                                    Text(LocalizableText.editProfileProfessionEmptyError)
                                                        .font(.robotoRegular(size: 10))
                                                        .foregroundColor(.red)
                                                        .multilineTextAlignment(.leading)
                                                    
                                                    Spacer()
                                                }
                                            }
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(LocalizableText.profileDinotisLinkWithCounter(with: viewModel.username.count))
                                                .font(.robotoMedium(size: 12))
                                                .foregroundColor(.DinotisDefault.black1)
                                            
                                            HStack(spacing: 8) {
                                                Image.profileLinkIcon
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 26, height: 26)
                                                
                                                Text(viewModel.constUrl)
                                                    .font(.robotoRegular(size: 12))
                                                    .foregroundColor(.DinotisDefault.black1)
                                                
                                                DinotisTextField(
                                                    LocaleText.usernameHint,
                                                    label: nil,
                                                    text: $viewModel.username,
                                                    errorText: .constant(nil), trailingButton:  {
                                                        if viewModel.isUsernameAvail && !viewModel.isLoadingUserName {
                                                            Image.Dinotis.verifiedCorrectIcon
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(height: 18)
                                                        } else if !viewModel.isUsernameAvail && !viewModel.username.isEmpty && !viewModel.isLoadingUserName {
                                                            if viewModel.username == viewModel.userData?.username {
                                                                EmptyView()
                                                            } else {
                                                                Image(systemName: "xmark")
                                                                    .resizable()
                                                                    .font(Font.system(size: 8, weight: .semibold))
                                                                    .scaledToFit()
                                                                    .frame(height: 8)
                                                                    .padding(3)
                                                                    .foregroundColor(Color.white)
                                                                    .background(Color.red)
                                                                    .clipShape(Circle())
                                                            }
                                                        } else if viewModel.usernameInvalid && !viewModel.isLoadingUserName {
                                                            Image(systemName: "xmark")
                                                                .resizable()
                                                                .font(Font.system(size: 8, weight: .semibold))
                                                                .scaledToFit()
                                                                .frame(height: 8)
                                                                .padding(3)
                                                                .foregroundColor(Color.white)
                                                                .background(Color.red)
                                                                .clipShape(Circle())
                                                        } else if viewModel.isLoadingUserName {
                                                            ProgressView()
                                                                .progressViewStyle(.circular)
                                                        }
                                                    })
                                                .disableAutocorrection(true)
                                                .autocapitalization(.none)
                                                .valueChanged(value: viewModel.username) { _ in
                                                    viewModel.startCheckAvail()
                                                }
                                            }
                                            
                                            if viewModel.username.isEmpty {
                                                HStack {
                                                    Image.Dinotis.exclamationCircleIcon
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: 10)
                                                        .foregroundColor(.red)
                                                    Text(LocalizableText.editProfileUsernameEmptyError)
                                                        .font(.robotoRegular(size: 10))
                                                        .foregroundColor(.red)
                                                        .multilineTextAlignment(.leading)
                                                    
                                                    Spacer()
                                                }
                                            }
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text(LocalizableText.contactInformationLabel)
                                            .font(.robotoBold(size: 18))
                                            .foregroundColor(.DinotisDefault.black1)
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(LocalizableText.phoneNumberLabel)
                                                .font(.robotoMedium(size: 12))
                                                .foregroundColor(.DinotisDefault.black1)
                                            
                                            DinotisTextField(
                                                viewModel.phone,
                                                disabled: true, 
                                                label: nil,
                                                text: $viewModel.phone,
                                                errorText: .constant(nil),
                                                trailingButton: {
                                                    DinotisPrimaryButton(
                                                        text: LocalizableText.changeLabel,
                                                        type: .mini,
                                                        textColor: .white,
                                                        bgColor: .DinotisDefault.primary
                                                    ) {
                                                        viewModel.routeToChangePhone()
                                                    }
                                                }
                                            )
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 16) {
                                        HStack {
                                            Text(LocalizableText.overviewLabel)
                                                .font(.robotoBold(size: 18))
                                                .foregroundColor(.DinotisDefault.black1)
                                            
                                            Spacer()
                                            
                                            Button {
                                                
                                            } label: {
                                                HStack(spacing: 8) {
                                                    Text(LocalizableText.previewProfileLabel)
                                                        .font(.robotoBold(size: 12))
                                                    
                                                    Image(systemName: "arrow.right.circle.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 16, height: 16)
                                                }
                                                .foregroundColor(.white)
                                                .padding(8)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(Color.DinotisDefault.primary)
                                                )
                                            }
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(LocalizableText.aboutMeWithCounter(with: viewModel.bio.count))
                                                .font(.robotoMedium(size: 12))
                                                .foregroundColor(.DinotisDefault.black1)
                                            
                                            DinotisTextEditor(
                                                LocalizableText.hintFormBio,
                                                label: nil,
                                                text: $viewModel.bio,
                                                errorText: .constant(nil)
                                            )
                                            
                                            if viewModel.bio.isEmpty {
                                                HStack {
                                                    Image.Dinotis.exclamationCircleIcon
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: 10)
                                                        .foregroundColor(.red)
                                                    Text(LocalizableText.editProfileBioEmptyError)
                                                        .font(.robotoRegular(size: 10))
                                                        .foregroundColor(.red)
                                                        .multilineTextAlignment(.leading)
                                                    
                                                    Spacer()
                                                }
                                            }
                                        }
                                        
                                        HighlightSection(geo: proxy, viewModel: viewModel)
                                    }
                                }
                                .padding(20)
                                .padding(.top)
                                .background(Color(.white))
                                .cornerRadius(16)
                                .shadow(color: Color.dinotisShadow.opacity(0.03), radius: 10)
                                .padding(.horizontal)
                                .padding(.bottom, 10)
                                .padding(.top)
                            }
                        })
                        
                        Button(action: {
                            viewModel.onUpload {
                                dismiss()
                            }
                        }, label: {
                            HStack {
                                Spacer()
                                Text(LocaleText.saveText)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(viewModel.isAvailableToSaveUser() && !profesionSelect.isEmpty ? .white : .black.opacity(0.6))
                                    .padding(10)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 5)
                                
                                Spacer()
                            }
                            .background(viewModel.isAvailableToSaveUser() && !profesionSelect.isEmpty ? Color.DinotisDefault.primary : Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        })
                        .padding()
                        .background(Color.white.edgesIgnoringSafeArea(.all))
                        .disabled(!viewModel.isAvailableToSaveUser() || profesionSelect.isEmpty)
                        
                    }
					.onAppear {
						for item in profesionSelect {
                            viewModel.professionSelectID.append((item.profession?.id).orZero())
						}
					}

				}

				ZStack(alignment: .bottom) {
					Color.black.opacity(viewModel.showDropDown ? 0.35 : 0)
						.onTapGesture {
							withAnimation(.spring()) {
								viewModel.showDropDown.toggle()
							}
						}

					VStack {
						ScrollView(.vertical, showsIndicators: true) {
							VStack {

								ForEach(viewModel.professionData?.data ?? [], id: \.id) { item in
									Button(action: {
										for items in profesionSelect where item.id == (items.profession?.id).orZero() {
											if let itemToRemoveIndex = profesionSelect.firstIndex(of: items) {
												profesionSelect.remove(at: itemToRemoveIndex)
											}
										}

										for items in viewModel.professionSelectID where item.id == items {
											if let itemToRemoveIndex = viewModel.professionSelectID.firstIndex(of: items) {
												viewModel.professionSelectID.remove(at: itemToRemoveIndex)
											}
										}

										profesionSelect.append(
											ProfessionData(
                                                userId: (viewModel.userData?.id).orEmpty(),
                                                professionId: item.id,
												createdAt: Date(),
												updatedAt: Date(),
                                                profession: ProfessionElement(id: item.id, professionCategoryId: item.professionCategoryId, name: item.name, createdAt: item.createdAt, updatedAt: item.updatedAt)
											)
										)
                                        viewModel.professionSelectID.append(item.id.orZero())
										withAnimation(.spring()) {
											viewModel.showDropDown.toggle()
										}
									}, label: {
										VStack {
											HStack {
												Text(item.name.orEmpty())
													.font(.robotoRegular(size: 12))
													.foregroundColor(.black)
													.padding(.horizontal)
													.padding(.vertical)

												Spacer()
											}

											if !(item.name == viewModel.professionData?.data?.last?.name ?? "") {
												Divider()
													.padding(.horizontal)
											} else {
												Capsule()
													.foregroundColor(.clear)
													.frame(height: 1)
											}
										}
									})
									.padding(.top, 5)

								}

							}

						}
					}
					.padding(.vertical)
					.background(
						RoundedCorner(radius: 10, corners: [.topLeft, .topRight])
							.foregroundColor(.white)
					)
					.frame(height: proxy.size.height/2.5)
					.offset(y: viewModel.showDropDown ? .zero : proxy.size.height+150)

				}
				.edgesIgnoringSafeArea(.vertical)

                DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
			}
            .onAppear {
                viewModel.onAppearLoad()
            }
			.onDisappear(perform: {
				viewModel.professionSelectID = []
				viewModel.image = UIImage()
				viewModel.userHighlightsImage = [UIImage(), UIImage(), UIImage()]
            })
            .navigationBarTitle(Text(""))
            .navigationBarHidden(true)
        }
        .dinotisAlert(
            isPresent: $viewModel.isShowAlert,
            title: viewModel.alert.title,
            isError: viewModel.alert.isError,
            message: viewModel.alert.message,
            primaryButton: viewModel.alert.primaryButton
        )
    }
}

struct TalentEditProfile_Previews: PreviewProvider {
	static var previews: some View {

		TalentEditProfile(
			profesionSelect: .constant([]),
			viewModel: EditProfileViewModel(backToHome: {}))
	}
}
