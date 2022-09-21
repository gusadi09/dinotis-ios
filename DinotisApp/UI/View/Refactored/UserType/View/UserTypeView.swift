//
//  ContentView.swift
//  DinotisApp
//
//  Created by Gus Adi on 02/08/21.
//

import SwiftUI
import SwiftUINavigation

struct UserTypeView: View {
	
	@ObservedObject var viewModel = UserTypeViewModel()
	@ObservedObject var stateObservable = StateObservable.shared
	
	var body: some View {
		GeometryReader { geo in
			ZStack(alignment: .top) {
				Image.Dinotis.userTypeBackground
					.resizable()
					.edgesIgnoringSafeArea(.all)

				VStack {
					Spacer()

					HeaderView(geo: geo)

					Spacer()

					UserSelectionView(viewModel: viewModel, geo: geo)
				}
				.padding(10)

				NavigationLink(
					unwrapping: $viewModel.route,
					case: /PrimaryRouting.userLogin
				) { viewModel in
					LoginViewUser(loginVM: viewModel.wrappedValue)
				} onNavigate: { _ in } label: {
					EmptyView()
				}

				NavigationLink(
					unwrapping: $viewModel.route,
					case: /PrimaryRouting.talentLogin
				) { viewModel in
					LoginViewTalent(loginVM: viewModel.wrappedValue)
				} onNavigate: { _ in } label: {
					EmptyView()
				}

				NavigationLink(
					unwrapping: $viewModel.route,
					case: /PrimaryRouting.homeUser
				) { viewModel in
					UserHomeView(homeVM: viewModel.wrappedValue)
				} onNavigate: { _ in } label: {
					EmptyView()
				}

				NavigationLink(
					unwrapping: $viewModel.route,
					case: /PrimaryRouting.homeTalent
				) { viewModel in
					TalentHomeView(homeVM: viewModel.wrappedValue)
				} onNavigate: { _ in } label: {
					EmptyView()
				}
			}
		}
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
		.onAppear(perform: {
			viewModel.checkingSession()

			if stateObservable.accessToken.isEmpty {
				stateObservable.isAnnounceShow = false
			}
		})
		
	}
}

private extension UserTypeView {
	
	struct HeaderView: View {
		let geo: GeometryProxy

		var body: some View {
			Image.Dinotis.dinotisLogoFulfilled
				.resizable()
				.scaledToFit()
				.frame(
					height: geo.size.height/14
				)
				.padding(.top, 3)
		}
	}
	
	struct UserSelectionView: View {
		
		@ObservedObject var viewModel: UserTypeViewModel
		let geo: GeometryProxy
		
		var body: some View {
			Image.Dinotis.userTypeImage
				.resizable()
				.scaledToFit()
				.frame(
					height: geo.size.height/3.5
				)
				.padding(.horizontal, 50)
				.padding(15)
			
			Spacer()
			
			VStack {
				Text(LocaleText.loginAsText)
					.font(.montserratBold(size: 18))
					.foregroundColor(.black)
				
				Button {
					viewModel.goToUserLogin()
				} label: {
					HStack(spacing: 10) {
						Image.Dinotis.userCircleFillIcon
							.resizable()
							.scaledToFit()
							.frame(height: 34)
						
						VStack(alignment: .leading) {
							Text(LocaleText.basicUserText)
								.font(.montserratBold(size: 14))
								.padding(.bottom, 0.2)
								.fixedSize(horizontal: false, vertical: true)
								.foregroundColor(.black)
								.multilineTextAlignment(.leading)
							
							Text(LocaleText.basicUserPlaceholder)
								.font(.montserratRegular(size: 12))
								.fixedSize(horizontal: false, vertical: true)
								.foregroundColor(.black)
								.multilineTextAlignment(.leading)
						}
						.foregroundColor(Color.dinotisGray)
						.padding(.vertical, 10)

						Spacer()
						
						Image.Dinotis.chevronLeftCircleIcon
							.padding()
					}
					.padding(.leading)
					.contentShape(Rectangle())
					.overlay(
						RoundedRectangle(cornerRadius: 10)
							.stroke(Color.dinotisStrokeSecondary, lineWidth: 1)
					)
				}
				.padding(.bottom, 5)
				
				Button {
					viewModel.goToTalentLogin()
				} label: {
					HStack(spacing: 10) {
						Image.Dinotis.userCircleFillIcon
							.resizable()
							.scaledToFit()
							.frame(height: 34)
						
						VStack(alignment: .leading) {
							Text(LocaleText.talentUserText)
								.font(.montserratBold(size: 14))
								.padding(.vertical, 0.2)
								.fixedSize(horizontal: false, vertical: true)
								.multilineTextAlignment(.leading)
								.foregroundColor(.black)
							
							Text(LocaleText.talentUserPlaceholder)
								.font(.montserratRegular(size: 12))
								.fixedSize(horizontal: false, vertical: true)
								.multilineTextAlignment(.leading)
								.foregroundColor(.black)
						}
						.foregroundColor(Color.dinotisGray)
						.padding(.vertical, 10)

						Spacer()
						
						Image.Dinotis.chevronLeftCircleIcon
							.padding()
							.padding(.leading, 2)
					}
					.padding(.leading)
					.overlay(
						RoundedRectangle(cornerRadius: 10)
							.stroke(Color.dinotisStrokeSecondary, lineWidth: 1)
					)
				}
				
			}
			.padding(20)
			.background(Color(.white))
			.cornerRadius(16)
			.shadow(color: Color.dinotisShadow.opacity(0.2), radius: 40, x: 0.0, y: 0.0)
			.padding(.bottom)
			.contentShape(Rectangle())
			.onAppear(perform: {
				AppDelegate.orientationLock = .portrait
			})
		}
	}
}

struct UserTypeView_Previews: PreviewProvider {
	static var previews: some View {
		UserTypeView()
	}
}
