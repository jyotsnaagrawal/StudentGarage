//
//  BookingModel.swift
//  StudentGarage
//
//  Created by student on 9/20/24.
//



import Foundation

struct BookingModel {
    static func getPlistPath() -> URL {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Could not find document directory")
        }
        return documentDirectory.appendingPathComponent("BookedServices.plist")
    }

    static func saveBookedServices(services: [[String: String]]) {
        let plistPath = getPlistPath()
        let plistData = try? PropertyListSerialization.data(fromPropertyList: services, format: .xml, options: 0)
        try? plistData?.write(to: plistPath, options: .atomic)
    }

    static func loadBookedServices() -> [[String: String]] {
        let fileManager = FileManager.default
        let fileURL = getPlistPath()

        if let data = try? Data(contentsOf: fileURL) {
            do {
                if let services = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [[String: String]] {
                    return services
                }
            } catch {
                print("Error loading plist: \(error)")
            }
        }
        return []
    }

    static func saveNotifications(notifications: [String]) {
        UserDefaults.standard.set(notifications, forKey: "BookedNotifications")
    }

    static func loadNotifications() -> [String] {
        UserDefaults.standard.stringArray(forKey: "BookedNotifications") ?? []
    }
}
