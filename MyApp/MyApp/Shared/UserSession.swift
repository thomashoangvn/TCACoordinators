import Foundation
import Security

final class UserSession: ObservableObject {
    static let shared = UserSession()
    
    @Published var user: User? {
        didSet {
            // Bất cứ khi nào `user` thay đổi, chúng ta sẽ lưu nó vào Keychain.
            if let user = user {
                saveUserToKeychain(user)
            } else {
                // Nếu người dùng đăng xuất (user = nil), xoá khỏi Keychain.
                deleteUserFromKeychain()
            }
        }
    }

    // Các hằng số để định danh mục của chúng ta trong Keychain.
    private let userAccount = "currentUser"
    private let service: String

    private init() {
        // Lấy bundle identifier để tạo một service key duy nhất.
        self.service = Bundle.main.bundleIdentifier ?? "com.myapp.usersession"
        // Khi UserSession được khởi tạo, hãy thử tải người dùng từ Keychain.
        self.user = loadUserFromKeychain()
    }
    
    private func saveUserToKeychain(_ user: User) {
        do {
            // 1. Mã hoá đối tượng User thành Data.
            let data = try JSONEncoder().encode(user)
            
            // 2. Tạo một query để lưu vào Keychain.
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: userAccount,
                kSecAttrService as String: service,
                kSecValueData as String: data
            ]
            
            // 3. Xoá mục hiện có trước khi thêm mục mới để tránh lỗi trùng lặp.
            SecItemDelete(query as CFDictionary)
            
            // 4. Thêm mục mới vào Keychain.
            let status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                print("Error saving user to keychain: \(status)")
            }
        } catch {
            print("Error encoding user for keychain: \(error)")
        }
    }
    
    private func loadUserFromKeychain() -> User? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: userAccount,
            kSecAttrService as String: service,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess, let data = dataTypeRef as? Data else {
            // errSecItemNotFound là bình thường nếu chưa có người dùng nào được lưu.
            if status != errSecItemNotFound {
                print("Error loading user from keychain: \(status)")
            }
            return nil
        }
        
        // Giải mã dữ liệu trở lại thành đối tượng User.
        return try? JSONDecoder().decode(User.self, from: data)
    }
    
    private func deleteUserFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: userAccount,
            kSecAttrService as String: service
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
