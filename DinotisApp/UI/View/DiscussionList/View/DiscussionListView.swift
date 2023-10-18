//
//  DiscussionListView.swift
//  DinotisApp
//
//  Created by Irham Naufal on 04/10/23.
//

import DinotisData
import DinotisDesignSystem
import SwiftUI
import SwiftUINavigation

struct DiscussionListView: View {
    
    @EnvironmentObject var viewModel: DiscussionListViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState var searchFocused: Bool
    @EnvironmentObject var customerChatManager: CustomerChatManager
    
    var body: some View {
        ZStack {
            NavigationLink(
                unwrapping: $viewModel.route,
                case: /HomeRouting.scheduleNegotiationChat,
                destination: {viewModel in
                    ScheduleNegotiationChatView(viewModel: viewModel.wrappedValue, isOnSheet: false)
                        .environmentObject(customerChatManager)
                },
                onNavigate: {_ in},
                label: {
                    EmptyView()
                }
            )
            
            VStack(spacing: 0) {
                
                if viewModel.isSearching {
                    HStack(spacing: 16) {
                        Button {
                            withAnimation {
                                viewModel.debouncedText = ""
                                viewModel.searchText = ""
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
                                    viewModel.data = []
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
                
                if viewModel.isLoading {
                    Spacer()
                    
                    DinotisLoadingView(.small, hide: !viewModel.isLoading)
                    
                    Spacer()
                } else {
                    List {
                        if viewModel.isSearching {
                            SearchDiscussionView(viewModel: viewModel)
                        } else {
                            // FIXME: Change this with data from backend
                            ForEach(viewModel.data, id: \.id) { item in
                                ChatCellView(
                                    viewModel: viewModel,
                                    type: viewModel.type,
                                    title: (item.meeting?.title).orEmpty(),
                                    hasAccepted: item.meeting?.startAt != nil,
                                    expiredAt: item.expiredAt.orCurrentDate(),
                                    hasRead: item.status.orEmpty() == "confirmed" || item.status.orEmpty() == "done",
                                    name: (item.user?.name).orEmpty(),
                                    profilePicture: (item.user?.profilePhoto).orEmpty(),
                                    message: item.lastMessage.orEmpty(),
                                    date: item.sendAt.orCurrentDate(),
                                    inbox: item
                                )
                                .listRowSeparator(.hidden)
                                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                            }
                        }
                    }
                    .refreshable(action: {
                        await viewModel.getInboxChat(section: viewModel.currentSection, query: viewModel.debouncedText, isRefresh: true)
                    })
                    .listStyle(.plain)
                }
            }
        }
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
        .onChange(of: viewModel.searchText) { newValue in
            viewModel.debounceText()
        }
        .onChange(of: viewModel.debouncedText) { newValue in
            viewModel.onLoadChats(section: viewModel.currentSection, query: newValue)
        }
        .onAppear {
            viewModel.onLoadChats(section: viewModel.currentSection, query: viewModel.debouncedText)
        }
        .dinotisAlert(
            isPresent: $viewModel.isError,
            type: .general,
            title: LocalizableText.attentionText,
            isError: true,
            message: viewModel.error,
            primaryButton: .init(text: LocalizableText.okText, action: {
                if viewModel.isRefreshFailed {
                    viewModel.routeToRoot()
                }
            })
        )
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
                                        viewModel.data = []
                                        viewModel.onLoadChats(section: tab, query: viewModel.debouncedText)
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
        
        private func headerText(for filter: ChatInboxFilter) -> String {
            switch filter {
            case .desc:
                return LocalizableText.sortLatest
            case .asc:
                return LocalizableText.sortEarliest
            }
        }
    }
    
    struct ChatCellView: View {
        
        @ObservedObject var viewModel: DiscussionListViewModel
        @State var type: DiscussionListType
        @State var title: String
        @State var hasAccepted: Bool
        @State var expiredAt: Date
        @State var hasRead: Bool
        @State var name: String
        @State var profilePicture: String
        @State var message: String
        @State var date: Date
        
        @State var inbox: InboxData
        
        var body: some View {
            Button(action: {
                viewModel.routeToScheduleNegotiationChat(meet: viewModel.convertToUserMeet(meet: inbox), expiredAt: expiredAt)
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
                                    
                                    Text(date.toStringFormat(with: .ddMMM))
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
            print(expiredAt)
            
            let days = timeDifference.day ?? 0
            let hours = timeDifference.hour ?? 0
            
            var formattedString = ""
            
            if days > 0 {
                formattedString += "\(days) \(LocalizableText.dayText) "
            } else {
                formattedString += "\(days) \(LocalizableText.dayText) "
            }
            
            if hours > 0 {
                formattedString += "\(hours) \(LocalizableText.hourText)"
            } else {
                formattedString += "\(hours) \(LocalizableText.hourText)"
            }
            
            do {
                return hasAccepted ? AttributedString(LocalizableText.discussionStatusScheduledSession) : try AttributedString(markdown: LocalizableText.discussionStatusCancelWithin(date: formattedString))
            } catch {
                return hasAccepted ? AttributedString(LocalizableText.discussionStatusScheduledSession) : AttributedString(LocalizableText.discussionStatusCancelWithin(date: formattedString))
            }
        }
    }
    
    struct SearchDiscussionView: View {
        
        @ObservedObject var viewModel: DiscussionListViewModel
        @ObservedObject var state = StateObservable.shared
        
        var body: some View {
            switch viewModel.searchState {
            case .initiate:
                HStack {
                    
                    Spacer()
                    
                    Text(state.userType == 2 ? LocalizableText.discussionSearchAudienceName : LocalizableText.discussionSearchCreatorName)
                        .font(.robotoRegular(size: 12))
                        .foregroundColor(.DinotisDefault.black1)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Spacer()
                }
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            case .success:
                ForEach(viewModel.data, id: \.id) { item in
                    ChatCellView(
                        viewModel: viewModel,
                        type: viewModel.type,
                        title: (item.meeting?.title).orEmpty(),
                        hasAccepted: item.meeting?.startAt != nil,
                        expiredAt: item.expiredAt.orCurrentDate(),
                        hasRead: item.status.orEmpty() == "confirmed" || item.status.orEmpty() == "done",
                        name: (item.user?.name).orEmpty(),
                        profilePicture: (item.user?.profilePhoto).orEmpty(),
                        message: item.lastMessage.orEmpty(),
                        date: item.sendAt.orCurrentDate(),
                        inbox: item
                    )
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
            case .empty:
                HStack {
                    Spacer()
                    
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
                    
                    Spacer()
                }
                .padding()
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
        }
    }
}

#Preview {
    DiscussionListView()
        .environmentObject(DiscussionListViewModel(type: .ongoing))
}
