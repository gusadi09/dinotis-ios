//
//  AfterFeedback.swift
//  DinotisApp
//
//  Created by mora hakim on 15/08/23.
//

import SwiftUI

struct AfterFeedback: View {
    var body: some View {
        ZStack {
            Image.thanksForFeedbackIcon
                .resizable()
                .frame(width: 430, height: 935)
                .ignoresSafeArea(.all)
            }
    }
}

struct AfterFeedback_Previews: PreviewProvider {
    static var previews: some View {
        AfterFeedback()
    }
}
