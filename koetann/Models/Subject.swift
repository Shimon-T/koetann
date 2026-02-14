//
//  Subject.swift
//  koetann
//
//  Created by 田中志門 on 2/1/26.
//

enum Subject: String, Codable, CaseIterable {
    case english = "英語"
    case japanese = "国語"
    case math = "数学"
    case science = "理科"
    case social = "社会"
    case other = "その他"
}

extension Subject {
    var displayName: String {
        switch self {
        case .english: return "英語"
        case .japanese: return "国語"
        case .math: return "数学"
        case .science: return "理科"
        case .social: return "社会"
        case .other: return "その他"
        }
    }
}
