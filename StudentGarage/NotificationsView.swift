//
//  NotificationsView.swift
//  StudentGarage
//
//  Created by student on 9/20/24.
//



import SwiftUI

struct NotificationsView: View {
    @Binding var notifications: [String]

    var body: some View {
        NavigationView {
            List(notifications, id: \.self) { notification in
                Text(notification)
            }
            .navigationTitle("Notifications")
        }
    }
}
