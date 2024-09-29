//
//  CalendarScheduleServiceView.swift
//  StudentGarage
//
//  Created by student on 9/20/24.
//



import SwiftUI

struct CalendarScheduleServiceView: View {
    @State private var selectedDate: Date = Date()
    @State private var selectedService: String = ""
    @State private var selectedTime: String = ""
    @Binding var bookedNotifications: [String]
    @State private var bookingError: String? = nil
    @State private var availableTimes: [String] = []
    @State private var showConfirmationAlert = false

    let services = ["Oil Change", "Brake Inspection", "Tire Rotation", "Battery Replacement"]
    let allTimeSlots = ["09:00 AM", "11:00 AM", "01:00 PM", "03:00 PM", "05:00 PM"]

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading) {
                Text("Select Date")
                    .font(.headline)
                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding(.bottom)
            }

            VStack(alignment: .leading) {
                Text("Select Service")
                    .font(.headline)
                Picker("Service", selection: $selectedService) {
                    ForEach(services, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.bottom)
            }

            if !selectedService.isEmpty {
                VStack(alignment: .leading) {
                    Text("Available Times")
                        .font(.headline)
                    Picker("Available Times", selection: $selectedTime) {
                        ForEach(availableTimes, id: \.self) { time in
                            Text(time)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.bottom)
                }
            }

            if let error = bookingError {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }

            Button(action: {
                bookService()
            }) {
                Text("Book Service")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            .alert(isPresented: $showConfirmationAlert) {
                Alert(
                    title: Text("Booking Confirmed"),
                    message: Text("\(selectedService) has been booked for \(selectedTime) on \(formattedDate(selectedDate))."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .padding()
        .onAppear {
            loadAvailableTimes()
            bookedNotifications = BookingModel.loadNotifications()
        }
        .onChange(of: selectedDate) { _ in
            loadAvailableTimes()
        }
    }

    func loadAvailableTimes() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let formattedDate = formatter.string(from: selectedDate)

        let currentServices = loadBookedServices()
        let bookedTimes = currentServices.filter { service in
            service["date"] == formattedDate && service["service"] == selectedService
        }.compactMap { service in
            service["time"]
        }

        availableTimes = allTimeSlots.filter { !bookedTimes.contains($0) }
    }

    func bookService() {
        if selectedService.isEmpty {
            bookingError = "Please select a service."
            return
        }
        if selectedTime.isEmpty {
            bookingError = "Please select a time."
            return
        }

        // Correctly format selectedDate and selectedTime
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let formattedDate = formatter.string(from: selectedDate)
        
        let newService = [
            "service": selectedService,
            "date": formattedDate,
            "time": selectedTime
        ]
        
        var updatedServices = loadBookedServices()
        updatedServices.append(newService)
        
        saveBookedServices(services: updatedServices)

        // Add to notifications with correct time and date
        let notification = "\(selectedService) booked for \(formattedDate) at \(selectedTime)."
        bookedNotifications.append(notification)
        
        saveNotifications(notifications: bookedNotifications)

        // Clear error and show confirmation
        bookingError = nil
        showConfirmationAlert = true
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
func getPlistPath() -> URL {
    let fileManager = FileManager.default
    guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        fatalError("Could not find document directory")
    }
    return documentDirectory.appendingPathComponent("BookedServices.plist")
}
func saveBookedServices(services: [[String: String]]) {
    let plistPath = getPlistPath()
    let plistData = try? PropertyListSerialization.data(fromPropertyList: services, format: .xml, options: 0)
    try? plistData?.write(to: plistPath, options: .atomic)
}
func saveNotifications(notifications: [String]) {
        UserDefaults.standard.set(notifications, forKey: "BookedNotifications")
    }
func loadBookedServices() -> [[String: String]] {
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
