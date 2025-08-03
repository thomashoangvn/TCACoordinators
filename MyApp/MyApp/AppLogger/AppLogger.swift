//
//  AppLogger.swift
//  TCAProductionsCart
//
//  Created by Thomas Hoang on 7/4/25.
//

import Foundation
import OSLog
import Dependencies

// --- TẠO MỘT DEPENDENCY MỚI CHO VIỆC PHÂN TÍCH ---
struct AnalyticsClient {
    var track: (String, String, String) -> Void
}

extension AnalyticsClient: DependencyKey {
    // Trong thực tế, bạn sẽ tích hợp Firebase, Sentry, etc. ở đây
    static let liveValue = Self(track: { action, stateBefore, stateAfter in
        // Ở đây bạn có thể gửi dữ liệu tới một dịch vụ analytics thực tế
        // Ví dụ: Analytics.logEvent(action, parameters: ["state_before": stateBefore, "state_after": stateAfter])
        print("✅ ANALYTICS (LIVE): Event tracked: \(action)")
        print("State Before:\n\(stateBefore)")
        print("State After:\n\(stateAfter)")
    })
    
    static let testValue = Self(track: { _, _, _ in })
}

extension DependencyValues {
    var analyticsClient: AnalyticsClient {
        get { self[AnalyticsClient.self] }
        set { self[AnalyticsClient.self] = newValue }
    }
}

// Định nghĩa AppLogger với các closure cho từng cấp độ log
struct AppLogger {
    var debug: (String) -> Void
    var info: (String) -> Void
    var error: (String) -> Void
    var track: (String, String, String) -> Void // <-- THÊM HÀM TRACK
}

extension AppLogger: DependencyKey {
    // --- Phiên bản "live" ---
    static let liveValue: Self = {
        // THÊM VÀO: Khai báo logger của OSLog để có thể sử dụng bên dưới
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "TCA")

        return Self(
            // VIẾT LẠI CÁC CLOSURE Ở ĐÂY
            debug: { message in
                #if DEBUG
                logger.debug("\(message)")
                #endif
            },
            info: { message in
                #if DEBUG
                logger.info("\(message)")
                #endif
            },
            error: { message in
                #if DEBUG
                logger.error("\(message)")
                #endif
            },
            // Sử dụng AnalyticsClient cho việc track
            track: { action, stateBefore, stateAfter in
                // Chỉ gửi tracking khi không ở chế độ DEBUG để tránh nhiễu
                // Hoặc bạn có thể cấu hình để gửi cả DEBUG nếu muốn
                @Dependency(\.analyticsClient) var client
                client.track(action, stateBefore, stateAfter)
            }
        )
    }()
    
    // --- Phiên bản "test" (không làm gì cả) ---
    static let testValue = Self(
        debug: { _ in },
        info: { _ in },
        error: { _ in },
        track: { _, _, _ in }
    )
    
    // --- Phiên bản "preview" (in ra console) ---
    static let previewValue = Self(
        debug: { print("DEBUG: \($0)") },
        info: { print("INFO: \($0)") },
        error: { print("ERROR: \($0)") },
        track: { action, stateBefore, stateAfter in
            print("TRACK: \(action)")
            print("State Before:\n\(stateBefore)")
            print("State After:\n\(stateAfter)")
        }
    )
}

// Thêm key vào DependencyValues
extension DependencyValues {
    var appLogger: AppLogger {
        get { self[AppLogger.self] }
        set { self[AppLogger.self] = newValue }
    }
}
       
