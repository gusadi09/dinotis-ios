//
//  FollowedCreatorView.swift
//  DinotisApp
//
//  Created by Gus Adi on 19/12/22.
//

import SwiftUI
import DinotisDesignSystem
import SwiftUINavigation

struct FollowedCreatorView: View {

	@ObservedObject var viewModel: FollowedCreatorViewModel

	@Environment(\.dismiss) var dismiss
    
    @Binding var tabValue: TabRoute

	var body: some View {
    GeometryReader { geo in
      ZStack {
        NavigationLink(
          unwrapping: $viewModel.route,
          case: /HomeRouting.talentProfileDetail
        ) { viewModel in
          CreatorProfileDetailView(viewModel: viewModel.wrappedValue, tabValue: $tabValue)
        } onNavigate: { _ in
          
        } label: {
          EmptyView()
        }
        
        Color.DinotisDefault.baseBackground
          .edgesIgnoringSafeArea(.all)
        
        VStack(spacing: 0) {
          HeaderView(
            type: .textHeader,
            title: LocalizableText.titleFollowedCreator,
            leadingButton: {
              DinotisElipsisButton(
                icon: .generalBackIcon,
                iconColor: .DinotisDefault.black1,
                bgColor: .DinotisDefault.white,
                strokeColor: nil,
                iconSize: 12,
                type: .primary, {
                  dismiss()
                }
              )
            },
            trailingButton: {
              Button {
                viewModel.openWhatsApp()
              } label: {
                Image.generalQuestionIcon
                  .resizable()
                  .scaledToFit()
                  .frame(height: 25)
              }
            }
          )
          
          List {
            if viewModel.talentData.isEmpty {
              HStack {
                
                Spacer()
                
                VStack(alignment: .center, spacing: -10) {
                  Image.onboardingSlide1Image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 266)
                  
                  Text(LocalizableText.choosenCreatorEmpty)
                    .font(.robotoBold(size: 16))
                    .foregroundColor(.black)
                }
                
                Spacer()
              }
              .listRowBackground(Color.clear)
              .listRowSeparator(.hidden)
            } else {
              LazyVGrid(
                columns: Array(
                  repeating: GridItem(.flexible(), spacing: 10),
                  count: UIDevice.current.userInterfaceIdiom == .pad ? 4 : 2
                )
              ) {
                ForEach(viewModel.talentData, id: \.id) { item in
                  Button {
                    viewModel.routeToTalentDetail(username: item.username.orEmpty())
                  } label: {
                    CreatorCard(
                      with: viewModel.convertToCardModel(with: item),
                      size: UIDevice.current.userInterfaceIdiom == .pad ? geo.size.width/4 - 22 : geo.size.width/2 - 22
                    )
                    .onAppear {
                      Task {
                        if item.id == viewModel.talentData.last?.id {
                          viewModel.query.skip = viewModel.query.take
                          viewModel.query.take += 15
                          
                          await viewModel.getFollowedCreator()
                        }
                      }
                    }
                  }
                  .buttonStyle(.plain)
                  
                }
              }
              .padding(.vertical)
              .listRowBackground(Color.clear)
              .listRowSeparator(.hidden)
            }
          }
          .listStyle(.plain)
          .refreshable {
            await viewModel.getFollowedCreator()
          }
        }
        
        DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
      }
    }
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
		.onAppear {
			Task {
				await viewModel.getFollowedCreator()
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

struct FollowedCreatorView_Previews: PreviewProvider {
	static var previews: some View {
        FollowedCreatorView(viewModel: FollowedCreatorViewModel(backToHome: {}), tabValue: .constant(.agenda))
	}
}
