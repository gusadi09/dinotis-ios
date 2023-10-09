//
//  DiscussionListView.swift
//  DinotisApp
//
//  Created by Irham Naufal on 04/10/23.
//

import DinotisData
import DinotisDesignSystem
import SwiftUI

struct DiscussionListView: View {
    
    @EnvironmentObject var viewModel: DiscussionListViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState var searchFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            
            if viewModel.isSearching {
                HStack(spacing: 16) {
                    Button {
                        withAnimation {
                            searchFocused = false
                            viewModel.isSearching = false
                        }
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
                    
                    SearchTextField(LocalizableText.discussionSearchPlaceholder, text: $viewModel.searchText)
                        .focused($searchFocused)
                }
                .padding()
                
            } else {
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
                            withAnimation {
                                viewModel.isSearching = true
                                searchFocused = true
                            }
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.DinotisDefault.black2)
                                .padding(12)
                        }
                    }
            }
            
            FilterDiscussionView(viewModel: viewModel)
                .isHidden(viewModel.isSearching, remove: viewModel.isSearching)
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    if viewModel.isSearching {
                        SearchDiscussionView(viewModel: viewModel)
                    } else {
                        // FIXME: Change this with data from backend
                        ForEach(viewModel.data, id: \.id) { item in
                            ChatCellView(
                                type: viewModel.type,
                                title: item.title,
                                hasAccepted: item.hasAccepted,
                                expiredAt: item.expiredAt,
                                hasRead: item.hasRead,
                                name: item.name,
                                profilePicture: item.profilePicture,
                                message: item.message,
                                date: item.date
                            )
                        }
                    }
                }
            }
            .background(Color.DinotisDefault.baseBackground)
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
            .background(Color.white)
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
        @State var hasAccepted: Bool
        @State var expiredAt: Date
        @State var hasRead: Bool
        @State var name: String
        @State var profilePicture: String
        @State var message: String
        @State var date: Date
        
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
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
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
                .background(Color.white)
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
    
    struct SearchDiscussionView: View {
        
        @ObservedObject var viewModel: DiscussionListViewModel
        @ObservedObject var state = StateObservable.shared
        
        var body: some View {
            switch viewModel.searchState {
            case .initiate:
                Text(state.userType == 2 ? LocalizableText.discussionSearchAudienceName : LocalizableText.discussionSearchCreatorName)
                    .font(.robotoRegular(size: 12))
                    .foregroundColor(.DinotisDefault.black1)
                    .multilineTextAlignment(.center)
                    .padding()
            case .success:
                ForEach(viewModel.searchedData, id: \.id) { item in
                    ChatCellView(
                        type: viewModel.type,
                        title: item.title,
                        hasAccepted: item.hasAccepted,
                        expiredAt: item.expiredAt,
                        hasRead: item.hasRead,
                        name: item.name,
                        profilePicture: item.profilePicture,
                        message: item.message,
                        date: item.date
                    )
                }
            case .empty:
                VStack(spacing: 16) {
                    Image.searchNotFoundImage
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 235)
                    
                    Text(LocalizableText.discussionSearchNotFound)
                        .font(.robotoRegular(size: 12))
                        .foregroundColor(.DinotisDefault.black1)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        }
    }
}

#Preview {
    DiscussionListView()
        .environmentObject(DiscussionListViewModel(type: .ongoing))
}
