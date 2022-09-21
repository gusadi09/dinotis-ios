//
//  TalentAddBankAccountView.swift
//  DinotisApp
//
//  Created by Gus Adi on 30/08/21.
//

import SwiftUI
import SwiftKeychainWrapper
import SDWebImageSwiftUI

struct TalentAddBankAccountView: View {
	
	@Binding var dataBank: BankAccount
	
	@State var rekening = ""
	@State var rekeningNamed = ""
	
	@State var isPresentBank = false
	
	@State var selectionBank: Bank?
	
	@State var searchBank = ""
	
	@State var dummyBank = ["Bank 0", "Bank 1", "Bank 2"]
	
	@Environment(\.presentationMode) var presentationMode
	
	@ObservedObject var BankVM = BankViewModel.shared
	
	@State var accessToken: String = KeychainWrapper.standard.string(forKey: "auth.accessToken") ?? ""
	
	@State var refreshToken: String = KeychainWrapper.standard.string(forKey: "auth.refreshToken") ?? ""
	
	@ObservedObject var bankAccVM = BankAccountViewModel.shared
	
	@State var isShowConnection = false
	
	@ObservedObject var usersVM = UsersViewModel.shared
	@Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
	
	private var viewController: UIViewController? {
		self.viewControllerHolder.value
	}
	
