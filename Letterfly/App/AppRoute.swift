import Foundation

enum AppRoute: Equatable {
    case loading
    case terms
    case authentication
    case nameSetup
    case pairing
    case main

    static func resolve(
        isLoadingPairID: Bool,
        hasAcceptedTerms: Bool,
        isLogged: Bool,
        displayName: String?,
        pairID: String?
    ) -> AppRoute {
        if isLoadingPairID { return .loading }
        if !hasAcceptedTerms { return .terms }
        if !isLogged { return .authentication }
        if displayName == nil { return .nameSetup }
        if pairID == nil { return .pairing }
        return .main
    }
}
