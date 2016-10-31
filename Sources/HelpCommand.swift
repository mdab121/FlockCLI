//
//  HelpCommand.swift
//  FlockCLI
//
//  Created by Jake Heiser on 10/28/16.
//
//

import SwiftCLI
import Spawn
import FileKit

class HelpCommand: SwiftCLI.HelpCommand, FlockCommand {
    
    let name = "--help"
    let signature = "[<opt>] ..."
    let shortDescription = "Prints help information"
    
    let failOnUnrecognizedOptions = false
    let unrecognizedOptionsPrintingBehavior = UnrecognizedOptionsPrintingBehavior.printNone
    let helpOnHFlag = false
    
    var printCLIDescription: Bool = true
    var allCommands: [Command] = []
    
    func setupOptions(options: OptionRegistry) {}
    
    func execute(arguments: CommandArguments) throws {
        print("Available commands: ")
        
        for command in allCommands {
            var name = command.name
            if !command.signature.isEmpty && !(command is HelpCommand) {
                name += " \(command.signature)"
            }
            printLine(name: name, description: command.shortDescription)
        }
        
        printLine(name: "<task>", description: "Execute the given task")
        
        if flockIsInitialized {
            print()
            
            if Path.executable.exists {
                // Forward to help command of local cli
                let spawn = try Spawn(args: [Path.executable.rawValue, "--help"]) { (chunk) in
                    print(chunk, terminator: "")
                }
                _ = spawn.waitForExit()
            } else {
                print("Local Flock not built; run `flock --build` then `flock` to see available tasks")
            }
        }
    }
    
    private func printLine(name: String, description: String) {
        let spacing = String(repeating: " ", count: 20 - name.characters.count)
        print("flock \(name)\(spacing)\(description)")
    }
    
}