import Foundation

struct DailyIntentionCommitment: Equatable {
    var intention: DailyIntention
    var reminder: ReminderInstance?

    var makesReviewReachable: Bool {
        intention.canOpenEveningReview
    }
}

struct DailyIntentionService: DailyIntentionServicing {
    var now: () -> Date = Date.init

    func select(day: Date, choice: DailyIntention.Choice, optionSetID: UUID?) -> DailyIntention {
        switch choice {
        case .a, .b:
            DailyIntention(day: day, choice: choice, state: .active, optionSetID: optionSetID, selectedAt: now())
        case .notSuitable:
            reject(day: day, optionSetID: optionSetID)
        case .dismissed:
            DailyIntention(day: day, choice: .dismissed, state: .dismissed, optionSetID: optionSetID, selectedAt: now())
        }
    }

    func select(option: ABOptionSet.Option, from optionSet: ABOptionSet, day: Date? = nil) -> DailyIntention {
        let choice: DailyIntention.Choice = option.label == .a ? .a : .b
        return select(day: day ?? optionSet.day, choice: choice, optionSetID: optionSet.id)
    }

    func reject(day: Date, optionSetID: UUID?) -> DailyIntention {
        DailyIntention(day: day, choice: .notSuitable, state: .rejected, optionSetID: optionSetID, selectedAt: now())
    }

    func commit(
        option: ABOptionSet.Option,
        from optionSet: ABOptionSet,
        preference: ReminderPreference,
        scheduler: NotificationScheduling,
        day: Date? = nil
    ) -> DailyIntentionCommitment {
        let intention = select(option: option, from: optionSet, day: day)
        let reminder = scheduler.scheduleIntentionReminder(for: intention, preference: preference, day: day ?? optionSet.day)
        return DailyIntentionCommitment(intention: intention, reminder: reminder)
    }
}
