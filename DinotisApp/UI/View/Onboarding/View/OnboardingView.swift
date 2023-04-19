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

				TabView(selection: $viewModel.selectedContent) {
					VStack(spacing: 15) {
						Image.onboardingSlide1Image
							.resizable()
							.scaledToFit()
							.frame(height: 321)

						VStack(spacing: 10) {
							Text(LocalizableText.firstOnboardingTitle)
								.font(.robotoBold(size: 20))
								.foregroundColor(.DinotisDefault.black1)
								.multilineTextAlignment(.center)

							Text(LocalizableText.descriptionFirstOnboardingContent)
								.font(.robotoRegular(size: 14))
								.foregroundColor(.DinotisDefault.black2)
								.multilineTextAlignment(.center)
						}
					}
					.padding()
					.background(
						Color.DinotisDefault.baseBackground
					)
					.tag(0)

					VStack(spacing: 15) {
						Image.onboardingSlide2Image
							.resizable()
							.scaledToFit()
							.frame(height: 297)

						VStack(spacing: 10) {
							Text(LocalizableText.secondOnboardingTitle)
								.font(.robotoBold(size: 20))
								.foregroundColor(.DinotisDefault.black1)
								.multilineTextAlignment(.center)

							Text(LocalizableText.descriptionSecondOnboardingContent)
								.font(.robotoRegular(size: 14))
								.foregroundColor(.DinotisDefault.black2)
								.multilineTextAlignment(.center)
						}
					}
					.padding()
					.background(
						Color.DinotisDefault.baseBackground
					)
					.tag(1)
				}
				.tabViewStyle(.page(indexDisplayMode: .always))

				HStack {
					if viewModel.selectedContent > 0 {
						DinotisNudeButton(text: LocalizableText.previousLabel, textColor: .DinotisDefault.black3, fontSize: 14) {
							withAnimation(.spring()) {
								viewModel.selectedContent = 0
							}

						}
					}

					Spacer()


					DinotisNudeButton(text: LocalizableText.continueLabel, textColor: .DinotisDefault.primary, fontSize: 14) {
						withAnimation(.spring()) {
							if viewModel.selectedContent == 1 {
								viewModel.routeToUserType()
							} else {
								viewModel.selectedContent = 1
							}
						}

					}
				}
				.padding()
			}
		}
		.onAppear {
			UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(.DinotisDefault.primary)
			UIPageControl.appearance().pageIndicatorTintColor = UIColor(.DinotisDefault.lightPrimaryActive)

			let configuration = UIImage.SymbolConfiguration(pointSize: 25, weight: .black)
			UIPageControl.appearance().preferredIndicatorImage = UIImage(systemName: "minus", withConfiguration: configuration)
			AppDelegate.orientationLock = .portrait
			viewModel.checkingSession()
		}
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
		.onDisappear {
			UIPageControl.appearance().preferredIndicatorImage = nil
		}
	}
}

struct OnboardingView_Previews: PreviewProvider {
	static var previews: some View {
		OnboardingView()
	}
}
