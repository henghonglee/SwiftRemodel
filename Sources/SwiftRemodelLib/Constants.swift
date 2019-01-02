//
//  Constants.swift
//  SwiftSyntax
//
//  Created by Lee Heng Hong on 28/12/18.
//

import Foundation
import SwiftSyntax

// each enum is basically a list of cases with each case potentially
// having multiple values with different types represented in strings
struct EnumData {
  let identifier: String
  let inheritance: TypeInheritanceClauseSyntax?
  let cases:[EnumCaseElementListSyntax]
}

struct RemodelConstants {
  static let enumMatchFileName = "Enum+Match.swift"
}

struct FileWriter: TextOutputStream {
  let outputFileURL: URL
  mutating func write(_ string: String) {
    guard let out = OutputStream(url: outputFileURL, append: true) else {fatalError()}
    out.open()
    out.write(string, maxLength: string.lengthOfBytes(using: .utf8))
    out.close()
  }
}
