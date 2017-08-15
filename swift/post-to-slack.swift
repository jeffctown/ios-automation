import Foundation
import Moderator


class RunLoop {
    static var dispatchSemaphore = DispatchSemaphore(value: 0)
}

let arguments = Moderator(description: "Post a message to Slack.")

let messageArg = arguments.add(Argument<String>.optionWithValue("m", name: "message", description: "The message to post.").required())
let urlSlugArg = arguments.add(Argument<String>.optionWithValue("p", name: "path", description: "The url path (the part after https://hooks.slack.com/services/).").required())

do {
    try arguments.parse()
    
    print("*** Constructing Slack URL.")
    let urlString = "https://hooks.slack.com/services/" + urlSlugArg.value
    let url = URL(string: urlString)!
    print("*** Done Constructing Slack URL: (\(url.absoluteString))")
    
    print("*** Constructing JSON Body.")
    let json = "{\"text\":\"\(messageArg.value)\"}"
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
