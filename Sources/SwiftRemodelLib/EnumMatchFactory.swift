//
//  EnumMatchFactory.swift
//  SwiftSyntax
//
//  Created by Lee Heng Hong on 28/12/18.
//
import SwiftSyntax
import Foundation

// TODO: Hash digest for checking

class EnumMatchFactory: SyntaxRewriter {
  var enumDatas = [String:EnumData]()
  
  func setUp(_ swiftFileUrls: [URL]) -> [URL] {
    let enumMatchPaths = swiftFileUrls.filter { return $0.lastPathComponent.contains(RemodelConstants.enumMatchFileName) }
    for enumMatchPath in enumMatchPaths {
      try! FileManager.default.removeItem(atPath: enumMatchPath.path)
    }
    return swiftFileUrls.filter { return !$0.lastPathComponent.contains(RemodelConstants.enumMatchFileName) }
  }
  
  override func visit(_ node: EnumDeclSyntax) -> DeclSyntax {
    var inheritanceQueue = [String]()
    inheritanceQueue.insert(node.identifier.text, at: 0)
    var n:Syntax = node
    while let parent = n.parent {
      if parent is StructDeclSyntax {
        let structDecl = parent as! StructDeclSyntax
        inheritanceQueue.insert(structDecl.identifier.text, at: 0)
      }
      if parent is ClassDeclSyntax {
        let classDecl = parent as! ClassDeclSyntax
        inheritanceQueue.insert(classDecl.identifier.text, at: 0)
      }
      if parent is EnumDeclSyntax {
        let enumDecl = parent as! EnumDeclSyntax
        inheritanceQueue.insert(enumDecl.identifier.text, at: 0)
      }
      n = parent
    }
    let identifierWithInheritance = inheritanceQueue.joined(separator: ".")
    let enumData = EnumData(identifier: identifierWithInheritance, inheritance: node.inheritanceClause, cases:
      node.members.members.compactMap { (decl) -> EnumCaseElementListSyntax? in
        if decl is EnumCaseDeclSyntax {
          let caseDecl = decl as! EnumCaseDeclSyntax
          return caseDecl.elements
        }
        return nil
    })
    enumDatas[enumData.identifier] = enumData
    return super.visit(node)
  }
  
