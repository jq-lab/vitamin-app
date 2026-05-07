import Foundation

protocol AppGateServicing {
    func resolveGate(profile: UserProfile?, dataSource: DataSourceAuthorization?) -> AppGateState
    func resolveGate(profile: UserProfile?, context: OnboardingContext?) -> AppGateState
}

protocol OnboardingServicing {
    func complete(profile: UserProfile, context: OnboardingContext, completedAt: Date) -> OnboardingContext
    func complete(draft: OnboardingDraft, completedAt: Date) -> OnboardingCompletion
}

protocol TodayStateServicing {
    func makeTodayState(day: Date, signals: [HealthSignal], cycle: CycleContext?, intention: DailyIntention?) -> TodayState
}

protocol EnergyRitualServicing {
    func openingState(day: Date, hasCompletedOrSkipped: Bool) -> DailyOpeningState
    func finish(day: Date, summary: EnergySummary?) -> EnergyRitualResult
}

protocol TodayAnalysisServicing {
    func makeAnalysis(day: Date, state: TodayState, summary: EnergySummary) -> TodayAnalysis
    func makeOptionSet(day: Date, summary: EnergySummary) -> ABOptionSet
}

protocol DailyIntentionServicing {
    func select(day: Date, choice: DailyIntention.Choice, optionSetID: UUID?) -> DailyIntention
}

protocol LunaHomeServicing {
    func context(today: TodayState?, intention: DailyIntention?, review: EveningReview?) -> String
}

protocol LunaRecordServicing {
    func draft(text: String, quickType: LunaRecordQuickType) -> LunaRecord
    func confirm(record: LunaRecord, summary: String) -> ParsedUnderstanding
}

protocol LunaChatServicing {
    func append(message: LunaConversationMessage, to messages: [LunaConversationMessage]) -> [LunaConversationMessage]
    func openingMessages(homeState: LunaHomeState, recentRecord: ParsedUnderstanding?) -> [LunaConversationMessage]
    func userMessage(text: String) -> LunaConversationMessage?
    func responseDraft(messages: [LunaConversationMessage], context: AIContextPackage, capability: AppCapabilityState) -> LunaResponseDraft
    func lunaMessage(from draft: LunaResponseDraft) -> LunaConversationMessage?
}

protocol EveningReviewServicing {
    func availability(
        day: Date,
        intention: DailyIntention?,
        morningSummary: String,
        suggestionSummary: String
    ) -> EveningReview
    func submit(
        day: Date,
        intentionID: UUID?,
        before: String,
        feedback: EveningReviewFeedback,
        note: String?
    ) -> EveningReview
}

protocol CycleServicing {
    func entry(for date: Date, context: CycleContext) -> CycleCalendarEntry
}

protocol NutritionServicing {
    func upsert(entry: NutritionEntry, into entries: [NutritionEntry]) -> [NutritionEntry]
    func remove(id: UUID, from entries: [NutritionEntry]) -> [NutritionEntry]
    func quickEntry(name: String, contextSummary: String) -> NutritionEntry
}

protocol SupportServicing {
    func visibleItems() -> [SupportItem]
    func panelState(selectedRoute: SupportRoute?) -> SupportPanelState
    func dataSourceSummary(for authorization: DataSourceAuthorization) -> DataSourceSummary
}

protocol DataExportServicing {
    func requestExport() -> DataExportRequest
    func beginConfirmation(_ request: DataExportRequest) -> DataExportRequest
    func prepare(_ request: DataExportRequest, exportItems: [ExportItem]) -> DataExportPackage
    func complete(_ request: DataExportRequest) -> DataExportRequest
    func cancel(_ request: DataExportRequest) -> DataExportRequest
}

protocol AccountRemovalServicing {
    func requestRemoval() -> AccountRemovalRequest
    func beginConfirmation(_ request: AccountRemovalRequest) -> AccountRemovalRequest
    func complete(_ request: AccountRemovalRequest, persistence: PersistenceClient) throws -> AccountRemovalResult
    func cancel(_ request: AccountRemovalRequest) -> AccountRemovalRequest
}

protocol AIContextServicing {
    func buildContext(job: AIJob, today: TodayState?, record: ParsedUnderstanding?) -> AIContextPackage
}
