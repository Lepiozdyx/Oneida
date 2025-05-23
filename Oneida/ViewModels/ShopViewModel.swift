//
//  ShopViewModel.swift
//  Oneida

import SwiftUI
import Combine

class ShopViewModel: ObservableObject {
    enum ShopTab {
        case instruments
        case backgrounds
    }
    
    @Published var currentTab: ShopTab = .instruments
    @Published var availableInstruments: [InstrumentItem] = []
    @Published var availableBackgrounds: [BackgroundItem] = []
    
    weak var appViewModel: AppViewModel?
    
    init() {
        loadItems()
    }
    
    private func loadItems() {
        availableInstruments = InstrumentItem.availableInstruments
        availableBackgrounds = BackgroundItem.availableBackgrounds
    }
    
    func isInstrumentPurchased(_ id: String) -> Bool {
        guard let gameState = appViewModel?.gameState else { return false }
        return id == "guitar" || gameState.purchasedThemes.contains(id)
    }
    
    func isInstrumentSelected(_ id: String) -> Bool {
        guard let gameState = appViewModel?.gameState else { return false }
        return gameState.currentInstrumentId == id
    }
    
    func purchaseInstrument(_ id: String) {
        guard let appViewModel = appViewModel,
              let instrument = InstrumentItem.availableInstruments.first(where: { $0.id == id }),
              appViewModel.coins >= instrument.price else { return }
        
        appViewModel.addCoins(-instrument.price)
        
        if !appViewModel.gameState.purchasedThemes.contains(id) {
            appViewModel.gameState.purchasedThemes.append(id)
        }

        if !appViewModel.gameState.purchasedInstruments.contains(id) {
            appViewModel.gameState.purchasedInstruments.append(id)
        }
        
        appViewModel.saveGameState()
        
        selectInstrument(id)
    }
    
    func selectInstrument(_ id: String) {
        guard let appViewModel = appViewModel,
              isInstrumentPurchased(id) else { return }
        
        appViewModel.gameState.currentInstrumentId = id
        appViewModel.saveGameState()
        
        objectWillChange.send()
    }
    
    func isBackgroundPurchased(_ id: String) -> Bool {
        guard let gameState = appViewModel?.gameState else { return false }
        return id == "bg2" || gameState.purchasedThemes.contains(id)
    }
    
    func isBackgroundSelected(_ id: String) -> Bool {
        guard let gameState = appViewModel?.gameState else { return false }
        return gameState.currentBackgroundId == id
    }
    
    func purchaseBackground(_ id: String) {
        guard let appViewModel = appViewModel,
              let background = BackgroundItem.availableBackgrounds.first(where: { $0.id == id }),
              appViewModel.coins >= background.price else { return }
        
        appViewModel.addCoins(-background.price)
        
        if !appViewModel.gameState.purchasedThemes.contains(id) {
            appViewModel.gameState.purchasedThemes.append(id)
        }
        
        if !appViewModel.gameState.purchasedBackgrounds.contains(id) {
            appViewModel.gameState.purchasedBackgrounds.append(id)
        }
        
        appViewModel.saveGameState()
        
        selectBackground(id)
    }
    
    func selectBackground(_ id: String) {
        guard let appViewModel = appViewModel,
              isBackgroundPurchased(id) else { return }
        
        appViewModel.gameState.currentBackgroundId = id
        appViewModel.saveGameState()
        
        objectWillChange.send()
    }
}
