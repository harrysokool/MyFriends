//
//  FriendContact.swift
//  MyFriends
//
//  Created by harrysocool on 2026-04-04.
//

import Foundation
import SwiftData

@Model
final class FriendContact {
    var name: String
    var phoneNumber: String
    var phoneRegionCode: String?
    var phoneDialingCode: String?
    var isFavorite: Bool?
    var email: String?
    var instagram: String?
    var notes: String?
    var lastInteractedAt: Date?
    var interactionNote: String?
    var createdAt: Date
    var folder: Folder?

    init(
        name: String,
        phoneNumber: String,
        phoneRegionCode: String = PhoneCountry.defaultCountry.regionCode,
        phoneDialingCode: String = PhoneCountry.defaultCountry.dialingCode,
        isFavorite: Bool = false,
        email: String? = nil,
        instagram: String? = nil,
        notes: String? = nil,
        lastInteractedAt: Date? = nil,
        interactionNote: String? = nil,
        createdAt: Date = .now,
        folder: Folder? = nil
    ) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.phoneRegionCode = phoneRegionCode
        self.phoneDialingCode = phoneDialingCode
        self.isFavorite = isFavorite
        self.email = email
        self.instagram = instagram
        self.notes = notes
        self.lastInteractedAt = lastInteractedAt
        self.interactionNote = interactionNote
        self.createdAt = createdAt
        self.folder = folder
    }

    var resolvedPhoneRegionCode: String {
        phoneRegionCode ?? PhoneCountry.defaultCountry.regionCode
    }

    var resolvedPhoneDialingCode: String {
        phoneDialingCode ?? PhoneCountry.defaultCountry.dialingCode
    }

    // Presentation-oriented convenience kept for existing UI call sites.
    var formattedPhoneNumber: String {
        "\(resolvedPhoneDialingCode) \(phoneNumber)"
    }

    var resolvedIsFavorite: Bool {
        isFavorite ?? false
    }

    var folderPath: String? {
        folder?.fullPath
    }
}
