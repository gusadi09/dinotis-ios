//
//  DiscussionListView.swift
//  DinotisApp
//
//  Created by Irham Naufal on 04/10/23.
//

import DinotisDesignSystem
import SwiftUI

struct DiscussionListView: View {
    
    @EnvironmentObject var viewModel: DiscussionListViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                type: .textHeader,
                title: viewModel.type == .ongoing ?
                LocalizableText.inboxDiscussScheduleTitle : LocalizableText.sessionCompleted,
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
                }) {
                    Button {
                        
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.DinotisDefault.black2)
                            .padding(12)
                    }
                }
            
            FilterDiscussionView(viewModel: viewModel)
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    // FIXME: Change this with data from backend
                    ForEach(0...10, id: \.self) { _ in
                        ChatCellView(
                            type: viewModel.type,
                            title: "Talk with Me About Personal wellbeing in one hour or maybe two is good tho",
                            hasAccepted: .constant(.random()),
                            expiredAt: .now + 100000,
                            hasRead: .random(),
                            name: "Zee JKT48",
                            profilePicture: "https://media.kompas.tv/library/image/content_article/article_img/20220926073750.jpg",
                            message: .constant("Hello! would love to discuss our upcoming for the next season"),
                            date: .constant(.now)
                        )
                    }
                }
            }
        }
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
    }
}

extension DiscussionListView {
    struct FilterDiscussionView: View {
        
        @ObservedObject var viewModel: DiscussionListViewModel
        
        var body: some View {
            VStack(spacing: 0) {
                Divider()
                
                ScrollViewReader { scrollView in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(viewModel.tabSections, id: \.self) { tab in
                                Button {
                                    withAnimation {
                                        viewModel.currentSection = tab
                                        scrollView.scrollTo(tab, anchor: .center)
                                    }
                                } label: {
                                    Text(headerText(for: tab))
                                        .font(tab == viewModel.currentSection ? .robotoBold(size: 14) : .robotoRegular(size: 14))
                                        .foregroundColor(tab == viewModel.currentSection ? .DinotisDefault.primary : .DinotisDefault.black1)
                                        .frame(maxWidth: .infinity)
                                        .padding(12)
                                        .frame(maxHeight: 38)
                                        .cornerRadius(20)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(tab == viewModel.currentSection ? Color.DinotisDefault.lightPrimary : .white)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .inset(by: 0.5)
                                                .stroke(Color.DinotisDefault.lightPrimary, lineWidth: 1)
                                        )
                                }
                                .id(tab)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        
        private func headerText(for filter: DiscussionFilter) -> String {
            switch filter {
            case .latest:
                return LocalizableText.sortLatest
            case .earliest:
                return LocalizableText.sortEarliest
            case .unread:
                return LocalizableText.discussionTagUnread
            case .nearest:
                return LocalizableText.discussionTagNearestSchedule
            }
        }
    }
    
    struct ChatCellView: View {
        
        @State var type: DiscussionListType
        @State var title: String
        @Binding var hasAccepted: Bool
        @State var expiredAt: Date
        @State var hasRead: Bool
        @State var name: String
        @State var profilePicture: String
        @Binding var message: String
        @Binding var date: Date
        
        var body: some View {
            Button(action: {
                withAnimation {
                    hasRead = true
                }
            }, label: {
                VStack(spacing: 0) {
                    Divider()
                    
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(hasRead ? Color.DinotisDefault.black2 : Color.DinotisDefault.primary)
                                .frame(width: 6, height: 6)
                            
                            Text(title)
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(hasRead ? .DinotisDefault.black2 : .DinotisDefault.primary)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity)
                            
                            Group {
                                switch type {
                                case .ongoing:
                                    Text(expiredTime)
                                case .completed:
                                    Text(LocalizableText.doneLabel)
                                }
                            }
                            .font(.robotoRegular(size: 10))
                            .foregroundColor(.DinotisDefault.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(Color.DinotisDefault.lightPrimary)
                            .cornerRadius(7)
                            .overlay(
                                RoundedRectangle(cornerRadius: 7)
                                    .inset(by: 0.5)
                                    .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                            )
                        }
                        
                        HStack(spacing: 8) {
                            DinotisImageLoader(urlString: profilePicture)
                                .scaledToFill()
                                .frame(width: 48, height: 48)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(name)
                                        .font(.robotoBold(size: 14))
                                        .foregroundColor(.DinotisDefault.black1)
                                        .lineLimit(1)
                                    
                                    Spacer()
                                    
                                    Text(messageDate)
                                        .font(.robotoRegular(size: 12))
                                        .foregroundColor(hasRead ? .DinotisDefault.black1 : .DinotisDefault.primary)
                                }
                                
                                HStack {
                                    Text(message)
                                        .font(.robotoRegular(size: 12))
                                        .foregroundColor(.DinotisDefault.black2)
                                        .lineLimit(1)
                                    
                                    Spacer()
                                    
                                    if !hasRead {
                                        Circle()
                                            .fill(Color.DinotisDefault.primary)
                                            .frame(width: 9, height: 9)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal)
                }
            })
        }
        
        private var expiredTime: AttributedString {
            let timeDifference = Calendar.current.dateComponents([.day, .hour, .minute], from: Date(), to: expiredAt)
            
            let days = timeDifference.day ?? 0
            let hours = timeDifference.hour ?? 0
            
            var formattedString = ""
            
            if days > 0 {
                formattedString += "\(days) \(LocalizableText.dayText) "
            }
            
            if hours > 0 {
                formattedString += "\(hours) \(LocalizableText.hourText)"
            }
            
            do {
                return hasAccepted ? AttributedString(LocalizableText.discussionStatusScheduledSession) : try AttributedString(markdown: LocalizableText.discussionStatusCancelWithin(date: formattedString))
            } catch {
                return hasAccepted ? AttributedString(LocalizableText.discussionStatusScheduledSession) : AttributedString(LocalizableText.discussionStatusCancelWithin(date: formattedString))
            }
        }
        
        private var messageDate: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM"

            return dateFormatter.string(from: date)
        }
    }
}

#Preview {
    DiscussionListView()
        .environmentObject(DiscussionListViewModel(type: .ongoing))
}
