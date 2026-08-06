//
//  Font+Handwriting.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 06.08.2026.
//

import Foundation
import SwiftUI

extension Font {
    static func handwriting(size: CGFloat, enabled: Bool) -> Font {
        enabled ? .custom("Caveat-Regular", size: size) : .system(size: size)
    }
    static func handwritingBold(size: CGFloat) -> Font {
        .custom("Caveat-Bold", size: size)
    }
}
