import Foundation
import Security

protocol SecureKeyStoring {
    func loadOrCreateKey(identifier: String) throws -> Data
    func clearKey(identifier: String) throws
}

enum KeyStoreError: Error, Equatable {
    case unexpectedStatus(OSStatus)
    case invalidStoredValue
}

final class KeychainKeyStore: SecureKeyStoring {
    func loadOrCreateKey(identifier: String) throws -> Data {
        if let existing = try loadKey(identifier: identifier) {
            return existing
        }

        var bytes = [UInt8](repeating: 0, count: 32)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        guard status == errSecSuccess else {
            throw KeyStoreError.unexpectedStatus(status)
        }

        let key = Data(bytes)
        try saveKey(key, identifier: identifier)
        return key
    }

    func clearKey(identifier: String) throws {
        let query = baseQuery(identifier: identifier)
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeyStoreError.unexpectedStatus(status)
        }
    }

    private func loadKey(identifier: String) throws -> Data? {
        var query = baseQuery(identifier: identifier)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess else {
            throw KeyStoreError.unexpectedStatus(status)
        }
        guard let data = result as? Data else {
            throw KeyStoreError.invalidStoredValue
        }
        return data
    }

    private func saveKey(_ key: Data, identifier: String) throws {
        var query = baseQuery(identifier: identifier)
        query[kSecValueData as String] = key
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeyStoreError.unexpectedStatus(status)
        }
    }

    private func baseQuery(identifier: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.vitora.local-key",
            kSecAttrAccount as String: identifier,
        ]
    }
}

final class InMemorySecureKeyStore: SecureKeyStoring {
    private var keys: [String: Data] = [:]

    func loadOrCreateKey(identifier: String) throws -> Data {
        if let existing = keys[identifier] {
            return existing
        }
        let key = Data(repeating: 7, count: 32)
        keys[identifier] = key
        return key
    }

    func clearKey(identifier: String) throws {
        keys[identifier] = nil
    }

    var isEmpty: Bool {
        keys.isEmpty
    }
}
