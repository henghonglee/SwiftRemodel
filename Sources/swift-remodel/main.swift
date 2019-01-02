//
//  main.swift
//  Files
//
//  Created by Lee Heng Hong on 29/12/18.
//

import Foundation
import SwiftSyntax
import SwiftRemodelLib

func main()
{
  let tool = CommandLineTool.init(arguments: CommandLine.arguments)
  try! tool.run()
}

main()
