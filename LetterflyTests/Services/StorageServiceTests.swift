import Foundation
import Testing
@testable import Letterfly

@MainActor
struct StorageServiceTests {
    @Test func uploadFile_rejectsDataLargerThanFiveMegabytesBeforeNetworkAccess() async {
        let service = StorageService()
        let oversizedData = Data(count: 5 * 1024 * 1024 + 1)

        await #expect(throws: StorageError.self) {
            try await service.uploadFile(data: oversizedData, path: "avatars/test.jpg")
        }
    }
}
