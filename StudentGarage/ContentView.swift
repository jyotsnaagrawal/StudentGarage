//
//  ContentView.swift
//  StudentGarage
//
//  Created by student on 9/20/24.
//

import SwiftUI

struct ContentView: View {
    @State private var bookedNotifications: [String] = []

    var body: some View {
        TabView {
            CalendarScheduleServiceView(bookedNotifications: $bookedNotifications)
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }

            NotificationsView(notifications: $bookedNotifications)
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }
        }
    }
}
