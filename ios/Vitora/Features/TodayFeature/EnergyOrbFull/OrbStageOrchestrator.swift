import Foundation

enum OrbStage: Int, CaseIterable, Comparable {
    case opening = 0
    case sleep = 1
    case heartRate = 2
    case hrv = 3
    case composite = 4
    case confetti = 5
    case cardReveal = 6

    static func < (lhs: OrbStage, rhs: OrbStage) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct OrbTimeline {

    // MARK: - Full version (first open today): 14s total

    static let fullStages: [(stage: OrbStage, start: Double, end: Double)] = [
        (.opening,    0.0,   1.5),
        (.sleep,      1.5,   4.0),
        (.heartRate,  4.0,   6.5),
        (.hrv,        6.5,   9.0),
        (.composite,  9.0,  12.0),
        (.confetti,  12.0,  14.5),
        (.cardReveal,14.0,  15.5),
    ]

    // MARK: - Brief version (subsequent opens): ~8s total
    // Skips sleep/heartRate/hrv, jumps opening → composite

    static let briefStages: [(stage: OrbStage, start: Double, end: Double)] = [
        (.opening,    0.0,  1.5),
        (.composite,  1.5,  4.5),
        (.confetti,   4.5,  7.0),
        (.cardReveal, 6.5,  8.0),
    ]

    static func stages(isFullVersion: Bool) -> [(stage: OrbStage, start: Double, end: Double)] {
        isFullVersion ? fullStages : briefStages
    }

    static func stage(at elapsed: Double, isFullVersion: Bool) -> OrbStage {
        let timeline = stages(isFullVersion: isFullVersion)
        for entry in timeline.reversed() {
            if elapsed >= entry.start {
                return entry.stage
            }
        }
        return .opening
    }

    static func stageProgress(at elapsed: Double, stage: OrbStage, isFullVersion: Bool) -> Double {
        let timeline = stages(isFullVersion: isFullVersion)
        guard let entry = timeline.first(where: { $0.stage == stage }) else { return 0 }
        let duration = entry.end - entry.start
        guard duration > 0 else { return 0 }
        let progress = (elapsed - entry.start) / duration
        return min(max(progress, 0), 1)
    }

    static func totalDuration(isFullVersion: Bool) -> Double {
        let timeline = stages(isFullVersion: isFullVersion)
        return timeline.map(\.end).max() ?? 15.5
    }

    static func hasReached(stage: OrbStage, at elapsed: Double, isFullVersion: Bool) -> Bool {
        let timeline = stages(isFullVersion: isFullVersion)
        guard let entry = timeline.first(where: { $0.stage == stage }) else { return false }
        return elapsed >= entry.start
    }

    static func isComplete(at elapsed: Double, isFullVersion: Bool) -> Bool {
        elapsed >= totalDuration(isFullVersion: isFullVersion)
    }
}

// MARK: - Easing Helpers

func easeIn(_ value: Double) -> Double {
    value * value
}

func easeOut(_ value: Double) -> Double {
    1 - (1 - value) * (1 - value)
}

func easeInOut(_ value: Double) -> Double {
    value < 0.5 ? 2 * value * value : 1 - pow(-2 * value + 2, 2) / 2
}

func springBounce(_ value: Double, damping: Double = 14, stiffness: Double = 120) -> Double {
    let decay = exp(-damping * value * 0.1)
    let oscillation = cos(stiffness * value * 0.05)
    return 1 - decay * oscillation * (1 - value)
}
