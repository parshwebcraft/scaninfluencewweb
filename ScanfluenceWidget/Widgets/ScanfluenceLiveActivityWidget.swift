import ActivityKit
import SwiftUI
import WidgetKit

struct ScanfluenceLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ScanfluenceActivityAttributes.self) { context in
            LockScreenLiveActivityView(context: context)
                .activityBackgroundTint(.black.opacity(0.86))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    IslandAvatarView(contact: context.attributes.contact, size: 58)
                }

                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(context.attributes.contact.name)
                            .font(.headline.weight(.semibold))
                            .lineLimit(1)

                        Text(context.attributes.contact.designation)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    StatusBadgeView(state: context.state)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedProgressView(context: context)
                }
            } compactLeading: {
                IslandAvatarView(contact: context.attributes.contact, size: 26)
            } compactTrailing: {
                Image(systemName: context.state.phase == .saved ? "checkmark.circle.fill" : "arrow.triangle.2.circlepath.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(context.state.phase == .saved ? .teal : .white)
            } minimal: {
                Image(systemName: context.state.phase == .saved ? "checkmark" : "person.crop.circle.badge.plus")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.teal)
            }
            .widgetURL(URL(string: "scanfluence://contact/sarah-chen"))
            .keylineTint(.teal)
        }
    }
}

private struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<ScanfluenceActivityAttributes>

    var body: some View {
        HStack(spacing: 16) {
            IslandAvatarView(contact: context.attributes.contact, size: 58)

            VStack(alignment: .leading, spacing: 5) {
                Text(context.attributes.contact.name)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)

                Text("\(context.attributes.contact.designation) at \(context.attributes.contact.company)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.64))
                    .lineLimit(1)

                ProgressView(value: context.state.progress)
                    .tint(.teal)
                    .padding(.top, 4)
            }

            Spacer(minLength: 8)

            StatusBadgeView(state: context.state)
        }
        .padding(4)
        .widgetURL(URL(string: "scanfluence://contact/sarah-chen"))
    }
}

private struct ExpandedProgressView: View {
    let context: ActivityViewContext<ScanfluenceActivityAttributes>

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(context.state.statusText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)

                Spacer()

                Text(context.attributes.contact.company)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.12))

                    Capsule()
                        .fill(.teal)
                        .frame(width: max(18, proxy.size.width * context.state.progress))
                        .shadow(color: .teal.opacity(0.8), radius: context.state.phase == .saved ? 10 : 4)
                }
            }
            .frame(height: 6)
        }
        .padding(.top, 2)
    }
}

private struct StatusBadgeView: View {
    let state: ScanfluenceActivityAttributes.ContentState

    var body: some View {
        ZStack {
            Circle()
                .fill(state.phase == .saved ? .teal.opacity(0.22) : .white.opacity(0.12))
                .frame(width: 42, height: 42)

            Image(systemName: state.phase == .saved ? "checkmark" : "plus")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(state.phase == .saved ? .teal : .white)
        }
        .contentTransition(.symbolEffect(.replace))
    }
}
