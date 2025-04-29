//
//  ShopView.swift
//  Oneida
//

import SwiftUI

struct ShopView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = ShopViewModel()
    @StateObject private var svm = SettingsViewModel.shared
    
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            AppBackgroundView(background: Color.deepPurple)
            
            VStack(spacing: 20) {
                HStack {
                    Button {
                        svm.play()
                        appViewModel.navigateTo(.menu)
                    } label: {
                        MainActionView(width: 40, height: 40, text: "", textSize: 24)
                            .overlay {
                                Image(systemName: "arrowshape.backward.circle")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(.white)
                            }
                    }
                    
                    Spacer()
                    
                    CounterView(amount: appViewModel.coins)
                    
                    Spacer()
                }
                
                Text("Shop")
                    .specialFont(60)
                    .scaleEffect(titleScale)
                    .opacity(titleOpacity)
                
                TabSelectorView(selectedTab: $viewModel.currentTab)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                
                Spacer()
                
                VStack(spacing: 30) {
                    if viewModel.currentTab == .instruments {
                        LazyVGrid(columns: columns, spacing: 30) {
                            ForEach(viewModel.availableInstruments) { instrument in
                                ShopItemView(
                                    imageName: instrument.imageName,
                                    price: instrument.price,
                                    isPurchased: viewModel.isInstrumentPurchased(instrument.id),
                                    isSelected: viewModel.isInstrumentSelected(instrument.id),
                                    canAfford: appViewModel.coins >= instrument.price,
                                    onBuy: {
                                        viewModel.purchaseInstrument(instrument.id)
                                    },
                                    onSelect: {
                                        viewModel.selectInstrument(instrument.id)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        LazyVGrid(columns: columns, spacing: 30) {
                            ForEach(viewModel.availableBackgrounds) { background in
                                ShopItemView(
                                    imageName: background.imageName,
                                    price: background.price,
                                    isPurchased: viewModel.isBackgroundPurchased(background.id),
                                    isSelected: viewModel.isBackgroundSelected(background.id),
                                    canAfford: appViewModel.coins >= background.price,
                                    onBuy: {
                                        viewModel.purchaseBackground(background.id)
                                    },
                                    onSelect: {
                                        viewModel.selectBackground(background.id)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .frame(maxWidth: .infinity)
                .opacity(contentOpacity)
                .offset(y: contentOffset)
                
                Spacer()
            }
            .padding()
            .onAppear {
                viewModel.appViewModel = appViewModel
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                    titleScale = 1.0
                    titleOpacity = 1.0
                }
                
                withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                    contentOpacity = 1.0
                    contentOffset = 0
                }
            }
        }
    }
}

#Preview {
    ShopView()
        .environmentObject(AppViewModel())
}
