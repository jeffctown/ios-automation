import Foundation
import Moderator
import Files

let arguments = Moderator(description: "Search for and update a build setting in your project.")
let projectArg = arguments.add(Argument<String>.optionWithValue("p", name: "project", description: "The path to your project (xcodeproj).").required())
let regexArg = arguments.add(Argument<String>.optionWithValue("r", name: "regex", description: "The regex string to use.").required())
let replacementArg = arguments.add(Argument<String>.optionWithValue("n", name: "new", description: "The string to replace the regex match with.").required())

extension String {
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location + nsRange.length, limitedBy: utf16.endIndex),
            let from = from16.samePosition(in: self),
            let to = to16.samePosition(in: self)
            else { return nil }
        return from ..< to
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
    let matches = regex.matches(in: projectFileContents, options: [], range: NSRange(location: 0, length: projectFileContents.characters.count))
    print("*** Regex search complete.  \(matches.count) matches found.")
    
    for match in matches {
        if let nsRange = projectFileContents.range(from: match.range) {
            let matchString = projectFileContents.substring(with: nsRange)
            print("*** Matched: \(matchString)")
            print("*** Replacing with \(replacementArg.value)")
            projectFileContents.replaceSubrange(nsRange, with: replacementArg.value)
        }
    }
    
    print("*** Writing out new projects contents.")
    try projectFile.write(string: projectFileContents)
    print("*** Project file written at \(projectFile.path)")
    
} catch {
    print("*** FAILURE!")
    print(error)
    exit(Int32(error._code))
}

