//
//  NotificationCell.swift
//  DinotisApp
//
//  Created by Gus Adi on 04/08/21.
//

import SwiftUI

struct NotificationCell: View {
    @State var isRead: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack {
                    Image("ic-notif-badge")
                }
                
                VStack(alignment: .leading) {
                    Text("Ada yang mau video call nih!")
                        .font(Font.custom(FontManager.Montserrat.bold, size: 14))
                        .foregroundColor(.black)
                        .padding(.bottom, 1)
                    
                    Text("Asik, sepertinya fansmu sudah ngga sabar mau ngobrol bareng kamu. Cek di sini!")
                        .font(Font.custom(FontManager.Montserrat.regular, size: 12))
                        .foregroundColor(.black)
                        .kerning(1)
                }
                .padding(.horizontal)
            }
            .padding()
            
            Divider()
                .padding(.horizontal)
        }
        .edgesIgnoringSafeArea(.all)
        .background(isRead ? Color(.white) : Color("notif-color"))
        .onTapGesture(perform: {
            isRead.toggle()
        })
    }
}

struct NotificationCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            NotificationCell(isRead: true)
            NotificationCell(isRead: false)
        }
    }
}
