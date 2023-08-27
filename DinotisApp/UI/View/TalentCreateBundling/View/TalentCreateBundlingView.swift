//
//  TalentCreateBundlingView.swift
//  DinotisApp
//
//  Created by Garry on 26/09/22.
//

import SwiftUI
import SwiftUINavigation
import DinotisDesignSystem

struct TalentCreateBundlingView: View {
    
    @ObservedObject var viewModel: TalentCreateBundlingViewModel

	@Binding var meetingArray: [String]
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geo in
            
            NavigationLink(
                unwrapping: $viewModel.route,
                case: /HomeRouting.bundlingForm,
                destination: { viewModel in
                    BundlingFormView(viewModel: viewModel.wrappedValue)
                },
                onNavigate: { _ in },
                label: {
                    EmptyView()
                }
            )
            
            ZStack {
                Image.Dinotis.linearGradientBackground
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
					.alert(isPresented: $viewModel.isError) {
						Alert(
							title: Text(LocaleText.attention),
							message: Text(viewModel.error.orEmpty()),
							dismissButton: .default(Text(LocaleText.okText))
						)
					}
                
				VStack {
					HeaderView()

					DinotisList {
						if viewModel.isEdit {
							viewModel.meetingIdArray = meetingArray
                            Task {
                                await viewModel.getAvailableMeetingForEdit()
                            }
						} else {
                            Task {
                                await viewModel.getAvailableMeeting()
                            }
						}
					} introspectConfig: { view in
						view.separatorStyle = .none
						view.indicatorStyle = .white
						view.sectionHeaderHeight = -10
						view.showsVerticalScrollIndicator = false
						viewModel.use(for: view) { refresh in
							if viewModel.isEdit {
								viewModel.meetingIdArray = meetingArray
                                Task {
                                    await viewModel.getAvailableMeetingForEdit()
                                }
							} else {
                                Task {
                                    await viewModel.getAvailableMeeting()
                                }
							}
							refresh.endRefreshing()
						}
					} content: {
						HStack {
							Spacer()

							Text(LocaleText.bundlingListCaption)
								.font(.robotoRegular(size: 12))
								.foregroundColor(.black)
								.padding()

							Spacer()
						}
						.listRowBackground(Color.clear)

						ForEach(viewModel.meetingList, id: \.id) { item in
                            BundlingMiniCardView(meeting: .constant(item), meetingIdArray: $viewModel.meetingIdArray) {
								viewModel.addMeeting(id: item.id.orEmpty())
							}
							.listRowBackground(Color.clear)
						}
					}
                    
                    VStack {
                        VStack {
                            HStack {
                                Button {
                                    viewModel.allSelected.toggle()
                                    viewModel.selectAllSession()
                                } label: {
                                    Image(systemName: viewModel.allSelected || viewModel.isAllSelectedManually() ? "checkmark.circle.fill" : "circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30)
                                        .foregroundColor(.DinotisDefault.primary)
                                }
                                
                                Text(LocaleText.selectAll)
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Text("\(viewModel.meetingIdArray.count) \(LocaleText.selectedSession)")
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.black)
                            }
                            
                            Button {
								if viewModel.isEdit {
									meetingArray = viewModel.meetingIdArray
									dismiss()
								} else {
									viewModel.routeToBundlingForm()
								}
                            } label: {
                                HStack {
                                    Spacer()
                                    
                                    Text(LocaleText.continueAlt)
                                        .font(.robotoMedium(size: 12))
                                        .foregroundColor(viewModel.meetingIdArray.count < 2 ? Color(.systemGray3) : .white)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(viewModel.meetingIdArray.count < 2 ? Color(.systemGray5) : Color.DinotisDefault.primary)
                                .cornerRadius(8)
                            }
                            .disabled(viewModel.meetingIdArray.count < 2)
                        }
                        .padding()
                        .edgesIgnoringSafeArea(.bottom)
                        .background(Color.white)
                    }
                    .padding(.top, -8)

                }
              
              DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
            }
            .onAppear {
				if viewModel.isEdit {
					viewModel.meetingIdArray = meetingArray
                    Task {
                        await viewModel.getAvailableMeetingForEdit()
                    }
				} else {
                    Task {
                        await viewModel.getAvailableMeeting()
                    }
				}
            }
            .onChange(of: viewModel.meetingIdArray) { value in
                viewModel.allSelected = value.count == viewModel.meetingList.count
            }
        }
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
    }
}

struct TalentCreateBundlingView_Previews: PreviewProvider {
    static var previews: some View {
		TalentCreateBundlingView(viewModel: TalentCreateBundlingViewModel(isEdit: false, backToHome: {}, backToBundlingList: {}), meetingArray: .constant([]))
    }
}

extension TalentCreateBundlingView {
    struct HeaderView: View {

        @Environment(\.dismiss) var dismiss

        var body: some View {
			HStack {
				Button(action: {
					dismiss()

				}, label: {
					Image.Dinotis.arrowBackIcon
						.padding()
				})
				.background(Color.white)
				.clipShape(Circle())
				.shadow(color: .black.opacity(0.1), radius: 20)

				Spacer()

				Text(LocaleText.chooseSession)
					.font(.robotoBold(size: 14))
					.foregroundColor(.black)
					.padding(.trailing)

				Spacer()
			}
			.padding()
			.padding(.trailing)
        }
    }
}
