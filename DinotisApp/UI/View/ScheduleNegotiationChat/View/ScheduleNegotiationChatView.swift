//
//  ScheduleNegotiationChatView.swift
//  DinotisApp
//
//  Created by Gus Adi on 05/10/22.
//

import SwiftUI
import DinotisData
import DinotisDesignSystem

struct ScheduleNegotiationChatView: View {

	@ObservedObject var viewModel: ScheduleNegotiationChatViewModel
	@EnvironmentObject var customerChatManager: CustomerChatManager
    let isOnSheet: Bool
    let calendar = Calendar(identifier: .iso8601)

	var body: some View {
		ZStack {
            Color.DinotisDefault.baseBackground.edgesIgnoringSafeArea(.all)

			VStack(spacing: 0) {
				HeaderView(viewModel: viewModel)

                if customerChatManager.isLoading || viewModel.isLoading {
                    Spacer()
                    
                    ProgressView()
                        .progressViewStyle(.circular)
                    
                    Spacer()
                } else {
                    ScrollViewReader { scroll in
                        List {
                            Section {
                                EndChatLimitationView(viewModel: viewModel)
                                    .padding(.top, 5)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            
                            Section {
                                ForEach(customerChatManager.groupedMessage.sorted(by: {
                                    $0.date < $1.date
                                }), id: \.id) { item in
                                    HStack {
                                        
                                        Spacer()
                                        
                                        if calendar.isDateInYesterday(item.date) {
                                            Text(LocalizableText.yesterday)
                                                .font(.robotoRegular(size: 12))
                                                .foregroundColor(.DinotisDefault.primary)
                                                .padding(.vertical, 4)
                                                .padding(.horizontal, 12)
                                                .overlay(
                                                    Capsule()
                                                        .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                                                )
                                        } else if calendar.isDateInToday(item.date) {
                                            Text(LocalizableText.today)
                                                .font(.robotoRegular(size: 12))
                                                .foregroundColor(.DinotisDefault.primary)
                                                .padding(.vertical, 4)
                                                .padding(.horizontal, 12)
                                                .overlay(
                                                    Capsule()
                                                        .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                                                )
                                        } else {
                                            Text(item.date.toStringFormat(with: .ddMMMyyyy))
                                                .font(.robotoRegular(size: 12))
                                                .foregroundColor(.DinotisDefault.primary)
                                                .padding(.vertical, 4)
                                                .padding(.horizontal, 12)
                                                .overlay(
                                                    Capsule()
                                                        .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                                                )
                                        }
                                        
                                        Spacer()
                                    }
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(.init(top: 10, leading: 20, bottom: 5, trailing: 20))
                                    
                                    ForEach(item.chat, id: \.id) { item in
                                        HStack {
                                            if item.author == viewModel.state.userId {
                                                Spacer()
                                            }
                                            
                                            ChatBubbleView(
                                                sender: item.name.orEmpty(),
                                                message: item.body,
                                                date: item.date,
                                                isSender: item.author == viewModel.state.userId
                                            )
                                            .tag(item.id)
                                            .onAppear {
                                                if item.id == (customerChatManager.messages.last?.id).orEmpty() {
                                                    viewModel.count += 30
                                                    customerChatManager.getMessages(count: viewModel.count, isMore: true)
                                                }
                                            }
                                            
                                            if item.author != viewModel.state.userId {
                                                Spacer()
                                            }
                                        }
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color.clear)
                                        .listRowInsets(.init(top: 5, leading: 20, bottom: 5, trailing: 20))
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .onChange(of: customerChatManager.messages.count) { newValue in
                            withAnimation {
                                scroll.scrollTo((customerChatManager.groupedMessage.sorted(by: {
                                    $0.date < $1.date
                                }).last?.chat.last?.id).orEmpty())
                            }
                        }
                        .onAppear {
                            withAnimation {
                                scroll.scrollTo((customerChatManager.groupedMessage.sorted(by: {
                                    $0.date < $1.date
                                }).last?.chat.last?.id).orEmpty())
                            }
                        }
                    }
                }

				HStack(alignment: .bottom, spacing: 15) {
                    if viewModel.isCanceledOrEnded() {
                        HStack {
                            Spacer()
                            
                            Text(LocalizableText.chatDisabledText)
                                .font(.robotoRegular(size: 12))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.DinotisDefault.black3)
                            
                            Spacer()
                        }
                        .padding(10)
                        .background(
                            Capsule()
                                .foregroundColor(.DinotisDefault.baseBackground)
                        )
                    } else {
                        MultilineTextField(LocaleText.writeYourMessagePlaceholder, text: $viewModel.textMessage)
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundColor(Color(.systemGray6))
                            )
                            .disabled(customerChatManager.isLoading || viewModel.isLoading)
                        
                        Button {
                            customerChatManager.sendMessage(viewModel.textMessage)
                            viewModel.textMessage = ""
                        } label: {
                            Image.Dinotis.flatPlaneButtonIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 45)
                                .opacity(viewModel.textMessage.isEmpty || !viewModel.textMessage.isStringContainWhitespaceAndText() || customerChatManager.isLoading || viewModel.isLoading ? 0.5 : 1)
                        }
                        .disabled(viewModel.textMessage.isEmpty || !viewModel.textMessage.isStringContainWhitespaceAndText() || customerChatManager.isLoading || viewModel.isLoading)
                    }
				}
				.padding(15)
				.background(
					Color.white.edgesIgnoringSafeArea(.bottom)
						.shadow(color: .black.opacity(0.1), radius: 5, x: -2, y: 0)
				)
			}
		}
		.navigationBarHidden(true)
		.navigationBarTitle("")
        .onChange(of: viewModel.tokenConversation, perform: { newValue in
            if !isOnSheet {
                if !viewModel.tokenConversation.isEmpty {
                    customerChatManager.connect(accessToken: newValue, conversationName: (viewModel.meetingData.meetingRequest?.id).orEmpty())
                }
            }
        })
        .onAppear(perform: {
            if !isOnSheet {
                if customerChatManager.messages.isEmpty {
                    Task {
                        await viewModel.getConversationToken(id: (viewModel.meetingData.meetingRequest?.id).orEmpty())
                    }
                } else if customerChatManager.conversation?.sid != viewModel.meetingData.roomSid {
                    Task {
                        await viewModel.getConversationToken(id: (viewModel.meetingData.meetingRequest?.id).orEmpty())
                    }
                }
            }
        })
        .dinotisAlert(
            isPresent: $viewModel.isShowAlert,
            type: .general,
            title: viewModel.alertTitle(),
            isError: viewModel.typeAlert == .error || viewModel.typeAlert == .refreshFailed,
            message: viewModel.alertContent(),
            primaryButton: .init(text: viewModel.alertButtonText(), action: {
                viewModel.alertAction()
            })
        )
	}
}

extension ScheduleNegotiationChatView {
	struct HeaderView: View {
		@Environment(\.dismiss) var dismiss

