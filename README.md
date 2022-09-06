# SwiftObfuscator

Byte Code Obfuscator for Encrypting Strings
Changes a string literal, adds a decryption extension to the file with the encrypted string.

## Setup:

Just add the package to your project
Or download it separately, you will need to transfer the Obfuscator swift file to your project.

## Usage:

- Right click on the package and select "Show in Finder"
- Right-click on the folder with the "Surf-SwiftObfuscator" package and select "new terminal by folder adress" from the context menu
- In the terminal `swift run SwiftObfuscator [Parameters]`

Parameters:

`-f` or `--file-path <file-path>` Path to the file where you want to obfuscate strings.

`-s` or `--salt <salt>` Salt that the strings should be obfuscated with.

`-l` or `--line <line>` The line number on which strings should be obfuscated. By default, all lines will be obfuscated.


### Example:

 To obfuscate all lines in a file in the terminal that opens, type:

```bash
swift run SwiftObfuscator -f ../MyProject/Tokens.swift -s somesalt
```
If you need to obfuscate a specific string then use:

```bash
swift run SwiftObfuscator -f ../MyProject/Tokens.swift -s somesalt -l 135
```

### File Changes

File before change:

```swift
import UIKit

class ViewController: UIViewController {

    enum Tokens {
        static let value1 = "value1"
        static let value2 = "value2"
        static let value3 = "value3"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("string1", "string2")
    }

}
```

File after change:

```swift
// swiftlint:disable line_length
import Obfuscator

import UIKit

class ViewController: UIViewController {

    enum Tokens {
    // Obfuscated from "value1"
        static let value1 = Obfuscator.default.reveal(key: [7, 22, 9, 7, 20, 70]) ?? ""
    // Obfuscated from "value2"
        static let value2 = Obfuscator.default.reveal(key: [7, 22, 9, 7, 20, 69]) ?? ""
    // Obfuscated from "value3"
        static let value3 = Obfuscator.default.reveal(key: [7, 22, 9, 7, 20, 68]) ?? ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print(Obfuscator.default.reveal(key: [2, 3, 23, 27, 31, 16, 84]) ?? "", Obfuscator.default.reveal(key: [2, 3, 23, 27, 31, 16, 87]) ?? "")
    }

}

fileprivate extension Obfuscator {

    @inline(__always)
    static var `default`: Obfuscator {
        return Obfuscator(withSalt: "qwer")
    }

}
```