//
//  ViewController.swift
//  javascriptTest
//
//  Created by 김민종 on 2022/09/05.
//

import UIKit
import WebKit

class ViewController: UIViewController, UIWebViewDelegate, WKNavigationDelegate {

    var jsonString = String()
    var webView: WKWebView!
    
    @IBOutlet weak var webViewBackgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setWebView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        load()

        webView.navigationDelegate = self
        self.createJsonToPass(email: "easyletgothen@gmail.com", firstName: "hello", lastName: "kim")
        
        // Here is important point!!!
        // Place where sending data from Swift -> JS
        // Have to write (javascript:window.NativeInterface.) before JS Function name helloWorld() and inside function add your data to pass
        webView.evaluateJavaScript("javascript:window.NativeInterface.helloWorld('\(self.jsonString)')") { (result, error) in

            print("Error : \(error?.localizedDescription ?? "")")
        }

    }
    // MARK: - Setting up the WKWebView Step1

    func load() {
        let url = URL(string: "Input Your URL Here")!

        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self

    }
    // MARK: - Setting up the WKWebView Step2

    func setWebView() {
            let contentController = WKUserContentController()
            
            // Adding Bridge name
            // With the name ("full", "back") is located at JS and it's calling us with that name
            contentController.add(self, name: "full")
            contentController.add(self, name: "back")

            let configuration = WKWebViewConfiguration()
            configuration.userContentController = contentController
            
            webView = WKWebView(frame: .zero, configuration: configuration)
            webViewBackgroundView.addSubview(webView)
        
            // Layout for webView
            webView.translatesAutoresizingMaskIntoConstraints = false
            webView.topAnchor.constraint(equalTo: webViewBackgroundView.topAnchor).isActive = true
            webView.bottomAnchor.constraint(equalTo: webViewBackgroundView.bottomAnchor).isActive = true
            webView.leadingAnchor.constraint(equalTo: webViewBackgroundView.leadingAnchor).isActive = true
            webView.trailingAnchor.constraint(equalTo: webViewBackgroundView.trailingAnchor).isActive = true
        }
    
    // MARK: - Making type of Data to pass to JS
    
    func createJsonToPass(email : String , firstName : String = "" , lastName : String = "" ) {
        
        let data = ["email": email ,"firstName": firstName , "lastName": lastName] as [String : Any]
        self.jsonString = createJsonForJavaScript(for: data)
        
    }
    
    // MARK: - Creating Json for JS

    func createJsonForJavaScript(for data: [String : Any]) -> String {
        var jsonString : String?
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            
            jsonString = String(data: jsonData, encoding: .utf8)!
            jsonString = jsonString?.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\\", with: "")
            
        } catch {
            print(error.localizedDescription)
        }
        print(jsonString!)
        return jsonString!
    }
    

}


    // MARK: - Place where getting message back from JS

    // This is where to get message from JS -> Swift
    // JS will send "full" or "back" message and with that string message make your own action
extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
            
        case "full":
            print("DeBug --> 탭바")
            
        case "back":
            print("DeBug --> 뒤로")

        default:
            break
        }
    }
}




