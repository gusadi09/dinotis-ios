//
//  TalentCardListView.swift
//  DinotisApp
//
//  Created by Gus Adi on 03/10/22.
//

import DinotisDesignSystem
import SwiftUI
import SwiftUINavigation

struct TalentCardListView: View {

    @ObservedObject var viewModel: TalentCardListViewModel

    var body: some View {
        ZStack {
            Color.secondaryBackground.edgesIgnoringSafeArea(.all)
				.alert(isPresented: $viewModel.isRefreshFailed) {
					Alert(
						title: Text(LocaleText.attention),
						message: Text(LocaleText.sessionExpireText),
						dismissButton: .default(
							Text(LocaleText.returnText),
							action: {
								viewModel.routeToRoot()
							}
						)
					)
				}

            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    HeaderView(viewModel: viewModel)
						.alert(isPresented: $viewModel.isError) {
							Alert(
								title: Text(LocaleText.attention),
								message: Text(viewModel.error.orEmpty()),
								dismissButton: .default(Text(LocaleText.returnText))
							)
						}

                    DinotisList(
                        refreshAction: {
							Task {
								await viewModel.onRefresh()
							}
                        },
                        introspectConfig: { view in
                            view.separatorStyle = .none
                            view.indicatorStyle = .white
                            view.showsVerticalScrollIndicator = false
							viewModel.use(for: view) { refresh in
								Task {
									await viewModel.onRefresh()
									refresh.endRefreshing()
								}
							}
                        }, content: {
                            LazyVStack(spacing: 15) {
								if viewModel.rateCardList.unique().isEmpty {
									VStack(spacing: 20) {

										Image.Dinotis.emptyScheduleImage
											.resizable()
											.scaledToFit()
											.frame(height: 137)

										VStack(spacing: 10) {
											Text(LocaleText.emptyRateCardTitle)
												.font(.robotoBold(size: 14))
												.multilineTextAlignment(.center)
												.foregroundColor(.black)

											Text(LocaleText.emptyRateCardSubtitle)
												.font(.robotoRegular(size: 12))
												.multilineTextAlignment(.center)
												.foregroundColor(.black)
										}

										Button {
											viewModel.routeToCreateRateCardForm(isEdit: false, id: "")
										} label: {
											HStack {
												Spacer()

												Text(LocaleText.createRateCard)
													.font(.robotoMedium(size: 12))
													.foregroundColor(.white)

												Spacer()
											}
											.padding()
											.background(
												RoundedRectangle(cornerRadius: 10)
													.foregroundColor(.DinotisDefault.primary)
											)
										}

									}
									.padding(30)
									.background(
										RoundedRectangle(cornerRadius: 12)
											.foregroundColor(.white)
											.shadow(color: .black.opacity(0.1), radius: 15)
									)
									.padding(.vertical)
									.listRowBackground(Color.clear)
								} else {
									ForEach(viewModel.rateCardList.unique(), id: \.self) { item in
										RateHorizontalCardView(
											item: item,
											isTalent: true,
											onTapDelete: {
												viewModel.deleteId = item.id.orEmpty()

												viewModel.isShowDeleteAlert.toggle()
											},
											onTapEdit: {
												viewModel.routeToCreateRateCardForm(isEdit: true, id: item.id.orEmpty())
											}
										)
										.buttonStyle(.plain)
										.onAppear {
											if item.id == viewModel.rateCardList.unique().last?.id {
												viewModel.query.skip = viewModel.query.take
												viewModel.query.take += 15

												Task {
													await viewModel.getRateCardList()
												}
											}
										}
									}

									HStack {
										Spacer()

										ActivityIndicator(
											isAnimating: $viewModel.isLoading,
											color: .black,
											style: .large
										)

										Spacer()
									}
									.isHidden(!viewModel.isLoading, remove: !viewModel.isLoading)
								}
                            }
                            .listRowBackground(Color.clear)
                        }
                    )
                }

                Button(action: {
					viewModel.routeToCreateRateCardForm(isEdit: false, id: "")
                }, label: {
                    Image.Dinotis.plusIcon
                        .resizable()
                        .scaledToFit()
                        .frame(height: 22)
                        .padding()
                        .background(Color.DinotisDefault.primary)
                        .clipShape(Circle())

                })
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
                .padding()
				.alert(isPresented: $viewModel.isShowDeleteAlert) {
					Alert(
						title: Text(LocaleText.attention),
						message: Text(LocaleText.deleteMessageRateCardText),
						primaryButton: .default(Text(LocaleText.noText)),
						secondaryButton: .destructive(Text(LocaleText.yesDeleteText)) {
							withAnimation {
								viewModel.onDeleteCard()
							}
						}
					)
				}
                
				NavigationLink(
					unwrapping: $viewModel.route,
					case: /HomeRouting.talentCreateRateCardForm
				) { viewModel in
					CreateTalentRateCardForm(viewModel: viewModel.wrappedValue)
				} onNavigate: { _ in

				} label: {
					EmptyView()
				}
			}
            
            DinotisLoadingView(.fullscreen, hide: !viewModel.isLoadingDelete)
        }
		.onAppear {
			viewModel.onAppear()
		}
        .navigationBarHidden(true)
        .navigationBarTitle("")
    }
}

extension TalentCardListView {
    struct HeaderView: View {
        @Environment(\.dismiss) var dismiss

        @ObservedObject var viewModel: TalentCardListViewModel

        var body: some View {
            ZStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image.Dinotis.arrowBackIcon
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                    })
                    .padding()

                    Spacer()
                }

                Text(LocaleText.rateCardMenuText)
                    .font(.robotoBold(size: 14))
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: UIScreen.main.bounds.width - 120)
            }
            .background(
                Color.secondaryBackground
            )
			.onDisappear {
				viewModel.rateCardList.removeAll()
			}
        }
    }
}

struct TalentCardListView_Previews: PreviewProvider {
    static var previews: some View {
        TalentCardListView(viewModel: TalentCardListViewModel(backToHome: {}))
    }
}
