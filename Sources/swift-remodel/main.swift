//
//  main.swift
//  Files
//
//  Created by Lee Heng Hong on 29/12/18.
//

import Foundation
import SwiftSyntax
import SwiftRemodelLib

@available(OSX 10.11, *)
func main()
{
  let tool = CommandLineTool.init(arguments: CommandLine.arguments)
  try! tool.run()
}

if #available(OSX 10.11, *) {
  main()
} else {
  // Fallback on earlier versions
  fatalError("Only supporting OSX 10.11 and above")
}
