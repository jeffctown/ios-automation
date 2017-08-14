import Foundation
import Files
import SwiftShell
import Moderator

let arguments = Moderator(description: "Update the version number in your plists.")
let infoPListArg = arguments.add(Argument<String>.optionWithValue("p", name: "plist", description: "The path to the plist."))
let versionArg = arguments.add(Argument<String>.optionWithValue("v", name: "version", description: "The version to update to."))

func exitWithFailure() {
    exit(Int32(1))
}

do {
    try arguments.parse()
    
    // check plist argument
    guard let infoPList = infoPListArg.value else {
        throw ArgumentError(errormessage: "PList not found.", usagetext: "use -p=Info.plist")
    }
    
    //check version argument
    guard let version = versionArg.value else {
        throw ArgumentError(errormessage: "Version number not found.", usagetext: "use -v=1.0.0")
    }
    
    //check plist exists
    _ = try File(path: infoPList)
    
    print("*** Reading version number")
    let readResult = run(bash: "/usr/libexec/PlistBuddy '-c' 'Print CFBundleShortVersionString' \(infoPList)")
    print("*** Finished Reading Version number (\(readResult.stdout))")
    print("*** Updating version number to \(version)")
    let writeResult = run(bash: "/usr/libexec/PlistBuddy '-c' 'Set CFBundleShortVersionString \(version)' \(infoPList)")
    print("*** Done updating version number.")
    print("*** Verifying version number.")
    let verifyResult = run(bash: "/usr/libexec/PlistBuddy '-c' 'Print CFBundleShortVersionString' \(infoPList)")
    print("*** Version number found: \(verifyResult.stdout)")
    if verifyResult.stdout != version {
        exitWithFailure()
    }
    
    print("*** Version number updated successfully.")
    print("*** SUCCESS!")
    
} catch {
    print("*** FAILURE!")
    print(error)
    exit(Int32(error._code))
}

