import Foundation
import Moderator
import Files

let arguments = Moderator(description: "Search for and update a build setting in your project.")
let projectArg = arguments.add(Argument<String>.optionWithValue("p", name: "project", description: "The path to your project (xcodeproj).").required())
let regexArg = arguments.add(Argument<String>.optionWithValue("r", name: "regex", description: "The regex string to use.").required())
let replacementArg = arguments.add(Argument<String>.optionWithValue("n", name: "new", description: "The string to replace the regex match with.").required())

extension String {
    func replacing(pattern: String, withTemplate: String) throws -> String {
        let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        return regex.stringByReplacingMatches(in: self, options: [], range: NSRange(0..<self.utf16.count), withTemplate: withTemplate)
    }
}

do {
    try arguments.parse()
    
    print("*** Opening project file.")
    let projectFile = try File(path: projectArg.value + "/project.pbxproj")
    print("*** Project file opened.")
    print("*** Reading project contents.")
    var projectFileContents = try projectFile.readAsString()
    print("*** Project contents read.")
    
    print("*** Creating regular expression.")
    let regex = try NSRegularExpression(pattern: regexArg.value, options: [])
    print("*** Regular expression created.")
    
    print("*** Searching in project for regex.")
    projectFileContents = try projectFileContents.replacing(pattern: regexArg.value, withTemplate: replacementArg.value)
    
    print("*** Writing out new projects contents.")
    try projectFile.write(string: projectFileContents)
    print("*** Project file written at \(projectFile.path)")
    
} catch {
    print("*** FAILURE!")
    print(error)
    exit(Int32(error._code))
}

