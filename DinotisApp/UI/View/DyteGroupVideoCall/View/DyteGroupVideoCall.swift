//
//  DyteGroupVideoCall.swift
//  DinotisApp
//
//  Created by Gus Adi on 19/06/23.
//

import SwiftUI

struct DyteGroupVideoCall: View {
    
    @ObservedObject var viewModel: DyteGroupVideoCallViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(viewModel.isJoined ? "Joined" : "Leave")
            
            Button {
                viewModel.onJoinRoom()
            } label: {
                Text("Join")
            }

            Button {
                viewModel.onLeaveRoom()
            } label: {
                Text("Leave")
            }
            
            Button {
                viewModel.backToHome()
            } label: {
                Text("Back")
            }
            
            Spacer()
        }
        .navigationTitle(Text(""))
        .navigationBarHidden(true)
    }
}

struct DyteGroupVideoCall_Previews: PreviewProvider {
    static var previews: some View {
        DyteGroupVideoCall(viewModel: DyteGroupVideoCallViewModel(backToRoot: {}, backToHome: {}))
    }
}
