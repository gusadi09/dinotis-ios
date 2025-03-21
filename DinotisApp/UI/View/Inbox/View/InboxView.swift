//
//  InboxView.swift
//  DinotisApp
//
//  Created by Irham Naufal on 03/10/23.
//

import DinotisData
import DinotisDesignSystem
import SwiftUI
import SwiftUINavigation

struct InboxView: View {
    
    @ObservedObject var state = StateObservable.shared
    @EnvironmentObject var viewModel: InboxViewModel
    @Environment(\.dismiss) var dismiss
    @StateObject private var customerChatManager = CustomerChatManager()
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationLink(
                unwrapping: $viewModel.route,
                case: /HomeRouting.discussionList) { viewModel in
                    DiscussionListView()
                        .environmentObject(viewModel.wrappedValue)
                        .environmentObject(customerChatManager)
                } onNavigate: { _ in
                    
                } label: {
                    EmptyView()
                }
            
            NavigationLink(
                unwrapping: $viewModel.route,
                case: /HomeRouting.reviewList) { viewModel in
                    ReviewListView()
                        .environmentObject(viewModel.wrappedValue)
                } onNavigate: { _ in
                    
                } label: {
                    EmptyView()
                }
            
            HeaderView(
                type: .textHeader,
                title: LocalizableText.creatorInboxTitle,
                headerColor: .white,
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
                                    .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/.opacity(0.05), radius: 10, x: 0, y: 0)
                            )
                    }
                })
            
            ScrollView {
                VStack(spacing: 0) {
                    InboxSectionView(
                        icon: .inboxScheduleIcon,
                        title: LocalizableText.inboxDiscussScheduleTitle,
                        description: LocalizableText.inboxDiscussScheduleDesc,
                        counter: $viewModel.discussionChatCounter,
                        action: {
                            viewModel.routeToDiscussionList(.ongoing)
                        }, 
                        isLoading: $viewModel.isLoadingInbox
                    )
                    
                    InboxSectionView(
                        icon: .inboxAudienceIcon,
                        title: LocalizableText.sessionCompleted,
                        description: LocalizableText.inboxCompletedSessionDesc,
                        counter: $viewModel.completedSessionCounter,
                        action: {
                            viewModel.routeToDiscussionList(.completed)
                        },
                        isLoading: .constant(false)
                    )
                    .isHidden(true, remove: true) // hide, since this menu unnecesarry
                    
                    InboxSectionView(
                        icon: .inboxReviewIcon,
                        title: LocalizableText.talentDetailReviews,
                        description: LocalizableText.inboxReviewDesc,
                        counter: $viewModel.reviewCounter,
                        action: {
                            viewModel.routeToReviewList()
                        },
                        isLoading: $viewModel.isLoadingReview
                    )
                    .isHidden(state.userType != 2, remove: state.userType != 2)
                }
            }
            .background(
                Color.DinotisDefault.baseBackground
                    .ignoresSafeArea()
            )
        }
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
        .onAppear {
            customerChatManager.disconnect()
            viewModel.onLoadReviews(section: .desc)
            viewModel.onLoadChats(section: .desc, query: "")
        }
    }
}

extension InboxView {
    
    struct InboxSectionView: View {
        
        let icon: Image
        let title: String
        let description: String
        @Binding var counter: String
        let action: () -> Void
        @Binding var isLoading: Bool
        
        var body: some View {
            Button(action: {
                action()
            }, label: {
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack(spacing: 16) {
                        icon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .foregroundColor(.DinotisDefault.black2)
                                .font(.robotoRegular(size: 14))
                            
                            Text(description)
                                .foregroundColor(.DinotisDefault.black3)
                                .font(.robotoRegular(size: 12))
                        }
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if isLoading {
                            LottieView(name: "regular-loading", loopMode: .loop)
                                .scaledToFit()
                                .frame(height: 15)
                        } else {
                            Text(counter)
                                .font(.robotoRegular(size: 14))
                                .foregroundColor(.white)
                                .padding(4)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.DinotisDefault.primary)
                                )
                                .isHidden(counter == "0", remove: counter == "0")
                        }
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.DinotisDefault.black1)
                    }
                    .padding(.vertical, 24)
                    .padding(.horizontal, 16)
                }
                .background(
                    Color.white
                )
            })
        }
    }
}

#Preview {
    InboxView()
        .environmentObject(InboxViewModel())
}
