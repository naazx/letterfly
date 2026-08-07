//
//  SortOption.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 07.08.2026.
//

import Foundation
enum SortOption: String, CaseIterable{
    case name
    case dateSent
    
    var title: String {
        switch self {
        case .name:
            return "Name"
        case .dateSent:
            return "Date Sent"
        }
    }
}
