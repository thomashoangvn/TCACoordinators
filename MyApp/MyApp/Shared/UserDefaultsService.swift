//
//  UserDefaultsService.swift
//  MyApp
//
//  Created by Thomas Hoang on 8/4/25.
//

import Foundation

// MARK: - UserDefaults extensions

public extension UserDefaults {
    
    /// Lưu một đối tượng tuân thủ `Codable` vào UserDefaults.
    ///
    /// - Parameters:
    ///   - object: Đối tượng `Codable` cần lưu.
    ///   - forKey: Khoá để định danh đối tượng.
    /// - Throws: Lỗi nếu không thể mã hoá đối tượng thành JSON.
    func setObject<T: Codable>(object: T, forKey: String) throws {
        
        let jsonData = try JSONEncoder().encode(object)
        
        set(jsonData, forKey: forKey)
    }

    /// Lấy một đối tượng tuân thủ `Codable` từ UserDefaults.
    ///
    /// - Parameters:
    ///   - objectType: Kiểu của đối tượng `Codable` cần lấy.
    ///   - forKey: Khoá đã dùng để lưu đối tượng.
    /// - Returns: Một đối tượng `T?` đã được giải mã, hoặc `nil` nếu không tìm thấy dữ liệu.
    /// - Throws: Lỗi nếu không thể giải mã dữ liệu thành đối tượng.
    func getObject<T: Codable>(objectType: T.Type, forKey: String) throws -> T? {
        
        guard let result = data(forKey: forKey) else {
            return nil
        }
        return try JSONDecoder().decode(objectType, from: result)
    }
    
    /// Lưu một mảng các đối tượng tuân thủ `Codable` vào UserDefaults.
    ///
    /// - Parameters:
    ///   - object: Mảng các đối tượng `Codable` cần lưu.
    ///   - forKey: Khoá để định danh mảng.
    /// - Throws: Lỗi nếu không thể mã hoá mảng thành JSON.
    func setObjects<T: Codable>(object: [T], forKey: String) throws {
        let jsonData = try JSONEncoder().encode(object)
        set(jsonData, forKey: forKey)
    }
    
    func getObjects<T: Codable>(objectType: [T].Type, forKey: String) throws -> [T] {
        
        guard let result = data(forKey: forKey) else {
            return []
        }
        return try JSONDecoder().decode(objectType, from: result)
    }
}

/// Một service để quản lý việc đọc/ghi dữ liệu vào UserDefaults.
/// Service này được thiết kế để tích hợp với hệ thống Dependency của TCA.
struct UserDefaultsService {
    
    // Sử dụng một enum để quản lý các key một cách an toàn, tránh lỗi chính tả.
    private enum Key {
        static let isNotFirstLaunchApp = "is_not_first_launch_app"
        static let isTutorialCompleted = "is_tutorial_completed"
        static let appLanguage = "app_language"
        static let isNotificationOn = "is_notification_on"
    }
    
    private let userDefaults: UserDefaults

    // Cho phép khởi tạo với một instance UserDefaults cụ thể, hữu ích cho testing.
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    /// Cờ đánh dấu đây có phải là lần đầu tiên người dùng mở ứng dụng hay không.
    /// Mặc định là `false` (tức là lần đầu). Sau lần chạy đầu tiên, nên được set thành `true`.
    var isNotFirstLaunchApp: Bool {
        get { userDefaults.bool(forKey: Key.isNotFirstLaunchApp) }
        set { userDefaults.set(newValue, forKey: Key.isNotFirstLaunchApp) }
    }
    
    /// Cờ đánh dấu người dùng đã hoàn thành phần hướng dẫn (tutorial) hay chưa.
    /// Mặc định là `false`.
    var isTutorialCompleted: Bool {
        get { userDefaults.bool(forKey: Key.isTutorialCompleted) }
        set { userDefaults.set(newValue, forKey: Key.isTutorialCompleted) }
    }
    
    var appLanguage: String? {
        get { userDefaults.string(forKey: Key.appLanguage) }
        set {
            if let newValue = newValue {
                userDefaults.set(newValue, forKey: Key.appLanguage)
            } else {
                userDefaults.removeObject(forKey: Key.appLanguage)
            }
        }
    }
    
    var isNotificationOn: Bool {
        get { userDefaults.bool(forKey: Key.isNotificationOn) }
        set { userDefaults.set(newValue, forKey: Key.isNotificationOn) }
    }
}
