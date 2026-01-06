//
//  MapWebView.swift
//  Taleb_5edma
//
//  Created by Apple on 10/11/2025.
//

import SwiftUI
import WebKit

/// A SwiftUI wrapper for WKWebView to display HTML content
/// Used primarily for embedding Leaflet.js OpenStreetMap
/// Supports JavaScript message passing for marker click events
struct MapWebView: UIViewRepresentable {
    let htmlString: String
    var onMarkerTap: ((String) -> Void)? = nil
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onMarkerTap: onMarkerTap)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        // Add message handler for marker clicks
        contentController.add(context.coordinator, name: "markerClicked")
        configuration.userContentController = contentController
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = true
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var onMarkerTap: ((String) -> Void)?
        
        init(onMarkerTap: ((String) -> Void)?) {
            self.onMarkerTap = onMarkerTap
        }
        
        // Handle messages from JavaScript
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "markerClicked", let offreId = message.body as? String {
                onMarkerTap?(offreId)
            }
        }
    }
}
