//
//  InboxView.swift
//  DinotisApp
//
//  Created by Irham Naufal on 03/10/23.
//

import DinotisDesignSystem
import SwiftUI

struct InboxView: View {
    
    @EnvironmentObject var viewModel: InboxViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                type: .textHeader,
                title: LocalizableText.creatorInboxTitle,
                headerColor: .white,
                textColor: .DinotisDefault.black1,
                leadingButton:  {
                    Button {
                        
                    } label: {
                        Image.generalBackIcon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding(8)
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
                        counter: viewModel.discussionChatCounter,
                        action: {
                            
                        }
                    )
                    
                    InboxSectionView(
                        icon: .inboxAudienceIcon,
                        title: LocalizableText.sessionCompleted,
                        description: LocalizableText.inboxCompletedSessionDesc,
                        counter: viewModel.completedSessionCounter,
                        action: {
                            
                        }
                    )
                    
                    InboxSectionView(
                        icon: .inboxReviewIcon,
                        title: LocalizableText.talentDetailReviews,
                        description: LocalizableText.inboxReviewDesc,
                        counter: viewModel.reviewCounter,
                        action: {
                            
                        }
                    )
                }
            }
            .background(
                Color.DinotisDefault.baseBackground
                    .ignoresSafeArea()
            )
        }
    }
}

extension InboxView {
    
    struct InboxSectionView: View {
        
        let icon: Image
        let title: String
        let description: String
        @State var counter: String
        let action: () -> Void
        
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(counter)
                            .font(.robotoRegular(size: 14))
                            .foregroundColor(.white)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.DinotisDefault.primary)
                            )
                            .isHidden(counter == "", remove: counter == "")
                        
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
