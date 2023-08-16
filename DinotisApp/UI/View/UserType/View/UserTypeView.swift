//
//  ContentView.swift
//  DinotisApp
//
//  Created by Gus Adi on 02/08/21.
//

import SwiftUI
import DinotisDesignSystem
import SwiftUINavigation
import DinotisData

struct UserTypeView: View {
	
    @ObservedObject var viewModel = UserTypeViewModel()
    @StateObject var stateObservable = StateObservable.shared
    
    var body: some View {
        MainUserType()
            .environmentObject(viewModel)
    }
    
    struct MainUserType: View {
        @EnvironmentObject var viewModel: UserTypeViewModel
        @ObservedObject var stateObservable = StateObservable.shared
        
        var body: some View {
            GeometryReader { geo in
                ZStack(alignment: .top) {
                    Color.DinotisDefault.baseBackground
                        .edgesIgnoringSafeArea(.all)

                    VStack(alignment: .leading) {

                        Spacer()

                        Image.loginRunningTextImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width)
                            .edgesIgnoringSafeArea(.horizontal)

                        Spacer()

                        Text(LocalizableText.titleRoleType)
                            .font(.robotoBold(size: 34))
                            .minimumScaleFactor(0.7)
                            .foregroundColor(.DinotisDefault.black1)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)

                        Spacer()

                        VStack(alignment: .leading, spacing: 15) {
                            Text(LocalizableText.descriptionRoleType)
                                .font(.robotoMedium(size: 16))
                                .minimumScaleFactor(0.8)
                                .foregroundColor(.DinotisDefault.black1)
                                .multilineTextAlignment(.leading)

                            UserSelectionView(viewModel: viewModel, geo: geo)
                        }
                        .padding(.horizontal)

                        Spacer()
                    }

                    NavigationLink(
                        unwrapping: $viewModel.route,
                        case: /PrimaryRouting.userLogin
                    ) { viewModel in
                        LoginViewUser(loginVM: viewModel.wrappedValue)
                    } onNavigate: { _ in } label: {
                        EmptyView()
                    }
                }
            }
            .navigationBarTitle(Text(""))
            .navigationBarHidden(true)
            .onAppear(perform: {
                if stateObservable.accessToken.isEmpty {
                    stateObservable.isAnnounceShow = false
                }
            })
        }
    }
}

private extension UserTypeView {
	
	struct UserSelectionView: View {
		
		@ObservedObject var viewModel: UserTypeViewModel
		let geo: GeometryProxy
		
		var body: some View {
			VStack {
				Button {
					viewModel.goToUserLogin()
				} label: {
					HStack(alignment: .center) {

						Image.loginAudienceImage
							.resizable()
							.scaledToFit()
							.frame(height: 70)
							.minimumScaleFactor(0.8)

						VStack(alignment: .leading, spacing: 5) {
							Text(LocalizableText.audienceTitle)
								.font(.robotoBold(size: 20))
								.foregroundColor(.DinotisDefault.white)
								.multilineTextAlignment(.leading)

							Text(LocalizableText.descriptionAudienceLogin)
								.font(.robotoRegular(size: 12))
								.foregroundColor(.DinotisDefault.white)
								.multilineTextAlignment(.leading)
						}

						Spacer()

						Image(systemName: "chevron.right")
							.foregroundColor(.DinotisDefault.white)
							.font(.system(size: 16, weight: .bold, design: .rounded))
					}
					.padding(.horizontal)
					.padding(.top, 10)
					.padding(.bottom)
					.background(
						RoundedRectangle(cornerRadius: 10)
							.foregroundColor(.DinotisDefault.primary)
					)
				}

				Button {
					viewModel.goToTalentLogin()
				} label: {
					HStack(alignment: .center, spacing: 0) {

						Image.loginCreatorImage
							.resizable()
							.scaledToFit()
							.frame(height: 70)
							.minimumScaleFactor(0.8)

						VStack(alignment: .leading, spacing: 5) {
							Text(LocalizableText.creatorTitle)
								.font(.robotoBold(size: 20))
								.foregroundColor(.DinotisDefault.white)
								.multilineTextAlignment(.leading)

							Text(LocalizableText.descriptionCreatorLogin)
								.font(.robotoRegular(size: 12))
								.foregroundColor(.DinotisDefault.white)
								.multilineTextAlignment(.leading)
						}

						Spacer()

						Image(systemName: "chevron.right")
							.foregroundColor(.DinotisDefault.white)
							.font(.system(size: 16, weight: .bold, design: .rounded))
					}
					.padding(.horizontal)
					.padding(.top, 12)
					.padding(.bottom)
					.background(
						RoundedRectangle(cornerRadius: 10)
							.foregroundColor(.DinotisDefault.secondary)
					)
				}
			}
		}
	}
}

struct UserTypeView_Previews: PreviewProvider {
	static var previews: some View {
		UserTypeView()
	}
}
