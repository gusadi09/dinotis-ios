//
//  CreatorPickerView.swift
//  DinotisApp
//
//  Created by Gus Adi on 26/04/23.
//

import SwiftUI
import DinotisData
import DinotisDesignSystem

struct CreatorPickerView: View {
    
    @StateObject var viewModel = CreatorPickerViewModel()
    
    @Binding var arrUsername: [String]?
    @Binding var arrTalent: [MeetingCollaborationData]
    
    var back: () -> Void
    
    init(arrUsername: Binding<[String]?>, arrTalent: Binding<[MeetingCollaborationData]>, back: @escaping () -> Void) {
        self._arrUsername = arrUsername
        self._arrTalent = arrTalent
        self.back = back
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(LocalizableText.selectCreatorForCollabTitle)
                    .font(.robotoMedium(size: 14))

                Spacer()
                Button(action: {
                    back()
                }, label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 10)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                })
            }
            .padding(.horizontal)
            .padding(.top)
            .onAppear {
                viewModel.onGetTalent(isMore: false)
            }

            HStack(spacing: 15) {
                Image.Dinotis.magnifyingIcon

                TextField(LocalizableText.searchCreatorPlaceholder, text: $viewModel.search)
                    .font(.robotoRegular(size: 12))
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
                    .accentColor(.black)
                    .onChange(of: viewModel.search) { _ in
                        viewModel.searchTalent()
                    }
            }
            .padding()
            .background(Color.backgroundProfile)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1.0)
            )
            .padding(.horizontal)
            .padding(.top, 10)

            if viewModel.isLoading {
                VStack {
                    Spacer()
                    
                    DinotisLoadingView(.small, hide: !viewModel.isLoading)
                    
                    Spacer()
                }
                .padding()
            } else if viewModel.isError {
                VStack(spacing: 20) {
                    Spacer()
                    
                    VStack(spacing: 15) {
                        Image.searchNotFoundImage
                          .resizable()
                          .scaledToFit()
                          .frame(width: 180)
                        
                        Text(LocalizableText.retrySubtitle)
                            .font(.robotoRegular(size: 14))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    }
                    
                    DinotisPrimaryButton(
                        text: LocalizableText.retryText,
                        type: .adaptiveScreen,
                        textColor: .white,
                        bgColor: .DinotisDefault.primary
                    ) {
                        viewModel.take = 10
                        viewModel.onGetTalent(isMore: false)
                    }
                    
                    Spacer()
                }
                .padding()
            } else {
                ScrollView(.vertical, showsIndicators: false, content: {
                    LazyVStack {
                        ForEach(viewModel.talent, id: \.id) { items in
                            if viewModel.talent.last?.id == items.id {
                                VStack {
                                    HStack {
                                        ImageLoader(url: items.profilePhoto.orEmpty(), width: 35, height: 35)
                                            .frame(width: 35, height: 35)
                                            .clipShape(Circle())
                                        
                                        Text(items.name.orEmpty())
                                            .font(.robotoRegular(size: 12))
                                        
                                        Spacer()
                                        
                                        if arrTalent.contains(where: {
                                            $0.user?.id == items.id
                                        }) {
                                            Image.Dinotis.stepCheckmark
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 20)
                                        }
                                    }
                                    .padding(.vertical, 15)
                                    
                                    Divider()
                                    
                                    if viewModel.isLoadingMore {
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                            .padding(.top, 8)
                                    }
                                }
                                .padding(.horizontal)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    arrTalent.append(
                                        MeetingCollaborationData(
                                            id: Int.random(in: 0...9999999),
                                            meetingId: nil,
                                            username: items.username,
                                            user: UserResponse(
                                                coinBalance: nil,
                                                createdAt: nil,
                                                email: nil,
                                                emailVerifiedAt: nil,
                                                id: items.id,
                                                isActive: nil,
                                                isPasswordFilled: nil,
                                                isVerified: items.isVerified,
                                                isVisible: nil,
                                                lastLoginAt: nil,
                                                name: items.name,
                                                username: items.username,
                                                phone: nil,
                                                platform: nil,
                                                profession: nil,
                                                professionId: nil,
                                                professions: items.professions,
                                                stringProfessions: items.stringProfessions,
                                                profileDescription: items.profileDescription,
                                                profilePhoto: items.profilePhoto,
                                                registeredWith: nil,
                                                roles: nil,
                                                updatedAt: nil,
                                                userHighlights: nil,
                                                management: nil,
                                                managements: nil,
                                                meetingCount: nil,
                                                followerCount: nil,
                                                rating: nil, 
                                                userAvailability: nil
                                            ),
                                            approvedAt: nil,
                                            declinedAt: nil
                                        )
                                    )
                                    arrUsername = arrTalent.compactMap({
                                        $0.username.orEmpty()
                                    })
                                    back()
                                }
                                .onAppear {
                                    if viewModel.talent.last?.id == items.id && viewModel.nextCursor != nil {
                                        viewModel.take += 10
                                        viewModel.onGetTalent(isMore: true)
                                    }
                                    
                                    if viewModel.nextCursor == nil {
                                        viewModel.take = 10
                                    }
                                }
                            } else {
                                VStack {
                                    HStack {
                                        ImageLoader(url: items.profilePhoto.orEmpty(), width: 35, height: 35)
                                            .frame(width: 35, height: 35)
                                            .clipShape(Circle())
                                        
                                        Text(items.name.orEmpty())
                                            .font(.robotoRegular(size: 12))
                                        
                                        Spacer()
                                        
                                        if arrTalent.contains(where: {
                                            $0.user?.id == items.id
                                        }) {
                                            Image.Dinotis.stepCheckmark
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 20)
                                        }
                                    }
                                    .padding(.vertical, 15)
                                    
                                    Divider()
                                }
                                .padding(.horizontal)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    arrTalent.append(
                                        MeetingCollaborationData(
                                            id: Int.random(in: 0...9999999),
                                            meetingId: nil,
                                            username: items.username,
                                            user: UserResponse(
                                                coinBalance: nil,
                                                createdAt: nil,
                                                email: nil,
                                                emailVerifiedAt: nil,
                                                id: items.id,
                                                isActive: nil,
                                                isPasswordFilled: nil,
                                                isVerified: items.isVerified,
                                                isVisible: nil,
                                                lastLoginAt: nil,
                                                name: items.name,
                                                username: items.username,
                                                phone: nil,
                                                platform: nil,
                                                profession: nil,
                                                professionId: nil,
                                                professions: items.professions,
                                                stringProfessions: items.stringProfessions,
                                                profileDescription: items.profileDescription,
                                                profilePhoto: items.profilePhoto,
                                                registeredWith: nil,
                                                roles: nil,
                                                updatedAt: nil,
                                                userHighlights: nil,
                                                management: nil,
                                                managements: nil,
                                                meetingCount: nil,
                                                followerCount: nil,
                                                rating: nil,
                                                userAvailability: nil
                                            ),
                                            approvedAt: nil,
                                            declinedAt: nil
                                        )
                                    )
                                    arrUsername = arrTalent.compactMap({
                                        $0.username.orEmpty()
                                    })
                                    back()
                                }
                                .onAppear {
                                    if viewModel.talent.last?.id == items.id && viewModel.nextCursor != nil {
                                        viewModel.take += 10
                                        viewModel.onGetTalent(isMore: true)
                                    }
                                    
                                    if viewModel.nextCursor == nil {
                                        viewModel.take = 10
                                    }
                                }
                            }
                        }
                    }
                })
            }
        }
    }
}

struct CreatorPickerView_Previews: PreviewProvider {
    static var previews: some View {
        CreatorPickerView(arrUsername: .constant([]), arrTalent: .constant([]), back: {})
    }
}