		@ObservedObject var viewModel: ScheduleNegotiationChatViewModel

		var body: some View {
            VStack {
                ZStack {
                    HStack {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Image.Dinotis.arrowBackIcon
                                .padding()
                                .background(
                                    Circle()
                                        .foregroundColor(Color.white)
                                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 0)
                                )
                        })
                        .padding()
                        
                        Spacer()
                    }
                    
                    Text(LocaleText.newScheduleDiscussionTitle)
                        .font(.robotoBold(size: 14))
                        .foregroundColor(.black)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .frame(width: UIScreen.main.bounds.width - 120)
                }
                
                HStack(spacing: 16) {
                    ImageLoader(url: viewModel.profileImage(), width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .scaledToFit()
                        .frame(height: 48)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if viewModel.state.userType == 2 {
                            Text(viewModel.profileName())
                                .font(.robotoRegular(size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(.DinotisDefault.black1)
                                .lineLimit(1)
                        } else {
                            if viewModel.meetingData.user?.isVerified ?? false {
                                HStack(spacing: 0) {
                                    Text("\(viewModel.profileName()) ")
                                        .font(.robotoRegular(size: 14))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.DinotisDefault.black1)
                                        .lineLimit(1)
                                    
                                    Image.sessionCardVerifiedIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 12)
                                }
                                
                            } else {
                                Text(viewModel.profileName())
                                    .font(.robotoRegular(size: 14))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.DinotisDefault.black1)
                                    .lineLimit(1)
                            }
                            
                        }
                        
                        Text(LocalizableText.chatBookedSession(title: viewModel.sessionName()))
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.DinotisDefault.black1.opacity(0.6))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
			.background(
                Color.white.shadow(color: .black.opacity(0.1), radius: 8, x: 2, y: 2).edgesIgnoringSafeArea(.all)
			)
		}
	}

	struct EndChatLimitationView: View {

		@ObservedObject var viewModel: ScheduleNegotiationChatViewModel

		var body: some View {
			HStack {
				Text(LocaleText.finalConfirmationLimitText)
					.font(.robotoMedium(size: 12))
                    .foregroundColor(.DinotisDefault.black2)
					.multilineTextAlignment(.leading)

				Spacer()

                Text(DateUtils.dateFormatter(viewModel.endChat, forFormat: .EEEEddMMMyyyHHmm))
					.font(.robotoMedium(size: 12))
					.foregroundColor(.DinotisDefault.primary)
					.multilineTextAlignment(.trailing)
			}
			.padding(15)
			.background(
				RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.DinotisDefault.lightPrimary)
			)
		}
	}
}

struct ScheduleNegotiationChatView_Previews: PreviewProvider {
	static var previews: some View {
        ScheduleNegotiationChatView(
            viewModel: ScheduleNegotiationChatViewModel(
                meetingData: UserMeetingData(
                    id: nil,
                    title: nil,
                    meetingDescription: nil,
                    price: nil,
                    startAt: nil,
                    endAt: nil,
                    isPrivate: nil,
                    isLiveStreaming: nil,
                    slots: nil,
                    participants: nil,
                    userID: nil,
                    startedAt: nil,
                    endedAt: nil,
                    createdAt: nil,
                    updatedAt: nil,
                    deletedAt: nil,
                    bookings: nil,
                    user: nil,
                    participantDetails: nil,
                    meetingBundleId: nil,
                    meetingRequestId: nil,
                    status: nil,
                    meetingRequest: nil,
                    expiredAt: nil,
                    background: nil,
                    meetingCollaborations: nil,
                    meetingUrls: nil,
                    meetingUploads: nil,
                    roomSid: nil,
                    dyteMeetingId: nil,
                    isInspected: nil,
                    reviews: nil
                ),
                expireDate: Date(),
                backToHome: {}
            ),
            isOnSheet: false
        )
	}
}
