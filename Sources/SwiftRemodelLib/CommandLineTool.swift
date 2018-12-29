//
//  CommandLineTool.swift
//  Files
//
//  Created by Lee Heng Hong on 29/12/18.
//

import Foundation
import SwiftSyntax

public final class CommandLineTool {
  private let arguments: [String]
  
  public init(arguments: [String] = CommandLine.arguments) {
    self.arguments = arguments
  }
  
  public func run() throws {
    guard arguments.count > 0 else {
      throw Error.missingRootDirectory
    }
    // root directory to generate the new file, also searches all swift files starting from here
    let rootDirectoryUrl = URL(fileURLWithPath: arguments[0])
    
    let contents = try! FileManager.default.contentsOfDirectory(at: rootDirectoryUrl,
                                                                includingPropertiesForKeys: nil,
                                                                options: [.skipsHiddenFiles])
    
    var swiftFileUrls = contents.recFlatMap(contents)
    
    let factory = EnumMatchFactory()
    swiftFileUrls = factory.setUp(swiftFileUrls)
    
    for (index, swiftFile) in swiftFileUrls.enumerated() {
      print("\(index)/\(swiftFileUrls.count) files")
      let sourceFile = try! SyntaxTreeParser.parse(swiftFile)
      factory.visit(sourceFile)
    }
    factory.createEnumMatchFile(rootDirectoryUrl)
  }
}

public extension CommandLineTool {
  enum Error: Swift.Error {
    case missingRootDirectory
  }
}
