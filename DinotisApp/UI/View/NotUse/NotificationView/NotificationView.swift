//
//  NotificationView.swift
//  DinotisApp
//
//  Created by Gus Adi on 04/08/21.
//

import SwiftUI

struct Contoh {
    var id = UUID()
    var isRead: Bool
}

struct NotificationView: View {
    @State var isRead = false
    var dummy = [Contoh(isRead: false),
                 Contoh(isRead: true),
                 Contoh(isRead: true),
                 Contoh(isRead: true)
    ]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                ZStack {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Image("ic-chevron-back")
                                .padding()
                        })
                        .padding(.leading)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        Text("Notifikasi")
                            .font(Font.custom(FontManager.Montserrat.bold, size: 14))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                }
                .padding(.top, 10)
                .background(Color(.white))
                
                ScrollView(.vertical, showsIndicators: false, content: {
                    VStack(spacing: 0) {
                        ForEach(dummy, id: \.id) { items in
                            VStack(spacing: 0) {
                                NotificationCell(isRead: items.isRead)
                            }
                        }
                    }
                })
            }
        }
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
