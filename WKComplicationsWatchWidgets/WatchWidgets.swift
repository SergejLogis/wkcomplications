import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {

    var currentEntry: Entry {
        .init(
            date: .now,
            value: WatchManager.shared.currentValue,
            updatedOn: WatchManager.shared.lastUpdateDate
        )
    }

    func placeholder(in context: Context) -> WatchEntry {
        .init(date: .now, value: 0, updatedOn: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (WatchEntry) -> Void) {
        completion(currentEntry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WatchEntry>) -> Void) {
        completion(Timeline(entries: [currentEntry], policy: .never))
    }
}

struct WatchEntry: TimelineEntry {
    let date: Date
    let value: Int
    let updatedOn: Date?
}

struct WatchWidgetsEntryView : View {
    var entry: Provider.Entry

    var formattedLastUpdateTime: String {
        entry.updatedOn?.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute().second().secondFraction(.fractional(3))) ?? "NEVER"
    }

    var body: some View {
        VStack {
            Text("Current value: **\(entry.value)**")
            Text("Last updated at: **\(formattedLastUpdateTime)**")
                .font(.system(size: 10))
        }
    }
}

@main
struct WatchWidgets: Widget {
    let kind: String = "WatchWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WatchWidgetsEntryView(entry: entry)
                .widgetBackground(Color.clear)
        }
    }
}

extension View {
    @ViewBuilder func widgetBackground(_ backgroundView: @autoclosure @escaping () -> some View) -> some View {
        if #available(iOS 17.0, watchOS 10.0, *) {
            containerBackground(for: .widget) {
                backgroundView()
            }
        } else {
            background(backgroundView())
        }
    }
}

#Preview(as: .accessoryRectangular) {
    WatchWidgets()
} timeline: {
    WatchEntry(date: .now, value: 1, updatedOn: .now)
    WatchEntry(date: .now, value: 0, updatedOn: nil)
}
