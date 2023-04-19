//
//  EmptySchedule.swift
//  DinotisApp
//
//  Created by hilmy ghozy on 20/04/22.
//

import Foundation
import SwiftUI
import DinotisDesignSystem

struct EmptySchedule: View {
    
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 10) {
                Image("empty-schedule-img")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        minWidth: 0,
                        idealWidth: 203,
                        maxWidth: 203,
                        minHeight: 0,
                        idealHeight: 137,
                        maxHeight: 137,
                        alignment: .center
                    )

                Text(NSLocalizedString("no_schedule_label", comment: ""))
                    .font(.robotoBold(size: 14))
                    .foregroundColor(.black)

                Text(NSLocalizedString("talent_detail_empty_label", comment: ""))
                    .font(.robotoRegular(size: 12))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
        .shadow(color: Color("dinotis-shadow-1").opacity(0.1), radius: 20, x: 0.0, y: 0.0)
        .padding(.top, 30)
    }
    
}
