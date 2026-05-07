import CryptoKit
import Foundation

enum DomainModelID: String, CaseIterable, Codable, Equatable {
    case dm001 = "DM-001"
    case dm002 = "DM-002"
    case dm003 = "DM-003"
    case dm004 = "DM-004"
    case dm005 = "DM-005"
    case dm006 = "DM-006"
    case dm007 = "DM-007"
    case dm008 = "DM-008"
    case dm009 = "DM-009"
    case dm010 = "DM-010"
    case dm011 = "DM-011"
    case dm012 = "DM-012"
    case dm013 = "DM-013"
    case dm014 = "DM-014"
    case dm015 = "DM-015"
    case dm016 = "DM-016"
    case dm017 = "DM-017"
    case dm018 = "DM-018"
    case dm019 = "DM-019"
    case dm020 = "DM-020"
    case dm021 = "DM-021"
    case dm022 = "DM-022"
    case dm023 = "DM-023"
    case dm024 = "DM-024"
    case dm025 = "DM-025"
}

enum DataClass: String, Codable, Equatable {
    case dc00 = "DC-00"
    case dc01 = "DC-01"
    case dc02 = "DC-02"
    case dc03 = "DC-03"
    case dc04 = "DC-04"
    case dc05 = "DC-05"

    var requiresEncryptedStorage: Bool {
        switch self {
        case .dc02, .dc03:
            true
        case .dc00, .dc01, .dc04, .dc05:
            false
        }
    }

    var isTransientByDefault: Bool {
        self == .dc05
    }
}

struct StoredRecord: Codable, Equatable {
    var id: UUID
    var modelID: DomainModelID
    var dataClass: DataClass
    var encrypted: Bool
    var payload: Data
    var savedAt: Date
}

struct ExportItem: Codable, Equatable {
    var id: UUID
    var modelID: DomainModelID
    var dataClass: DataClass
}

enum PersistenceError: Error, Equatable {
    case transientDataNotPersisted
    case missingKey
}

protocol PersistenceClient {
    func save<Model: Codable>(_ model: Model, id: UUID, modelID: DomainModelID, dataClass: DataClass) throws
    func load<Model: Codable>(_ type: Model.Type, id: UUID, modelID: DomainModelID) throws -> Model?
    func exportSnapshot() -> [ExportItem]
    func removeAccountData() throws -> AppGateState
}

final class InMemoryPersistenceClient: PersistenceClient {
    private var storage: [String: StoredRecord] = [:]
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let keyStore: SecureKeyStoring
    private let keyIdentifier = "vitora.local.database"

    init(keyStore: SecureKeyStoring = InMemorySecureKeyStore()) {
        self.keyStore = keyStore
    }

    func save<Model: Codable>(_ model: Model, id: UUID, modelID: DomainModelID, dataClass: DataClass) throws {
        if dataClass.isTransientByDefault {
            throw PersistenceError.transientDataNotPersisted
        }

        let rawPayload = try encoder.encode(model)
        let shouldEncrypt = dataClass.requiresEncryptedStorage
        let payload = shouldEncrypt ? try protected(rawPayload) : rawPayload
        storage[key(id: id, modelID: modelID)] = StoredRecord(
            id: id,
            modelID: modelID,
            dataClass: dataClass,
            encrypted: shouldEncrypt,
            payload: payload,
            savedAt: .now
        )
    }

    func load<Model: Codable>(_ type: Model.Type, id: UUID, modelID: DomainModelID) throws -> Model? {
        guard let record = storage[key(id: id, modelID: modelID)] else {
            return nil
        }
        let payload = record.encrypted ? try unprotected(record.payload) : record.payload
        return try decoder.decode(type, from: payload)
    }

    func exportSnapshot() -> [ExportItem] {
        storage.values
            .filter { $0.dataClass != .dc00 && $0.dataClass != .dc05 }
            .map { ExportItem(id: $0.id, modelID: $0.modelID, dataClass: $0.dataClass) }
            .sorted { $0.modelID.rawValue < $1.modelID.rawValue }
    }

    func removeAccountData() throws -> AppGateState {
        storage.removeAll()
        try keyStore.clearKey(identifier: keyIdentifier)
        return .needsOnboarding
    }

    func storedRecord(id: UUID, modelID: DomainModelID) -> StoredRecord? {
        storage[key(id: id, modelID: modelID)]
    }

    private func key(id: UUID, modelID: DomainModelID) -> String {
        "\(modelID.rawValue):\(id.uuidString)"
    }

    private func protected(_ data: Data) throws -> Data {
        let key = try keyStore.loadOrCreateKey(identifier: keyIdentifier)
        guard !key.isEmpty else {
            throw PersistenceError.missingKey
        }
        let sealedBox = try AES.GCM.seal(data, using: SymmetricKey(data: key))
        return sealedBox.combined ?? Data()
    }

    private func unprotected(_ data: Data) throws -> Data {
        let key = try keyStore.loadOrCreateKey(identifier: keyIdentifier)
        guard !key.isEmpty else {
            throw PersistenceError.missingKey
        }
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: SymmetricKey(data: key))
    }
}
