//
//  CreateTaskCommand.swift
//  FlockCLI
//
//  Created by Jake Heiser on 10/27/16.
//
//

import SwiftCLI
import FileKit
import Rainbow

class CreateTaskCommand: FlockCommand {
    
    let name = "--create"
    let signature = "<name>"
    let shortDescription = ""
    
    let taskSuffix = "Task"
    
    public func execute(arguments: CommandArguments) throws {
        var name = arguments.requiredArgument("name")
        if name.hasSuffix(taskSuffix) {
            name = name.substring(to: name.index(name.endIndex, offsetBy: taskSuffix.characters.count))
        }
        
        let namespace: String?
        if let colonIndex = name.characters.index(of: ":") {
            namespace = name.substring(to: colonIndex)
            name = name.substring(from: name.index(after: colonIndex))
        } else {
            namespace = nil
        }
        
        let namespaceSegment = namespace?.capitalized ?? ""
        let taskSegment = name.capitalized + taskSuffix
        let fileName = namespaceSegment + taskSegment + ".swift"
        let path = Path.deployDirectory + fileName
        if path.exists {
            throw CLIError.error("\(path) already exists".red)
        }
        
        try write(contents: template(for: name, in: namespace), to: path)
        try createLink(at: Path.flockDirectory + fileName, pointingTo: Path("..") + fileName, logPath: path)
        
        print("What's left to do:".yellow)
        print("1. Replace <NameThisGroup> at the top of your new file with a custom name")
        print("2. In your Flockfile, add `Flock.use(WhateverINamedIt)`")
    }
    
    func template(for name: String, in namespace: String?) -> String {
        let taskName = name.capitalized + taskSuffix
        var lines = [
            "import Flock",
            "",
            "extension Flock {",
            "   public static let <NameThisGroup>: [Task] = [",
            "       \(taskName)()",
            "   ]",
            "}",
            "",
            "// Delete if no custom Config properties are needed",
            "extension Config {",
            "   // public static var myVar = \"\"",
            "}",
            "",
            "class \(taskName): Task {",
            "   let name = \"\(name)\""
        ]
        if let namespace = namespace {
            lines.append("   let namespace = \"\(namespace)\"")
        }
        lines += [
            "",
            "   func run(on server: Server) throws {",
            "      // Do work",
            "   }",
            "}",
            ""
        ]
        return lines.joined(separator: "\n")
    }
    
}
