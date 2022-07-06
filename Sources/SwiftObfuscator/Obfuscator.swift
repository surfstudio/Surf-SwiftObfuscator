import Foundation

final class Obfuscator {

    // MARK: - Public Properties

    /// The salt used to obfuscate and reveal the string.
    private var salt: String = ""

    // MARK: - Lifecycle

    @inline(__always)
    init(withSalt salt: String) {
        self.salt = salt
    }

    // MARK: - Public Methods

    #if DEBUG

    /// This method obfuscates the string passed in using the salt
    /// that was used when the Obfuscator was initialized.
    ///
    /// - Parameter string: the string to obfuscate.
    /// - Returns: the obfuscated string in a byte array.
    @inline(__always)
    func bytesByObfuscatingString(string: String) -> [UInt8] {
        let text = [UInt8](string.utf8)
        let cipher = [UInt8](self.salt.utf8)
        let length = cipher.count

        var encrypted = [UInt8]()

        for (index, element) in text.enumerated() {
            encrypted.append(element ^ cipher[index % length])
        }

        return encrypted
    }

    #endif

    /// This method reveals the original string from the obfuscated
    /// byte array passed in. The salt must be the same as the one
    /// used to encrypt it in the first place.
    ///
    /// - Parameter key: the byte array to reveal.
    /// - Returns: the original string.
    @inline(__always)
    func reveal(key: [UInt8]) -> String? {
        let cipher = [UInt8](self.salt.utf8)
        let length = cipher.count

        var decrypted = [UInt8]()

        for (index, element) in key.enumerated() {
            decrypted.append(element ^ cipher[index % length])
        }

        return String(bytes: decrypted, encoding: .utf8)
    }

}
