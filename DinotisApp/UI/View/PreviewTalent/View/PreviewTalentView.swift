//
//  PreviewTalentView.swift
//  DinotisApp
//
//  Created by Gus Adi on 23/04/22.
//

import DinotisDesignSystem
import Introspect
import SwiftUI

struct PreviewTalentView: View {

	@ObservedObject var viewModel: PreviewTalentViewModel

	var body: some View {
		GeometryReader { geo in
			ZStack(alignment: .center) {
				Color.white.edgesIgnoringSafeArea(.all)
					.alert(isPresented: $viewModel.isRefreshFailed) {
						Alert(
							title: Text(LocaleText.attention),
							message: Text(LocaleText.sessionExpireText),
							dismissButton: .default(Text(LocaleText.returnText), action: {
								viewModel.backToRoot()
							})
						)
					}

				VStack(spacing: 0) {

					HeaderView(viewModel: viewModel)
						.padding(.top, 5)
						.padding(.bottom)
						.background(Color.clear)

					DinotisList { view in
						view.separatorStyle = .none
						view.indicatorStyle = .white
						view.tableHeaderView = UIView()
						viewModel.use(for: view) { refresh in
							DispatchQueue.main.async {
								refresh.endRefreshing()
							}
						}
					} content: {
						if !viewModel.profileBannerContent.isEmpty {
							ProfileBannerView(content: $viewModel.profileBannerContent, geo: geo)
								.background(Color.secondaryBackground)
								.listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
								.listRowBackground(Color.clear)
						} else {
							SingleProfileImageBanner(
								profilePhoto: $viewModel.photoProfile,
								name: $viewModel.nameOfUser,
								width: geo.size.width-20,
								height: geo.size.height/2.2
							)
							.listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
							.listRowBackground(Color.clear)
						}

						Section {
							EmptyView()
						} header: {
							CardProfile(viewModel: viewModel)
								.padding(.top, -10)
						}
						.listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
						.listRowBackground(Color.clear)
					}
					.padding(.horizontal, -20)
				}
                
                DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
			}
			.onAppear {
                Task {
                    await viewModel.getUsers()
                }
			}
			.navigationBarTitle(Text(""))
			.navigationBarHidden(true)
		}
	}
}

struct PreviewTalentView_Previews: PreviewProvider {
	static var previews: some View {
		PreviewTalentView(viewModel: PreviewTalentViewModel(backToRoot: {}))
	}
}
