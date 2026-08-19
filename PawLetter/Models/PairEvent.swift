//
//  PairEvent.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 19.08.2026.
//

import Foundation
import FirebaseFirestore

struct PairEvent: Codable, Identifiable, Hashable, Equatable {
    @DocumentID var id: String?
    var title: String
    var date: Date
    var isRecurring: Bool
    var createdBy: String
}
