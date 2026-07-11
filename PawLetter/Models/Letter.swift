//
//  Letter.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 10.07.2026.
//
import FirebaseFirestore
import Foundation

struct Letter : Codable, Identifiable, Equatable{
    @DocumentID var id: String?
    var authorID: String
    var text: String
    var createdAt: Date
}
