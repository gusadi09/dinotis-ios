//
//  OnboardingView.swift
//  DinotisApp
//
//  Created by Gus Adi on 07/12/22.
//

import SwiftUI
import DinotisDesignSystem
import SwiftUINavigation

struct OnboardingView: View {

	@ObservedObject var viewModel = OnboardingViewModel()
    
    @AppStorage("isShowTooltip") var isShowTooltip = false

	var body: some View {
		ZStack {

			NavigationLink(
				unwrapping: $viewModel.route,
				case: /PrimaryRouting.userType
			) { _ in
				UserTypeView()
			} onNavigate: { _ in } label: {
				EmptyView()
			}
            
            NavigationLink(
                unwrapping: $viewModel.route,
                case: /PrimaryRouting.biodataUser
            ) { viewModel in
                UserBiodataView(viewModel: viewModel.wrappedValue)
            } onNavigate: { _ in } label: {
                EmptyView()
            }

            NavigationLink(
                unwrapping: $viewModel.route,
                case: /PrimaryRouting.tabContainer
            ) { viewModel in
                TabViewContainer()
                    .environmentObject(viewModel.wrappedValue)
            } onNavigate: { _ in } label: {
                EmptyView()
            }

            NavigationLink(
                unwrapping: $viewModel.route,
                case: /PrimaryRouting.homeTalent
            ) { viewModel in
                TalentHomeView()
                    .environmentObject(viewModel.wrappedValue)
            } onNavigate: { _ in } label: {
                EmptyView()
            }

			Color.DinotisDefault.baseBackground
				.edgesIgnoringSafeArea(.all)

			VStack(spacing: 0) {
				HStack {
					Spacer()

					DinotisNudeButton(text: LocalizableText.skipLabel, textColor: .DinotisDefault.black3, fontSize: 14) {
						viewModel.routeToUserType()
					}
				}
				.padding()
                
                Spacer()

				TabView(selection: $viewModel.selectedContent) {
					VStack(spacing: 15) {
						Image.onboardingSlide1Image
							.resizable()
							.scaledToFit()

						VStack(spacing: 10) {
							Text(LocalizableText.firstOnboardingTitle)
								.font(.robotoBold(size: 24))
								.foregroundColor(.DinotisDefault.black1)
								.multilineTextAlignment(.center)

							Text(LocalizableText.descriptionFirstOnboardingContent)
								.font(.robotoRegular(size: 14))
								.foregroundColor(.DinotisDefault.black3)
								.multilineTextAlignment(.center)
						}
					}
                    .frame(maxWidth: 321)
					.padding()
					.background(
						Color.DinotisDefault.baseBackground
					)
					.tag(0)

					VStack(spacing: 15) {
						Image.onboardingSlide2Image
							.resizable()
							.scaledToFit()

						VStack(spacing: 10) {
							Text(LocalizableText.secondOnboardingTitle)
								.font(.robotoBold(size: 24))
								.foregroundColor(.DinotisDefault.black1)
								.multilineTextAlignment(.center)

							Text(LocalizableText.descriptionSecondOnboardingContent)
								.font(.robotoRegular(size: 14))
								.foregroundColor(.DinotisDefault.black3)
								.multilineTextAlignment(.center)
						}
					}
					.padding()
					.background(
						Color.DinotisDefault.baseBackground
					)
                    .frame(maxWidth: 321)
					.tag(1)
                    
                    VStack(spacing: 15) {
                        Image.onboardingSlide3Image
                            .resizable()
                            .scaledToFit()

                        VStack(spacing: 10) {
                            Text(LocalizableText.thirdOnboardingTitle)
                                .font(.robotoBold(size: 24))
                                .foregroundColor(.DinotisDefault.black1)
                                .multilineTextAlignment(.center)

                            Text(LocalizableText.descriptionThirdOnboardingContent)
                                .font(.robotoRegular(size: 14))
                                .foregroundColor(.DinotisDefault.black3)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: 321)
                    .padding()
                    .background(
                        Color.DinotisDefault.baseBackground
                    )
                    .tag(2)
				}
				.tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: 415)
                
                HStack(spacing: 8) {
                    ForEach(0...2, id:\.self) { index in
                        Capsule()
                            .fill(viewModel.selectedContent == index ? Color.DinotisDefault.primary : Color.DinotisDefault.grayDinotis)
                            .frame(width: viewModel.selectedContent == index ? 32 : 8, height: 8)
                            .animation(.easeInOut, value: viewModel.selectedContent)
                    }
                }
                .padding()
                
                Spacer()

				HStack {
					if viewModel.selectedContent > 0 {
						DinotisNudeButton(text: LocalizableText.previousLabel, textColor: .DinotisDefault.black3, fontSize: 14) {
							withAnimation(.spring()) {
                                if viewModel.selectedContent > 0 {
                                    viewModel.selectedContent -= 1
                                }
							}

						}
					}

					Spacer()


					DinotisNudeButton(text: LocalizableText.continueLabel, textColor: .DinotisDefault.primary, fontSize: 14) {
						withAnimation(.spring()) {
							if viewModel.selectedContent == 2 {
								viewModel.routeToUserType()
							} else {
								viewModel.selectedContent += 1
							}
						}

					}
				}
				.padding()
			}
		}
		.onAppear {
			AppDelegate.orientationLock = .portrait
			viewModel.checkingSession()
		}
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
		.onDisappear {
            viewModel.selectedContent = 0
		}
	}
}

struct OnboardingView_Previews: PreviewProvider {
	static var previews: some View {
		OnboardingView()
	}
}
