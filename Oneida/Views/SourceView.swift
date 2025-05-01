//
//  SourceView.swift
//  Oneida

import SwiftUI

struct SourceView: View {
    @StateObject private var state = AppStateViewModel()
    
    var body: some View {
        Group {
            switch state.appState {
            case .initial:
                LoadingView()
            case .web:
                if let url = state.webManager.oneURL {
                    WebViewManager(url: url, webManager: state.webManager)
                } else {
                    WebViewManager(url: NetworkManager.initURL, webManager: state.webManager)
                }
            case .final:
                ContentView()
                    .preferredColorScheme(.light)
            }
        }
        .onAppear {
            state.fetchState()
        }
    }
}

#Preview {
    SourceView()
}
