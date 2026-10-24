import Testing
@testable import Letterfly

@MainActor
struct AppRouteTests {
    @Test func loadingTakesPrecedenceOverOtherStates() {
        #expect(route(isLoading: true, accepted: false, loggedIn: true, name: "Nazar", pairID: "pair") == .loading)
    }

    @Test func termsMustBeAcceptedBeforeAuthenticationFlow() {
        #expect(route(isLoading: false, accepted: false, loggedIn: false, name: nil, pairID: nil) == .terms)
    }

    @Test func loggedOutUserSeesAuthentication() {
        #expect(route(isLoading: false, accepted: true, loggedIn: false, name: nil, pairID: nil) == .authentication)
    }

    @Test func loggedInUserWithoutNameSeesNameSetup() {
        #expect(route(isLoading: false, accepted: true, loggedIn: true, name: nil, pairID: nil) == .nameSetup)
    }

    @Test func namedUserWithoutPairSeesPairing() {
        #expect(route(isLoading: false, accepted: true, loggedIn: true, name: "Nazar", pairID: nil) == .pairing)
    }

    @Test func pairedNamedUserSeesMainApp() {
        #expect(route(isLoading: false, accepted: true, loggedIn: true, name: "Nazar", pairID: "pair-1") == .main)
    }

    private func route(isLoading: Bool, accepted: Bool, loggedIn: Bool, name: String?, pairID: String?) -> AppRoute {
        AppRoute.resolve(
            isLoadingPairID: isLoading,
            hasAcceptedTerms: accepted,
            isLogged: loggedIn,
            displayName: name,
            pairID: pairID
        )
    }
}