  func createEnumMatchFile(_ rootDirectoryUrl: URL) {
    var decls = [CodeBlockItemSyntax]()
    for enumData in enumDatas.values.sorted(by: { (data1, data2) -> Bool in
      return data1.identifier < data2.identifier
    }) {
      let extensionKeyword = SyntaxFactory.makeExtensionKeyword(leadingTrivia: .zero, trailingTrivia: .spaces(1))
      let identifier = SyntaxFactory.makeTypeIdentifier(enumData.identifier, leadingTrivia: .zero, trailingTrivia: .spaces(1))
      
      let leftBrace = SyntaxFactory.makeLeftBraceToken(leadingTrivia: .zero, trailingTrivia: .newlines(1))
      let rightBrace = SyntaxFactory.makeRightBraceToken(leadingTrivia: .newlines(1), trailingTrivia: .newlines(1))
      let funcLeftBrace = SyntaxFactory.makeLeftBraceToken(leadingTrivia: .spaces(1), trailingTrivia: .newlines(1))
      let funcRightBrace = SyntaxFactory.makeRightBraceToken(leadingTrivia: .spaces(2), trailingTrivia: .zero)
      let switchLeftBrace = SyntaxFactory.makeLeftBraceToken(leadingTrivia: .zero, trailingTrivia: .newlines(1))
      let switchRightBrace = SyntaxFactory.makeRightBraceToken(leadingTrivia: .spaces(4), trailingTrivia: .newlines(1))
      
      let matchFunc = SyntaxFactory.makeFuncKeyword(leadingTrivia: .spaces(2), trailingTrivia: .spaces(1))
      
      let commaToken = SyntaxFactory.makeToken(TokenKind.comma,
                                               presence: SourcePresence.present,
                                               leadingTrivia: .zero,
                                               trailingTrivia: .spaces(1))
      let colonToken = SyntaxFactory.makeToken(TokenKind.colon, presence: SourcePresence.present)
      
      var funcParams = [FunctionParameterSyntax]()
      var switchCases = [SwitchCaseSyntax]()
      var index = 0
      let maxIndex = enumData.cases.reduce(0) { (result, list) -> Int in return result + list.endIndex }
      for caseElementList in enumData.cases {
        var iter = caseElementList.makeIterator()
        while let caseElement = iter.next() {
          var typesString = ""
          if let associatedTypes = caseElement.associatedValue {
            typesString = associatedTypes.parameterList.compactMap { return $0.type?.description }.joined(separator: ", ")
          }
          
          let typeToken = SyntaxFactory.makeTypeIdentifier("(\(typesString))->Void", leadingTrivia: .zero, trailingTrivia: .zero)
          let nameToken = SyntaxFactory.makeIdentifier(caseElement.identifier.text)
          let funcParam = SyntaxFactory.makeFunctionParameter(attributes: nil,
                                                              firstName: nil,
                                                              secondName: nameToken,
                                                              colon: colonToken,
                                                              type: typeToken,
                                                              ellipsis: nil,
                                                              defaultArgument: nil,
                                                              trailingComma: index != (maxIndex - 1) ? commaToken : nil)
          funcParams.append(funcParam)
          
          
          // Switch
          
          let optionName = caseElement.identifier.text
          var fields = [String]()
          if let associatedTypes = caseElement.associatedValue {
            fields.removeAll()
            let values = associatedTypes.parameterList.compactMap { return $0.type?.description }
            for (index, _) in values.enumerated() {
              fields.append("param\(index)")
            }
          }
          var fieldName = fields.map{ return "let " + $0 }.joined(separator: ", ")
          if fieldName.count > 0 {
            fieldName = "(" + fieldName + ")"
          }
          let caseExpr = IdentifierExprSyntax { builder in
            builder.useIdentifier(SyntaxFactory.makeIdentifier(" .\(optionName)\(fieldName)"))
          }
          
          let exprPattern = ExpressionPatternSyntax { builder in
            builder.useExpression(caseExpr)
          }
          let caseItem = SyntaxFactory.makeCaseItem(pattern: exprPattern, whereClause: nil, trailingComma: nil)
          
          let switchCaseLabel = SyntaxFactory.makeSwitchCaseLabel(caseKeyword: SyntaxFactory.makeCaseKeyword(leadingTrivia: .spaces(4), trailingTrivia: .zero), caseItems: SyntaxFactory.makeCaseItemList([caseItem]), colon: SyntaxFactory.makeColonToken(leadingTrivia: .zero, trailingTrivia: .newlines(1)))
          
          let identifierCodeBlockItem = SyntaxFactory.makeCodeBlockItem(item: SyntaxFactory.makeIdentifier("\(optionName)(\(fields.joined(separator: ", ")))", leadingTrivia: .spaces(6), trailingTrivia: .newlines(1)), semicolon: nil)
          let itemList = SyntaxFactory.makeCodeBlockItemList([identifierCodeBlockItem])
          
          let switchCase = SyntaxFactory.makeSwitchCase(unknownAttr: nil, label: switchCaseLabel, statements: itemList)
          
          switchCases.append(switchCase)
          
          index = index + 1
        }
        
      }
      let funcParamList = SyntaxFactory.makeFunctionParameterList(funcParams)
      let paramClause = SyntaxFactory.makeParameterClause(leftParen: SyntaxFactory.makeLeftParenToken(),
                                                          parameterList: funcParamList,
                                                          rightParen: SyntaxFactory.makeRightParenToken())
      let matchFuncSignature = SyntaxFactory.makeFunctionSignature(input: paramClause, throwsOrRethrowsKeyword: nil, output: nil)
      
      
      
      let expr = IdentifierExprSyntax { builder in
        builder.useIdentifier(SyntaxFactory.makeSelfKeyword(leadingTrivia: .zero, trailingTrivia: .spaces(1)))
      }
      let switchStatement = SyntaxFactory.makeSwitchStmt(labelName: nil,
                                                         labelColon: nil,
                                                         switchKeyword: SyntaxFactory.makeSwitchKeyword(leadingTrivia: .spaces(4), trailingTrivia: .spaces(1)),
                                                         expression: expr,
                                                         leftBrace: switchLeftBrace,
                                                         cases: SyntaxFactory.makeSwitchCaseList(switchCases),
                                                         rightBrace: switchRightBrace)
      let itemList = SyntaxFactory.makeCodeBlockItemList([SyntaxFactory.makeCodeBlockItem(item: switchStatement, semicolon: nil)])
      let body = SyntaxFactory.makeCodeBlock(leftBrace: funcLeftBrace, statements: itemList, rightBrace: funcRightBrace)
      
      
      let decl = FunctionDeclSyntax { builder in
        builder.useFuncKeyword(matchFunc)
        builder.useIdentifier(SyntaxFactory.makeStringLiteral("match"))
        builder.useSignature(matchFuncSignature)
        builder.useBody(body)
      }
      
      let members = MemberDeclBlockSyntax { builder in
        builder.useLeftBrace(leftBrace)
        builder.addDecl(decl)
        builder.useRightBrace(rightBrace)
      }
      let extensionDeclaration = ExtensionDeclSyntax { builder in
        builder.useExtensionKeyword(extensionKeyword)
        builder.useExtendedType(identifier)
        builder.useMembers(members)
      }
      decls.append(SyntaxFactory.makeCodeBlockItem(item: extensionDeclaration, semicolon: nil))
    }
    let importKeyword = SyntaxFactory.makeImportKeyword(leadingTrivia: .zero, trailingTrivia: .spaces(1))
    let foundationImport = SyntaxFactory.makeIdentifier("Foundation", leadingTrivia: .zero, trailingTrivia: .newlines(2))
    let allExtensions = SyntaxFactory.makeCodeBlockItem(item: SyntaxFactory.makeCodeBlockItemList(decls), semicolon: nil)
    let codeBlockList = SyntaxFactory.makeCodeBlockItemList([SyntaxFactory.makeCodeBlockItem(item: importKeyword,
                                                                                             semicolon: nil),
                                                             SyntaxFactory.makeCodeBlockItem(item: foundationImport, semicolon: nil)])
    
    let imports = SyntaxFactory.makeCodeBlockItem(item: codeBlockList, semicolon: nil)
    let source = SourceFileSyntax { builder in
      builder.addCodeBlockItem(imports)
      builder.addCodeBlockItem(allExtensions)
      builder.useEOFToken(SyntaxFactory.makeToken(TokenKind.eof, presence: .present))
    }
    var fileWriter = FileWriter(rootDirectoryUrl: rootDirectoryUrl)
    source.write(to: &fileWriter)
  }
}
