//
//  NetworkManager.swift
//  Oneida

import UIKit
import SwiftUI
@preconcurrency import WebKit

class NetworkManager: ObservableObject {
    
    @Published private(set) var oneURL: URL?

    static let initURL = URL(string: "https://oneidcagame.top/get")!
    private let storage: UserDefaults
    private var didSaveURL = false
    
    init(storage: UserDefaults = .standard) {
        self.storage = storage
        loadCheckedUrl()
    }
    
    func urlCheck(_ url: URL) {
        if didSaveURL {
            return
        }
        
        guard !isInvalidUrl(url) else {
            return
        }
        
        storage.set(url.absoluteString, forKey: "oneURL")
        oneURL = url
        didSaveURL = true
    }
    
    private func loadCheckedUrl() {
        if let urlString = storage.string(forKey: "oneURL") {
            if let url = URL(string: urlString) {
                oneURL = url
                didSaveURL = true
            } else {
                print("!!!: \(urlString)")
            }
        }
    }
    
    private func isInvalidUrl(_ url: URL) -> Bool {
        let invalidURLs = ["about:blank", "about:srcdoc"]
        
        if invalidURLs.contains(url.absoluteString) {
            return true
        }
        
        return false
    }
    
    func checkInitUrl() async throws -> Bool {
        do {
            var request = URLRequest(url: Self.initURL)
            request.setValue(getUserAgent(forWebView: false), forHTTPHeaderField: "User-Agent")
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return true
            }
            
            if (400...599).contains(httpResponse.statusCode) {
                return false
            }
            
            return true

        } catch {
            return false
        }
    }
    
    func getUserAgent(forWebView: Bool = false) -> String {
        if forWebView {
            let version = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")
            let agent = "Mozilla/5.0 (iPhone; CPU iPhone OS \(version) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
            return agent
        } else {
            let agent = "TestRequest/1.0 CFNetwork/1410.0.3 Darwin/22.4.0"
            return agent
        }
    }
}

struct WebViewManager: UIViewRepresentable {
    let url: URL
    let webManager: NetworkManager
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.bounces = true
        webView.customUserAgent = webManager.getUserAgent(forWebView: true)
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewManager
        
        init(_ parent: WebViewManager) {
            self.parent = parent
            super.init()
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard let finalURL = webView.url else {
                return
            }
            
            if finalURL != NetworkManager.initURL {
                parent.webManager.urlCheck(finalURL)
            } else {}
        }
    }
}
