import Foundation
import Files
import SwiftShell
import Moderator

let arguments = Moderator(description: "Update the version number in your podspecs.")
let podSpecArg = arguments.add(Argument<String>.optionWithValue("p", name: "podspec", description: "The path to the podspec."))
let versionArg = arguments.add(Argument<String>.optionWithValue("v", name: "version", description: "The version to update to."))

do {
    try arguments.parse()
    
    // check podspec argument
    guard let podSpec = podSpecArg.value else {
        throw ArgumentError(errormessage: "PodSpec not found.", usagetext: "use -p=Cocoapod.podspec")
    }
    
    //check version argument
    guard let version = versionArg.value else {
        throw ArgumentError(errormessage: "Version number not found.", usagetext: "use -v=1.0.0")
    }
    
    //check podspec exists
    let podSpecFile = try File(path: podSpec)
    
    //check podspec contents
    let podSpecContents = try podSpecFile.readAsString()
    
    print("*** Reading version number")
    var versionNumber: String?
    var versionUpdated = false
    podSpecContents.enumerateLines(invoking: { (line, _) in
        if versionUpdated { return }
        if line.contains("s.version") {
            let components = line.components(separatedBy: "=")
            if components.count > 1 {
                var value = components[1]
                versionNumber = value.trimmingCharacters(in: NSCharacterSet.whitespaces).trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                versionUpdated = true
            }
        }
    })
    
    guard let versionNum = versionNumber else {
        exit(Int32(1))
    }
    
    print("*** Finished Reading Version number (\(versionNum))")
    print("*** Updating version number to \(version)")
    
    let newPodSpecContents = podSpecContents.replacingOccurrences(of: versionNum, with: version)
    print("*** Podspec Updated To: \(newPodSpecContents)")
    print("*** Writing new Podspec (\(podSpec))")
    try podSpecFile.write(string: newPodSpecContents)
    
    print("*** Done updating version number.")
    print("*** Verifying version number.")
    
    guard try podSpecFile.readAsString().contains(version) else {
        exit(Int32(1))
    }
    
    print("*** Version number found: \(version)")
    print("*** Version number updated successfully.")
    print("*** SUCCESS!")
    
} catch {
    print("*** FAILURE!")
    print(error)
    exit(Int32(error._code))
}
