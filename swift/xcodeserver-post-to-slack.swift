import Foundation
import Moderator

class RunLoop {
    static var dispatchSemaphore = DispatchSemaphore(value: 0)
}

let arguments = Moderator(description: "Post Xcode Server Results to Slack.")

let botNameArg = arguments.add(Argument<String>.optionWithValue("n", name: "name", description: "The Xcode Server Bot's name.").required())
let integrationResultArg = arguments.add(Argument<String>.optionWithValue("r", name: "result", description: "The Xcode Server integration result.").required())
let errorChangeArg = arguments.add(Argument<Int>.optionWithValue("e", name: "errors", description: "The Xcode Server integration's change in errors.").required())
let warningChangeArg = arguments.add(Argument<Int>.optionWithValue("w", name: "warnings", description: "The Xcode Server integration's change in warnings.").required())
let urlSlugArg = arguments.add(Argument<String>.optionWithValue("p", name: "path", description: "The url path (the part after https://hooks.slack.com/services/).").required())

do {
    try arguments.parse()
    
    print("*** Constructing Slack URL.")
    let urlString = "https://hooks.slack.com/services/" + urlSlugArg.value
    let url = URL(string: urlString)!
    print("*** Done Constructing Slack URL: (\(url.absoluteString))")
    
    guard let errorChange = Int(errorChangeArg.value) else {
        throw ArgumentError(errormessage: "Errors value not an integer value.")
    }
    
    guard let warningChange = Int(warningChangeArg.value) else {
        throw ArgumentError(errormessage: "Warnings value not an integer value.")
    }
    
    print("*** Constructing JSON Body.")
    
    // basic result
    var jsonMessage = "\(botNameArg.value) was built with result *\(integrationResultArg.value)*"
    
    // add errors if the number of them changed
    if errorChange != 0 {
        jsonMessage += " :no_entry_sign: Errors : \(errorChange)"
    }
    
    // add warnings if the number of them changed
    if warningChange != 0 {
        jsonMessage += " :warning: Warnings: \(warningChange)"
    }
    
    let json = "{\"text\":\"\(jsonMessage)\"}"
    print("*** Done Constructing JSON Body. (\(json))")
    
    // url session & configuration
    let configuration = URLSessionConfiguration.default
    let urlSession = URLSession(configuration: configuration)
    
    // url request
    var urlRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 5.0)
    urlRequest.httpMethod = "POST"
    
    // post body
    let bodyData = json.data(using: String.Encoding.utf8, allowLossyConversion: true)
    print("*** HTTP Body: \(bodyData!)")
    urlRequest.httpBody = bodyData
    
    // do it now
    print("*** Posting Message to Slack.")
    urlSession.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
        print("*** Done Posting Message to Slack.")
        
        if let httpResponse = response as? HTTPURLResponse {
            print("*** ResponseCode: \(httpResponse.statusCode)")
        }
        
        if let error = error {
            print("*** Error encountered: \(error)")
            exit(Int32(error._code))
        }
        
        RunLoop.dispatchSemaphore.signal()
    }).resume()
    
    RunLoop.dispatchSemaphore.wait()
    
} catch {
    print("*** FAILURE!")
    print(error)
    exit(Int32(error._code))
}