	var body: some View {
		ZStack {
			
			ZStack(alignment: .top) {
				Image("user-type-bg")
					.resizable()
					.edgesIgnoringSafeArea(.all)
					.alert(isPresented: $isShowConnection) {
						Alert(
							title: Text(NSLocalizedString("attention", comment: "")),
							message: Text(NSLocalizedString("connection_warning", comment: "")),
							dismissButton: .cancel(Text(NSLocalizedString("return", comment: "")))
						)
					}
				
				VStack(spacing: 0) {
					HStack(alignment: . center) {
						Button(action: {
							presentationMode.wrappedValue.dismiss()
						}, label: {
							Image("ic-chevron-back")
								.padding()
								.background(Color.white)
								.clipShape(Circle())
						})
						.padding(.leading)
						.padding(.trailing, 20)
						
						HStack {
							Text(NSLocalizedString("add_withdrawal_account", comment: ""))
								.font(Font.custom(FontManager.Montserrat.bold, size: 14))
								.foregroundColor(.black)
							
							Spacer()
						}
						.padding()
						
					}
					.padding(.top, 5)
					.alert(isPresented: $BankVM.isRefreshFailed) {
						Alert(
							title: Text(NSLocalizedString("attention", comment: "")),
							message: Text(NSLocalizedString("session_expired", comment: "")),
							dismissButton: .default(Text(NSLocalizedString("return", comment: "")), action: {
								
							}))
					}
					
					VStack(spacing: 15) {
						VStack(alignment: .leading) {
							Text(NSLocalizedString("bank_name", comment: ""))
								.font(Font.custom(FontManager.Montserrat.medium, size: 12))
								.foregroundColor(.black)
								.alert(isPresented: $bankAccVM.isRefreshFailed) {
									Alert(
										title: Text(NSLocalizedString("attention", comment: "")),
										message: Text(NSLocalizedString("session_expired", comment: "")),
										dismissButton: .default(Text(NSLocalizedString("return", comment: "")), action: {
											
										}))
								}
							
							Button(action: {
								isPresentBank.toggle()
							}, label: {
								HStack {
									Text(selectionBank == nil ? NSLocalizedString("select_bank_alt", comment: "") : selectionBank?.name ?? "")
										.font(Font.custom(FontManager.Montserrat.regular, size: 12))
										.foregroundColor(selectionBank == nil ? Color(.systemGray4) : .black)
										.padding(.horizontal)
										.padding(.vertical, 15)
									
									Spacer()
									
									Image("ic-chevron-bottom")
										.resizable()
										.scaledToFit()
										.frame(height: 20)
										.padding(.trailing, 10)
								}
								.overlay(
									RoundedRectangle(cornerRadius: 6)
										.stroke(Color(.systemGray4), lineWidth: 1.0)
								)
							})
						}
						
						VStack(alignment: .leading) {
							Text(NSLocalizedString("account_number", comment: ""))
								.font(Font.custom(FontManager.Montserrat.medium, size: 12))
								.foregroundColor(.black)
							
							TextField(NSLocalizedString("account_number_label", comment: ""), text: $rekening)
								.font(Font.custom(FontManager.Montserrat.regular, size: 12))
								.keyboardType(.numberPad)
								.foregroundColor(.black)
								.accentColor(.black)
								.padding(.horizontal)
								.padding(.vertical, 15)
								.overlay(
									RoundedRectangle(cornerRadius: 6)
										.stroke(Color(.systemGray4), lineWidth: 1.0)
								)
						}
						
						VStack(alignment: .leading) {
							Text(NSLocalizedString("account_owner_name", comment: ""))
								.font(Font.custom(FontManager.Montserrat.medium, size: 12))
								.foregroundColor(.black)
							
							TextField(NSLocalizedString("account_holder_name", comment: ""), text: $rekeningNamed)
								.font(Font.custom(FontManager.Montserrat.regular, size: 12))
								.autocapitalization(.words)
								.disableAutocorrection(true)
								.foregroundColor(.black)
								.accentColor(.black)
								.padding(.horizontal)
								.padding(.vertical, 15)
								.overlay(
									RoundedRectangle(cornerRadius: 6)
										.stroke(Color(.systemGray4), lineWidth: 1.0)
								)
						}
					}
					.padding(.horizontal)
					.padding(.vertical, 25)
					.background(Color.white)
					.cornerRadius(12)
					.padding()
				}
				
				VStack(spacing: 0) {
					Spacer()
					
					Button(action: {
						if bankAccVM.data?.first != nil {
							bankAccVM.updateBankAcc(id: dataBank.id ?? 0, by: AddBankAccount(bankId: selectionBank?.id ?? 0, accountName: rekeningNamed, accountNumber: rekening))
						} else {
							bankAccVM.addBankAcc(bankAcc: AddBankAccount(bankId: selectionBank?.id ?? 0, accountName: rekeningNamed, accountNumber: rekening))
						}
					}, label: {
						HStack {
							Spacer()
							Text(NSLocalizedString("save_account", comment: ""))
								.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
								.foregroundColor(.white)
								.padding(10)
								.padding(.horizontal, 5)
								.padding(.vertical, 5)
							
							Spacer()
						}
						.background(Color("btn-stroke-1"))
						.clipShape(RoundedRectangle(cornerRadius: 8))
					})
					.padding()
					.background(Color.white)
					.valueChanged(value: bankAccVM.isSuccessPut, onChange: { value in
						if value {
							presentationMode.wrappedValue.dismiss()
						}
					})
					.valueChanged(value: bankAccVM.isSuccessPost) { value in
						if value {
							presentationMode.wrappedValue.dismiss()
						}
					}
					.onAppear {
						BankVM.getBank()
						
						bankAccVM.getBankAcc()
						
						if !(dataBank.accountNumber?.isEmpty ?? false) {
							DispatchQueue.main.async {
								self.rekening = self.dataBank.accountNumber ?? ""
								self.rekeningNamed = self.dataBank.accountName ?? ""
								self.selectionBank = self.dataBank.bank
							}
						}
					}
					
					Color.white
						.frame(height: 8)
					
				}
				.edgesIgnoringSafeArea(.all)
				.sheet(isPresented: $isPresentBank) {
					VStack {
						HStack {
							Text(NSLocalizedString("select_bank", comment: ""))
								.font(.custom(FontManager.Montserrat.bold, size: 14))
							
							Spacer()
							Button(action: {
								isPresentBank.toggle()
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
						
						HStack(spacing: 15) {
							Image("ic-magnifying-glass")
							
							TextField(NSLocalizedString("search_bank", comment: ""), text: $searchBank)
								.font(Font.custom(FontManager.Montserrat.regular, size: 12))
								.autocapitalization(.words)
								.disableAutocorrection(true)
								.accentColor(.black)
						}
						.padding()
						.background(Color("bg-profile-text"))
						.cornerRadius(8)
						.overlay(
							RoundedRectangle(cornerRadius: 8)
								.stroke(Color.gray.opacity(0.3), lineWidth: 1.0)
						)
						.padding(.horizontal)
						.padding(.top, 10)
						
						ScrollView(.vertical, showsIndicators: false, content: {
							if let dataBank = BankVM.data {
								ForEach(dataBank.filter({ val in
									searchBank.isEmpty ? true : (val.name ?? "").contains(searchBank)
								}), id: \.id) { items in
									VStack {
										HStack {
											WebImage(url: URL(string: items.iconUrl ?? ""))
												.resizable()
												.customLoopCount(1)
												.playbackRate(2.0)
												.placeholder {
													Image(systemName: "creditcard.fill")
														.foregroundColor(Color(.systemGray3))
														.frame(width: 45, height: 25)
												}
												.indicator(.activity)
												.transition(.fade(duration: 0.5))
												.scaledToFit()
												.frame(height: 14)
											
											Text(items.name ?? "")
												.font(.custom(FontManager.Montserrat.regular, size: 12))
											
											Spacer()
											
											Image(systemName: "chevron.right")
												.resizable()
												.scaledToFit()
												.frame(height: 10)
												.font(.system(size: 15, weight: .bold, design: .rounded))
												.foregroundColor(.black)
										}
										.padding(.vertical, 15)
										
										Divider()
									}
									.padding(.horizontal)
									.contentShape(Rectangle())
									.onTapGesture {
										selectionBank = items
										isPresentBank.toggle()
									}
								}
							}
						})
					}
				}
			}
			
			if bankAccVM.isLoading {
				Color.black.opacity(0.3)
					.edgesIgnoringSafeArea(.all)
				
				VStack(alignment: .center) {
					Spacer()
					ActivityIndicator(isAnimating: $bankAccVM.isLoading, color: .white, style: .medium)
					Spacer()
				}
			}
		}
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
	}
}
