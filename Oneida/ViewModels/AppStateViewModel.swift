//
//  AppStateViewModel.swift
//  Oneida

import Foundation

@MainActor
final class AppStateViewModel: ObservableObject {
    @Published private(set) var appState: Step = .initial
    
    enum Step {
        case initial
        case web
        case final
    }
    
    let webManager: NetworkManager
    
    init(webManager: NetworkManager = NetworkManager()) {
        self.webManager = webManager
    }
    
    func fetchState() {
        Task {
            if webManager.oneURL != nil {
                appState = .web
                return
            }
            
            do {
                if try await webManager.checkInitUrl() {
                    appState = .web
                } else {
                    appState = .final
                }
            } catch {
                appState = .final
            }
        }
    }
}
