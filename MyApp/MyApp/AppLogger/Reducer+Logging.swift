//
//  Reducer+Logging.swift
//  TCAProductionsCart
//
//  Created by Thomas Hoang on 8/4/25.
//  Updated on 8/5/25.
//

import Foundation
import ComposableArchitecture
import CustomDump // Cần import để sử dụng `diff`

/// Một reducer "bọc" một reducer khác để ghi log lại các thay đổi của state.
/// Yêu cầu `State` phải tuân thủ `Equatable`.
private struct ObservingReducer<Base: Reducer>: Reducer where Base.State: Equatable {
    let base: Base
    let logger: AppLogger

    func reduce(into state: inout Base.State, action: Base.Action) -> Effect<Base.Action> {
        // TODO: Cân nhắc chỉ bật logger này trong môi trường DEBUG để tránh ảnh hưởng hiệu năng ở Production.
        // Ví dụ: #if DEBUG ... #endif

        let stateBefore = state
        let effects = self.base.reduce(into: &state, action: action)
        let stateAfter = state

        // Chỉ ghi log nếu state thực sự có thay đổi để tránh nhiễu.
        if stateBefore != stateAfter {
            // Trích xuất tên action
            let actionName = String(describing: action).extractedActionName

            // Chuyển đổi state sang dạng chuỗi để ghi log.
            // Sử dụng `customDump` để có output đẹp và chi tiết.
            let beforeStateDescription = String(customDumping: stateBefore)
            let afterStateDescription = String(customDumping: stateAfter)

            self.logger.track(
                "Action: \(actionName)",
                beforeStateDescription,
                afterStateDescription
            )
        }

        return effects
    }
}

extension Reducer where State: Equatable {
    /// Bọc reducer hiện tại trong một logic khác để ghi log các action và sự thay đổi của state.
    ///
    /// Logic này so sánh state trước và sau khi một action được xử lý. Nếu có sự thay đổi,
    /// nó sẽ ghi lại action và một bản `diff` chi tiết về sự thay đổi của state.
    ///
    /// - Parameter logger: `AppLogger` để thực hiện việc ghi log.
    /// - Returns: Một reducer mới với khả năng ghi log.
    func observe(using logger: AppLogger) -> some Reducer<State, Action> {
        ObservingReducer(base: self, logger: logger)
    }
}



extension String {
    /// Tự động trích xuất tên action cụ thể nhất từ chuỗi mô tả của một action trong TCA.
    /// Logic này được thiết kế để hoạt động với các action lồng nhau từ `Scope` và `ForEach`.
    var extractedActionName: String {
        // Xử lý trường hợp action của `ForEach` (IdentifiedAction), có dạng "...action: .specificAction)".
        if let actionRange = self.range(of: "action: ", options: .backwards) {
            var substring = self[actionRange.upperBound...]
            while substring.hasSuffix(")") {
                substring.removeLast()
            }
            return String(substring)
        }

        // Đối với các action khác (đơn giản hoặc scope), trả về chuỗi gốc.
        return self
    }
}
