//
//  Pair.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 21.07.2026.
//
import FirebaseFirestore
import Foundation

struct Pair : Codable{
    @DocumentID var id: String?
    var members: [String]
    var startDate: Date
}
