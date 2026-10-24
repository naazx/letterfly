import Foundation
import Testing
@testable import Letterfly

struct UserServicesTests {
    @Test func generateRandomCode_hasSixCharacters() {
        #expect(UserServices().generateRandomCode().count == 6)
    }

    @Test func generateRandomCode_usesOnlyLowercaseLettersAndDigits() {
        let allowed = Set("abcdefghijklmnopqrstuvwxyz0123456789")
        let service = UserServices()

        for _ in 0..<100 {
            let code = service.generateRandomCode()
            #expect(code.count == 6)
            #expect(code.allSatisfy { allowed.contains($0) })
        }
    }
}
