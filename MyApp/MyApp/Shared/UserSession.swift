import Foundation

final class UserSession: ObservableObject {
    static let shared = UserSession()
    
    @Published var user: User?
}
