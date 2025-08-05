//
//  StringLocalized.swift
//  MyApp
//
//  Created by Thomas Hoang on 8/5/25.
//


import Foundation

class LanguageHelper {
    
    var currentLanguageCode: String = "en"
    
    static let shared = LanguageHelper()
    private init(){
        checkLanguage()
    }
    
    func checkLanguage() {
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        print("Current Language: \(currentLanguage)")
        self.currentLanguageCode = currentLanguage
    }
    
    static var currentLanguage: LanguageSupport {
        var language: LanguageSupport = .en
        return language
    }
    
    var currentLanguage: LanguageSupport {
        var language: LanguageSupport = .en
        if let lang = LanguageSupport(rawValue: currentLanguageCode) {
            language = lang
        }
        return language
    }
}

enum LanguageSupport: String, Hashable, CaseIterable {
    case en = "en"
    case none = "none"
    
    var language: String {
        return self.rawValue
    }
    
    var apiLanguage: String {
        switch self {
        case .en:
            return "en"
        default:
            return "en"
        }
    }
    
    var titleLanguage: String {
        switch self {
        case .en:
            return "English"
        default:
            return "Auto".localized
        }
    }
}

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

struct StringLocalized: Codable {
    var en: String?
    
    enum CodingKeys: String, CodingKey {
        case en = "en"
    }
    
    init(){}
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        en = try? values.decodeIfPresent(String.self, forKey: .en) ?? nil
    }
    var localized: String? {
        get {
            switch LanguageHelper.shared.currentLanguage {
            case .en:
                return en
                
            default:
                return en
            }
        }
    }
    var english: String? {
        get {
            return en
        }
    }
    var isEmpty: Bool {
        (en ?? "").isEmpty
    }
    func isEqual(with localizedString: String) -> Bool {
        if localizedString == en {
            return true
        }
        return false
    }
}
