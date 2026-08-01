//
//  ChipPicker.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 01.08.2026.
//

import SwiftUI

struct ChipPicker<T: CaseIterable & Hashable & ChipDisplayable>: View {
    @Binding var selection: T?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack{
                ForEach(Array(T.allCases), id: \.self) { option in
                    HStack(spacing: 4){
                        Text(option.emoji)
                        Text(option.title)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .foregroundStyle(selection == option ? .white : .primary)
                    .background(selection == option ? Color.accentColor : Color(.secondarySystemBackground))
                    .clipShape(Capsule())
                    .onTapGesture {
                        if selection == option {
                            selection = nil
                        } else {
                            selection = option
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ChipPicker<MoodType>(selection: .constant(.happy))
}
