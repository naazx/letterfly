//
//  SurpriseType.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 18.08.2026.
//

import Foundation

enum SurpriseType: String, CaseIterable, Codable, ChipDisplayable {
    case flower
    case chocolate
    case coffee
    case teddyBear
    case handwrittenNote
    case loveLetter
    case breakfast
    case iceCream
    case pizza
    case movieNight
    case picnic
    case candle
    case plushie
    case book
    case playlist
    case photo
    case starGazing
    case sunset
    case favoriteSnack
    case donut
    case cupcake
    case tea
    case hotChocolate
    case bubbleTea
    case bracelet
    case keychain
    case stickerPack
    case surpriseDate
    case smallGift
    case goodieBox

    var title: String {
        switch self {
        case .flower:
            return "Flower"
        case .chocolate:
            return "Chocolate"
        case .coffee:
            return "Coffee"
        case .teddyBear:
            return "Teddy Bear"
        case .handwrittenNote:
            return "Handwritten Note"
        case .loveLetter:
            return "Love Letter"
        case .breakfast:
            return "Breakfast"
        case .iceCream:
            return "Ice Cream"
        case .pizza:
            return "Pizza"
        case .movieNight:
            return "Movie Night"
        case .picnic:
            return "Picnic"
        case .candle:
            return "Candle"
        case .plushie:
            return "Plushie"
        case .book:
            return "Book"
        case .playlist:
            return "Playlist"
        case .photo:
            return "Photo"
        case .starGazing:
            return "Star Gazing"
        case .sunset:
            return "Sunset"
        case .favoriteSnack:
            return "Favorite Snack"
        case .donut:
            return "Donut"
        case .cupcake:
            return "Cupcake"
        case .tea:
            return "Tea"
        case .hotChocolate:
            return "Hot Chocolate"
        case .bubbleTea:
            return "Bubble Tea"
        case .bracelet:
            return "Bracelet"
        case .keychain:
            return "Keychain"
        case .stickerPack:
            return "Sticker Pack"
        case .surpriseDate:
            return "Surprise Date"
        case .smallGift:
            return "Small Gift"
        case .goodieBox:
            return "Goodie Box"
        }
    }

    var emoji: String {
        switch self {
        case .flower:
            return "🌹"
        case .chocolate:
            return "🍫"
        case .coffee:
            return "☕️"
        case .teddyBear:
            return "🧸"
        case .handwrittenNote:
            return "💌"
        case .loveLetter:
            return "💖"
        case .breakfast:
            return "🥞"
        case .iceCream:
            return "🍦"
        case .pizza:
            return "🍕"
        case .movieNight:
            return "🎬"
        case .picnic:
            return "🧺"
        case .candle:
            return "🕯️"
        case .plushie:
            return "🐻"
        case .book:
            return "📖"
        case .playlist:
            return "🎵"
        case .photo:
            return "📸"
        case .starGazing:
            return "🌟"
        case .sunset:
            return "🌅"
        case .favoriteSnack:
            return "🍿"
        case .donut:
            return "🍩"
        case .cupcake:
            return "🧁"
        case .tea:
            return "🍵"
        case .hotChocolate:
            return "☕️"
        case .bubbleTea:
            return "🧋"
        case .bracelet:
            return "📿"
        case .keychain:
            return "🔑"
        case .stickerPack:
            return "✨"
        case .surpriseDate:
            return "💑"
        case .smallGift:
            return "🎁"
        case .goodieBox:
            return "📦"
        }
    }
}
