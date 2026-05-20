import ActivityKit
import Foundation

@MainActor
final class LiveActivityManager: ObservableObject {
    @Published private(set) var isRunning = false

    private var currentActivity: Activity<ScanfluenceActivityAttributes>?

    func startScanActivity(for contact: ContactProfile) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            isRunning = false
            return
        }

        let attributes = ScanfluenceActivityAttributes(contact: contact)
        let initialState = ScanfluenceActivityAttributes.ContentState(
            phase: .saving,
            progress: 0.22,
            statusText: "Saving Contact",
            updatedAt: .now
        )

        do {
            // ActivityKit owns the system surface after this request. The app only sends
            // compact state updates, and the widget extension decides how to render them.
            currentActivity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: initialState, staleDate: nil),
                pushType: nil
            )
            isRunning = true

            try? await Task.sleep(for: .milliseconds(850))
            await updateActivity(progress: 0.72, text: "Adding Connection", phase: .saving)

            try? await Task.sleep(for: .milliseconds(900))
            await updateActivity(progress: 1.0, text: contact.status, phase: .saved)
        } catch {
            isRunning = false
            print("Unable to start Scanfluence Live Activity: \(error.localizedDescription)")
        }
    }

    func endActivity() async {
        guard let currentActivity else { return }

        let finalState = ScanfluenceActivityAttributes.ContentState(
            phase: .saved,
            progress: 1,
            statusText: MockProfileStore.featuredContact.status,
            updatedAt: .now
        )

        await currentActivity.end(
            ActivityContent(state: finalState, staleDate: nil),
            dismissalPolicy: .after(.now + 6)
        )
        self.currentActivity = nil
        isRunning = false
    }

    private func updateActivity(
        progress: Double,
        text: String,
        phase: ScanfluenceActivityAttributes.ContentState.SavePhase
    ) async {
        guard let currentActivity else { return }

        let state = ScanfluenceActivityAttributes.ContentState(
            phase: phase,
            progress: progress,
            statusText: text,
            updatedAt: .now
        )

        await currentActivity.update(ActivityContent(state: state, staleDate: nil))
    }
}
