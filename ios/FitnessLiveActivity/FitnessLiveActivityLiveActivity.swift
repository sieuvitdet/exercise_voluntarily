//
//  FitnessLiveActivityLiveActivity.swift
//  FitnessLiveActivity
//
//  Created for Fitness On U App
//

import ActivityKit
import WidgetKit
import SwiftUI

// Shared UserDefaults with App Group
let sharedDefault = UserDefaults(suiteName: "group.ductran.ftel.fitness.onu")!

// IMPORTANT: This struct name MUST be "LiveActivitiesAppAttributes" for the live_activities package
struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState

    public struct ContentState: Codable, Hashable { }

    var id = UUID()
}

extension LiveActivitiesAppAttributes {
    func prefixedKey(_ key: String) -> String {
        return "\(id)_\(key)"
    }
}

struct FitnessLiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            // Read data from UserDefaults
            let elapsedSeconds = sharedDefault.integer(forKey: context.attributes.prefixedKey("elapsedSeconds"))
            let isOnBreak = sharedDefault.bool(forKey: context.attributes.prefixedKey("isOnBreak"))

            // Lock screen/banner UI
            LockScreenView(
                elapsedSeconds: elapsedSeconds,
                isOnBreak: isOnBreak
            )
        } dynamicIsland: { context in
            // Read data from UserDefaults
            let elapsedSeconds = sharedDefault.integer(forKey: context.attributes.prefixedKey("elapsedSeconds"))
            let isOnBreak = sharedDefault.bool(forKey: context.attributes.prefixedKey("isOnBreak"))

            return DynamicIsland {
                // Expanded Dynamic Island
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "figure.run")
                            .foregroundColor(isOnBreak ? .orange : .green)
                        Text(isOnBreak ? "Break" : "Active")
                            .font(.caption)
                            .foregroundColor(isOnBreak ? .orange : .green)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(formatTime(elapsedSeconds))
                        .font(.title2)
                        .fontWeight(.bold)
                        .monospacedDigit()
                }
                DynamicIslandExpandedRegion(.center) {
                    Text("Workout")
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 20) {
                        // Break/Resume Button
                        Link(destination: URL(string: "ftelfitness://action?type=\(isOnBreak ? "resume" : "break")")!) {
                            HStack {
                                Image(systemName: isOnBreak ? "play.fill" : "pause.fill")
                                Text(isOnBreak ? "Resume" : "Break")
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(isOnBreak ? Color.green : Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }

                        // Complete Button
                        Link(destination: URL(string: "ftelfitness://action?type=complete")!) {
                            HStack {
                                Image(systemName: "checkmark")
                                Text("Complete")
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                }
            } compactLeading: {
                Image(systemName: "figure.run")
                    .foregroundColor(isOnBreak ? .orange : .green)
            } compactTrailing: {
                Text(formatTime(elapsedSeconds))
                    .monospacedDigit()
                    .fontWeight(.semibold)
            } minimal: {
                Image(systemName: "figure.run")
                    .foregroundColor(isOnBreak ? .orange : .green)
            }
            .widgetURL(URL(string: "ftelfitness://open"))
            .keylineTint(isOnBreak ? .orange : .green)
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

// Lock Screen View
struct LockScreenView: View {
    let elapsedSeconds: Int
    let isOnBreak: Bool

    var body: some View {
        HStack {
            // Left side - Icon and Status
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "figure.run")
                        .font(.title2)
                        .foregroundColor(isOnBreak ? .orange : .green)
                    Text("Workout")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                Text(isOnBreak ? "On Break" : "Active")
                    .font(.caption)
                    .foregroundColor(isOnBreak ? .orange : .green)
            }

            Spacer()

            // Right side - Timer
            Text(formatTime(elapsedSeconds))
                .font(.system(size: 36, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
        }
        .padding()
        .activityBackgroundTint(Color(red: 0.12, green: 0.24, blue: 0.45).opacity(0.9))
        .activitySystemActionForegroundColor(.white)
    }

    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
