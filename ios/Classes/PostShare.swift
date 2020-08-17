//
//  PostShare.swift
//  FacebookCore
//
//  Created by Faiyyaz Khatri on 02/12/19.
//

import Foundation

// MARK: - PostShare
struct PostShare: Codable {
    let phoneNumber, message, type: String

    enum CodingKeys: String, CodingKey {
        case phoneNumber = "phoneNumber"
        case message = "message"
        case type = "type"
    }
}
