import WidgetKit
import SwiftUI

struct MacroTrackerWidgetEntry: TimelineEntry {
    let date: Date
    let kcalRemaining: String
    let carbsProgress: String
    let fatProgress: String
    let proteinProgress: String
    let waterProgress: String
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> MacroTrackerWidgetEntry {
        MacroTrackerWidgetEntry(
            date: Date(),
            kcalRemaining: "1800",
            carbsProgress: "120/300",
            fatProgress: "45/80",
            proteinProgress: "140/180",
            waterProgress: "1.5/3.5L"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (MacroTrackerWidgetEntry) -> ()) {
        let entry = readEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = readEntry()
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func readEntry() -> MacroTrackerWidgetEntry {
        // Reads shared data from the App Group suite name
        let sharedDefaults = UserDefaults(suiteName: "group.com.epsait.macrotracker")
        
        let kcalRemaining = sharedDefaults?.string(forKey: "widget_kcal_remaining") ?? "0"
        let carbsProgress = sharedDefaults?.string(forKey: "widget_carbs_progress") ?? "0/0"
        let fatProgress = sharedDefaults?.string(forKey: "widget_fat_progress") ?? "0/0"
        let proteinProgress = sharedDefaults?.string(forKey: "widget_protein_progress") ?? "0/0"
        let waterProgress = sharedDefaults?.string(forKey: "widget_water_progress") ?? "0.0/0.0L"

        return MacroTrackerWidgetEntry(
            date: Date(),
            kcalRemaining: kcalRemaining,
            carbsProgress: carbsProgress,
            fatProgress: fatProgress,
            proteinProgress: proteinProgress,
            waterProgress: waterProgress
        )
    }
}

struct MacroTrackerWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            // Elegant background matching a dark mode calorie tracker
            Color(red: 0.08, green: 0.09, blue: 0.12)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 8) {
                if family == .systemSmall {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.kcalRemaining)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("kcal restantes")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)
                        
                        Spacer().frame(height: 4)
                        
                        // Small row list for macros
                        MacroRow(name: "Prot", value: entry.proteinProgress, color: .orange)
                        MacroRow(name: "Carb", value: entry.carbsProgress, color: .blue)
                        MacroRow(name: "Gras", value: entry.fatProgress, color: .yellow)
                    }
                    .padding(12)
                } else {
                    // Medium Widget: Left is calories and water, right is detailed progress bars for macros
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.kcalRemaining)
                                .font(.system(size: 38, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("kcal restantes")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                            
                            Spacer().frame(height: 8)
                            
                            HStack(spacing: 6) {
                                Image(systemName: "drop.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 12))
                                Text(entry.waterProgress)
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Divider().background(Color.gray.opacity(0.3))
                        
                        VStack(alignment: .leading, spacing: 8) {
                            MacroBarView(label: "Proteínas", value: entry.proteinProgress, color: .orange)
                            MacroBarView(label: "Carbohidratos", value: entry.carbsProgress, color: .blue)
                            MacroBarView(label: "Grasas", value: entry.fatProgress, color: .yellow)
                        }
                    }
                    .padding(16)
                }
            }
        }
    }
}

struct MacroRow: View {
    let name: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text(name)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(color)
                .frame(width: 25, alignment: .leading)
            Text(value)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

struct MacroBarView: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.gray)
                Spacer()
                Text(value)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            // Visual progress indicator bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 5)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: getPercentWidth(value: value, totalWidth: geometry.size.width), height: 5)
                }
            }
            .frame(height: 5)
        }
    }
    
    private func getPercentWidth(value: String, totalWidth: CGFloat) -> CGFloat {
        let parts = value.components(separatedBy: "/")
        guard parts.count == 2,
              let tracked = Double(parts[0]),
              let goal = Double(parts[1]),
              goal > 0 else {
            return 0
        }
        let percent = min(1.0, tracked / goal)
        return totalWidth * CGFloat(percent)
    }
}

@main
struct MacroTrackerWidget: Widget {
    let kind: String = "MacroTrackerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MacroTrackerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Resumen MacroTracker")
        .description("Muestra el progreso de calorías, macros y agua del día actual.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
