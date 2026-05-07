import Foundation

protocol DomainRepository {
    associatedtype Model: Codable & Equatable & Identifiable where Model.ID == UUID

    var modelID: DomainModelID { get }
    var dataClass: DataClass { get }

    func save(_ model: Model) throws
    func load(id: UUID) throws -> Model?
}

final class InMemoryDomainRepository<Model: Codable & Equatable & Identifiable>: DomainRepository where Model.ID == UUID {
    let modelID: DomainModelID
    let dataClass: DataClass
    private let persistence: PersistenceClient

    init(modelID: DomainModelID, dataClass: DataClass, persistence: PersistenceClient) {
        self.modelID = modelID
        self.dataClass = dataClass
        self.persistence = persistence
    }

    func save(_ model: Model) throws {
        try persistence.save(model, id: model.id, modelID: modelID, dataClass: dataClass)
    }

    func load(id: UUID) throws -> Model? {
        try persistence.load(Model.self, id: id, modelID: modelID)
    }
}

struct RepositoryRegistry {
    let userProfiles: InMemoryDomainRepository<UserProfile>
    let onboardingContexts: InMemoryDomainRepository<OnboardingContext>
    let dataSourceAuthorizations: InMemoryDomainRepository<DataSourceAuthorization>
    let healthSignals: InMemoryDomainRepository<HealthSignal>
    let cycleContexts: InMemoryDomainRepository<CycleContext>
    let lunaRecords: InMemoryDomainRepository<LunaRecord>
    let parsedUnderstandings: InMemoryDomainRepository<ParsedUnderstanding>
    let nutritionEntries: InMemoryDomainRepository<NutritionEntry>
    let dailyIntentions: InMemoryDomainRepository<DailyIntention>
    let reminderPreferences: InMemoryDomainRepository<ReminderPreference>
    let reminderInstances: InMemoryDomainRepository<ReminderInstance>
    let eveningReviews: InMemoryDomainRepository<EveningReview>
    let vitoraLearningSignals: InMemoryDomainRepository<VitoraLearningSignal>
    let conversationMessages: InMemoryDomainRepository<LunaConversationMessage>
    let dataExportRequests: InMemoryDomainRepository<DataExportRequest>
    let accountRemovalRequests: InMemoryDomainRepository<AccountRemovalRequest>

    static func makeDefault(persistence: PersistenceClient = InMemoryPersistenceClient()) -> RepositoryRegistry {
        RepositoryRegistry(
            userProfiles: .init(modelID: .dm001, dataClass: .dc01, persistence: persistence),
            onboardingContexts: .init(modelID: .dm002, dataClass: .dc01, persistence: persistence),
            dataSourceAuthorizations: .init(modelID: .dm004, dataClass: .dc04, persistence: persistence),
            healthSignals: .init(modelID: .dm005, dataClass: .dc02, persistence: persistence),
            cycleContexts: .init(modelID: .dm006, dataClass: .dc02, persistence: persistence),
            lunaRecords: .init(modelID: .dm008, dataClass: .dc02, persistence: persistence),
            parsedUnderstandings: .init(modelID: .dm009, dataClass: .dc03, persistence: persistence),
            nutritionEntries: .init(modelID: .dm010, dataClass: .dc02, persistence: persistence),
            dailyIntentions: .init(modelID: .dm016, dataClass: .dc03, persistence: persistence),
            reminderPreferences: .init(modelID: .dm017, dataClass: .dc01, persistence: persistence),
            reminderInstances: .init(modelID: .dm018, dataClass: .dc04, persistence: persistence),
            eveningReviews: .init(modelID: .dm019, dataClass: .dc03, persistence: persistence),
            vitoraLearningSignals: .init(modelID: .dm020, dataClass: .dc03, persistence: persistence),
            conversationMessages: .init(modelID: .dm021, dataClass: .dc03, persistence: persistence),
            dataExportRequests: .init(modelID: .dm024, dataClass: .dc04, persistence: persistence),
            accountRemovalRequests: .init(modelID: .dm025, dataClass: .dc04, persistence: persistence)
        )
    }
}
