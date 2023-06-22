//
//  GroupVideoCallView.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/06/23.
//

import SwiftUI

struct GroupVideoCallView: View {
    
    @ObservedObject var viewModel: GroupVideoCallViewModel
    
    var body: some View {
        VStack {
            
            Spacer()
            
            Text(viewModel.joined)
            
            Button {
                viewModel.joinMeeting()
            } label: {
                Text("Join Room")
            }
            
            Button {
                viewModel.leaveMeeting()
            } label: {
                Text("Leave Room")
            }

            
            Spacer()
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}

struct GroupVideoCallView_Previews: PreviewProvider {
    static var previews: some View {
        GroupVideoCallView(viewModel: GroupVideoCallViewModel(backToRoot: {}, backToHome: {}))
    }
}
