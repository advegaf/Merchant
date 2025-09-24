
import Foundation
import SwiftUI
import UIKit

@Observable
public final class UserProfileStore {
    public static let shared = UserProfileStore()
    private init() { load() }

    private let key = "user_profile_v2"
    private let imageKey = "user_profile_image_v2"

    public var displayName: String = "Angel"
    public var profileImage: UIImage? = nil

    public func save() {
        UserDefaults.standard.set(["displayName": displayName], forKey: key)
        if let image = profileImage,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: imageKey)
        } else {
            UserDefaults.standard.removeObject(forKey: imageKey)
        }
    }

    private func load() {
        if let dict = UserDefaults.standard.dictionary(forKey: key), let name = dict["displayName"] as? String {
            displayName = name
        }

        if let imageData = UserDefaults.standard.data(forKey: imageKey),
           let image = UIImage(data: imageData) {
            profileImage = image
        }
    }

    public func clearProfileImage() {
        profileImage = nil
        save()
    }
}


