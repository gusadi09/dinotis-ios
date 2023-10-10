//
//  ReviewListViewModel.swift
//  DinotisApp
//
//  Created by Irham Naufal on 06/10/23.
//

import Foundation
import DinotisData

struct DummyReviewModel: Identifiable {
    var id: UUID = .init()
    var title: String
    var description: String
    var review: ReviewSuccessResponse
    var name: String
    var profilePicture: String
}

enum ReviewFilter {
    case latest
    case earliest
    case highest
    case lowest
}

final class ReviewListViewModel: ObservableObject {
    
    @Published var tabSections: [ReviewFilter] = [
        .latest, .earliest, .highest, .lowest
    ]
    @Published var currentSection: ReviewFilter = .latest
    
    @Published var data: [DummyReviewModel] = [
        .init(
            title: "Ngobrol bareng aku yuk!",
            description: "Welcome to another session with me!!! I hope u guys always healthy",
            review: .init(
                id: nil,
                rating: .random(in: 1...5),
                review: "Keren banget kakak yang satu ini, udah cantik terus ramah sekali. Makin cinta deh <3",
                userId: nil,
                talentId: nil,
                meetingId: nil,
                createdAt: .now - 100000,
                updatedAt: .now - 100000,
                tip: 2000
            ),
            name: "Robert Fox",
            profilePicture: "https://i.pinimg.com/236x/ed/0a/7b/ed0a7bdb0ad33dcceccd605e63994726.jpg"
        ),
        .init(
            title: "Ngobrol bareng aku yuk!",
            description: "Welcome to another session with me!!! I hope u guys always healthy",
            review: .init(
                id: nil,
                rating: .random(in: 1...5),
                review: "Keren banget kakak yang satu ini, udah cantik terus ramah sekali. Makin cinta deh <3. Keren banget kakak yang satu ini, udah cantik terus ramah sekali. Makin cinta deh <3. Keren banget kakak yang satu ini, udah cantik terus ramah sekali. Makin cinta deh <3",
                userId: nil,
                talentId: nil,
                meetingId: nil,
                createdAt: .now - 20500,
                updatedAt: .now - 20500,
                tip: nil
            ),
            name: "Robert Fox",
            profilePicture: "https://i.pinimg.com/236x/ed/0a/7b/ed0a7bdb0ad33dcceccd605e63994726.jpg"
        ),
        .init(
            title: "Ngobrol bareng aku yuk!",
            description: "Welcome to another session with me!!! I hope u guys always healthy",
            review: .init(
                id: nil,
                rating: .random(in: 1...5),
                review: nil,
                userId: nil,
                talentId: nil,
                meetingId: nil,
                createdAt: .now - 10500,
                updatedAt: .now - 10500,
                tip: nil
            ),
            name: "Robert Fox",
            profilePicture: "https://i.pinimg.com/236x/ed/0a/7b/ed0a7bdb0ad33dcceccd605e63994726.jpg"
        ),
        .init(
            title: "Ngobrol bareng aku yuk!",
            description: "Welcome to another session with me!!! I hope u guys always healthy",
            review: .init(
                id: nil,
                rating: .random(in: 1...5),
                review: "Keren banget kakak yang satu ini, udah cantik terus ramah sekali. Makin cinta deh <3",
                userId: nil,
                talentId: nil,
                meetingId: nil,
                createdAt: .now - 100000,
                updatedAt: .now - 100000,
                tip: 2000
            ),
            name: "Robert Fox",
            profilePicture: "https://i.pinimg.com/236x/ed/0a/7b/ed0a7bdb0ad33dcceccd605e63994726.jpg"
        ),
        .init(
            title: "Ngobrol bareng aku yuk!",
            description: "Welcome to another session with me!!! I hope u guys always healthy",
            review: .init(
                id: nil,
                rating: .random(in: 1...5),
                review: "Keren banget kakak yang satu ini, udah cantik terus ramah sekali. Makin cinta deh <3. Keren banget kakak yang satu ini, udah cantik terus ramah sekali. Makin cinta deh <3. Keren banget kakak yang satu ini, udah cantik terus ramah sekali. Makin cinta deh <3",
                userId: nil,
                talentId: nil,
                meetingId: nil,
                createdAt: .now - 70500,
                updatedAt: .now - 70500,
                tip: nil
            ),
            name: "Robert Fox",
            profilePicture: "https://i.pinimg.com/236x/ed/0a/7b/ed0a7bdb0ad33dcceccd605e63994726.jpg"
        ),
        .init(
            title: "Ngobrol bareng aku yuk!",
            description: "Welcome to another session with me!!! I hope u guys always healthy",
            review: .init(
                id: nil,
                rating: .random(in: 1...5),
                review: nil,
                userId: nil,
                talentId: nil,
                meetingId: nil,
                createdAt: .now - 10500,
                updatedAt: .now - 10500,
                tip: 50000
            ),
            name: "Robert Fox",
            profilePicture: "https://i.pinimg.com/236x/ed/0a/7b/ed0a7bdb0ad33dcceccd605e63994726.jpg"
        ),
        
    ]
}
