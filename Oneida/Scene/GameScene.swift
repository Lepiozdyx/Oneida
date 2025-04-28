//
//  GameScene.swift
//  Oneida
//
//  Created by Alex on 27.04.2025.
//

import SpriteKit
import SwiftUI

protocol GameSceneDelegate: AnyObject {
    func didCollectNote(ofType type: NoteType)
    func didMissNote(ofType type: NoteType)
    func didCollectGoldCoin()
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Constants
    
    private enum PhysicsCategory {
        static let none: UInt32 = 0
        static let guitar: UInt32 = 0x1 << 0
        static let note: UInt32 = 0x1 << 1
        static let goldCoin: UInt32 = 0x1 << 2
        static let ground: UInt32 = 0x1 << 3
    }
    
    // MARK: - Properties
    
    weak var gameDelegate: GameSceneDelegate?
    private var guitar: SKSpriteNode?
    private var isGameActive = false
    private var notesSpawnTimer: Timer?
    private var goldCoinTimer: Timer?
    
    // Размеры
    private let guitarWidth: CGFloat = 50
    private let guitarHeight: CGFloat = 100
    private let noteSize: CGFloat = 30
    private let goldCoinSize: CGFloat = 35
    
    // MARK: - Lifecycle
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        checkAssetsAvailability()
        
        setupPhysics()
        setupGuitar()
        setupGround()
        
        isGameActive = true
        startSpawningNotes()
        scheduleGoldCoin()
    }
    
    // MARK: - Setup
    
    private func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        physicsWorld.contactDelegate = self
    }
    
    private func setupGuitar() {
        guitar = SKSpriteNode(imageNamed: "guitar")
        
        guard let guitar = guitar else { return }
        
        guitar.size = CGSize(width: guitarWidth, height: guitarHeight)
        guitar.position = CGPoint(x: frame.midX, y: 80)
        guitar.zPosition = 10
        
        guitar.physicsBody = SKPhysicsBody(rectangleOf: guitar.size)
        guitar.physicsBody?.isDynamic = false
        guitar.physicsBody?.categoryBitMask = PhysicsCategory.guitar
        guitar.physicsBody?.contactTestBitMask = PhysicsCategory.note | PhysicsCategory.goldCoin
        guitar.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        addChild(guitar)
    }
    
    private func setupGround() {
        let ground = SKNode()
        ground.position = CGPoint(x: frame.midX, y: 0)
        
        let groundBody = SKPhysicsBody(edgeFrom: CGPoint(x: -frame.width/2, y: 0),
                                     to: CGPoint(x: frame.width/2, y: 0))
        groundBody.categoryBitMask = PhysicsCategory.ground
        groundBody.contactTestBitMask = PhysicsCategory.note
        groundBody.collisionBitMask = PhysicsCategory.none
        
        ground.physicsBody = groundBody
        addChild(ground)
    }
    
    // MARK: - Game Control
    
    func resetGame() {
        removeAllNotes()
        isPaused = false
        isGameActive = true
        
        // Отменяем все текущие таймеры
        notesSpawnTimer?.invalidate()
        goldCoinTimer?.invalidate()
        
        // Запускаем новые таймеры
        startSpawningNotes()
        scheduleGoldCoin()
    }
    
    func pauseGame() {
        isGameActive = false
        notesSpawnTimer?.invalidate()
        goldCoinTimer?.invalidate()
        
        // Останавливаем все движущиеся объекты
        self.isPaused = true
    }
    
    func resumeGame() {
        isGameActive = true
        self.isPaused = false
        startSpawningNotes()
        scheduleGoldCoin()
    }
    
    private func startSpawningNotes() {
        notesSpawnTimer?.invalidate()
        
        // Генерируем ноты с периодичностью 0.8-1.5 секунды
        notesSpawnTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isGameActive else { return }
            self.spawnNote()
        }
    }
    
    private func scheduleGoldCoin() {
        goldCoinTimer?.invalidate()
        
        // Запланировать появление золотой монеты через случайное время
        let randomDelay = Double.random(in: 15...25)
        goldCoinTimer = Timer.scheduledTimer(withTimeInterval: randomDelay, repeats: false) { [weak self] _ in
            guard let self = self, self.isGameActive else { return }
            self.spawnGoldCoin()
        }
    }
    
    private func spawnNote() {
        // С небольшой вероятностью (10%) спауним скрипичный ключ
        let useKey = Int.random(in: 0...9) == 0
        let noteType = useKey ? NoteType.key : NoteType.random(excludingKey: true)
        
        // Создаем узел с текстурой
        let note = SKSpriteNode(imageNamed: noteType.imageName)
        
        // Применяем цвет к текстуре
        note.color = SKColor(noteType.color)
        note.colorBlendFactor = 1.0
        
        // Устанавливаем корректный размер
        let scale = noteSize / max(note.size.width, note.size.height)
        note.setScale(scale)
        
        note.name = "note-\(noteType.rawValue)"
        
        // Случайная позиция по X с отступами от краев
        let margin: CGFloat = 16.0
        let safeAreaMin = margin + note.size.width/2
        let safeAreaMax = size.width - margin - note.size.width/2
        let randomX = CGFloat.random(in: safeAreaMin...safeAreaMax)
        
        note.position = CGPoint(x: randomX, y: size.height + note.size.height)
        note.zPosition = 5
        
        // Физика
        note.physicsBody = SKPhysicsBody(circleOfRadius: noteSize/2)
        note.physicsBody?.categoryBitMask = PhysicsCategory.note
        note.physicsBody?.contactTestBitMask = PhysicsCategory.guitar | PhysicsCategory.ground
        note.physicsBody?.collisionBitMask = PhysicsCategory.none
        note.physicsBody?.affectedByGravity = true
        
        addChild(note)
    }
    
    private func spawnGoldCoin() {
        let goldCoin = SKSpriteNode(imageNamed: "goldCoin")
        goldCoin.name = "goldCoin"
        goldCoin.size = CGSize(width: goldCoinSize, height: goldCoinSize)
        
        // Случайная позиция по X с отступами от краев
        let margin: CGFloat = 8.0
        let safeAreaMin = margin + goldCoin.size.width/2
        let safeAreaMax = size.width - margin - goldCoin.size.width/2
        let randomX = CGFloat.random(in: safeAreaMin...safeAreaMax)
        
        goldCoin.position = CGPoint(x: randomX, y: size.height + goldCoin.size.height)
        goldCoin.zPosition = 5
        
        // Физика
        goldCoin.physicsBody = SKPhysicsBody(circleOfRadius: goldCoinSize/2)
        goldCoin.physicsBody?.categoryBitMask = PhysicsCategory.goldCoin
        goldCoin.physicsBody?.contactTestBitMask = PhysicsCategory.guitar
        goldCoin.physicsBody?.collisionBitMask = PhysicsCategory.none
        goldCoin.physicsBody?.affectedByGravity = true
        
        addChild(goldCoin)
        
        // Эффект сияния
        let glow = SKEffectNode()
        glow.position = goldCoin.position
        glow.zPosition = 4
        
        let pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        
        goldCoin.run(SKAction.repeatForever(pulseAction))
    }
    
    private func removeAllNotes() {
        self.enumerateChildNodes(withName: "//note-*") { node, _ in
            node.removeFromParent()
        }
        
        self.enumerateChildNodes(withName: "//goldCoin") { node, _ in
            if let parent = node.parent as? SKEffectNode {
                parent.removeFromParent()
            } else {
                node.removeFromParent()
            }
        }
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            moveGuitar(to: location)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            moveGuitar(to: location)
        }
    }
    
    private func moveGuitar(to location: CGPoint) {
        guard let guitar = guitar, isGameActive else { return }
        
        // Ограничение по краям экрана
        let minX = guitar.size.width / 2
        let maxX = size.width - guitar.size.width / 2
        let newX = min(maxX, max(minX, location.x))
        
        // Плавное перемещение
        let moveAction = SKAction.moveTo(x: newX, duration: 0.1)
        guitar.run(moveAction)
    }
    
    // MARK: - Collision Handling
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if (bodyA.categoryBitMask == PhysicsCategory.guitar && bodyB.categoryBitMask == PhysicsCategory.note) ||
            (bodyA.categoryBitMask == PhysicsCategory.note && bodyB.categoryBitMask == PhysicsCategory.guitar) {
            // Столкновение гитары и ноты
            let noteBody = bodyA.categoryBitMask == PhysicsCategory.note ? bodyA : bodyB
            handleNoteCollision(noteBody.node)
        } else if (bodyA.categoryBitMask == PhysicsCategory.guitar && bodyB.categoryBitMask == PhysicsCategory.goldCoin) ||
                    (bodyA.categoryBitMask == PhysicsCategory.goldCoin && bodyB.categoryBitMask == PhysicsCategory.guitar) {
            // Столкновение гитары и золотой монеты
            let coinBody = bodyA.categoryBitMask == PhysicsCategory.goldCoin ? bodyA : bodyB
            handleGoldCoinCollision(coinBody.node)
        } else if (bodyA.categoryBitMask == PhysicsCategory.ground && bodyB.categoryBitMask == PhysicsCategory.note) ||
                    (bodyA.categoryBitMask == PhysicsCategory.note && bodyB.categoryBitMask == PhysicsCategory.ground) {
            // Нота упала на землю (пропущена)
            let noteBody = bodyA.categoryBitMask == PhysicsCategory.note ? bodyA : bodyB
            handleNoteMissed(noteBody.node)
        }
    }
    
    private func handleNoteCollision(_ node: SKNode?) {
        guard let noteName = node?.name, isGameActive else { return }
        
        // Определяем тип ноты из имени
        let components = noteName.split(separator: "-")
        if components.count > 1, let typeRawValue = Int(components[1]), let type = NoteType(rawValue: typeRawValue) {
            gameDelegate?.didCollectNote(ofType: type)
            
            // Добавляем эффект сбора
            showCollectionEffect(at: node?.position ?? .zero, isSuccess: true)
            
            // Удаляем ноту
            node?.removeFromParent()
        }
    }
    
    private func handleGoldCoinCollision(_ node: SKNode?) {
        guard isGameActive else { return }
        
        // Добавим отладочную информацию
        print("Столкновение с золотой монетой обработано")
        
        // Важно! Явно проверим делегат перед вызовом
        if let delegate = gameDelegate {
            print("Вызываем делегат didCollectGoldCoin")
            
            // Вызываем делегат через main queue с небольшой задержкой
            // Задержка нужна, чтобы SpriteKit успел обработать физику
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                delegate.didCollectGoldCoin()
            }
        } else {
            print("ОШИБКА: делегат gameDelegate = nil")
        }
        
        // Добавляем эффект сбора
        showCollectionEffect(at: node?.position ?? .zero, isSuccess: true, isGoldCoin: true)
        
        // Удаляем монету
        if let parent = node?.parent as? SKEffectNode {
            parent.removeFromParent()
        } else {
            node?.removeFromParent()
        }
    }
    
    private func handleNoteMissed(_ node: SKNode?) {
        guard let noteName = node?.name, isGameActive else { return }
        
        // Определяем тип ноты из имени
        let components = noteName.split(separator: "-")
        if components.count > 1, let typeRawValue = Int(components[1]), let type = NoteType(rawValue: typeRawValue) {
            // Передаем тип пропущенной ноты в делегат
            gameDelegate?.didMissNote(ofType: type)
            
            // Добавляем эффект пропуска
            showCollectionEffect(at: node?.position ?? .zero, isSuccess: false)
            
            // Удаляем ноту
            node?.removeFromParent()
        }
    }
    
    private func showCollectionEffect(at position: CGPoint, isSuccess: Bool, isGoldCoin: Bool = false) {
        // Создаем эмиттер частиц для эффекта
        let emitterName = isGoldCoin ? "GoldCoinEffect" : (isSuccess ? "NoteCollectEffect" : "NoteMissEffect")
        let emitter = createParticleEffect(named: emitterName, at: position)
        addChild(emitter)
        
        // Автоматически убираем через небольшое время
        let wait = SKAction.wait(forDuration: 0.7)
        let remove = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([wait, remove]))
    }
    
    private func createParticleEffect(named: String, at position: CGPoint) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.position = position
        
        // Создаем простую частицу вместо использования текстуры
        let particleNode = SKShapeNode(circleOfRadius: 3)
        particleNode.fillColor = .white
        particleNode.strokeColor = .clear
        
        emitter.particleTexture = SKView().texture(from: particleNode)
        
        switch named {
        case "NoteCollectEffect":
            emitter.particleBirthRate = 100
            emitter.numParticlesToEmit = 30
            emitter.particleLifetime = 0.5
            emitter.particleSpeed = 100
            emitter.particleSpeedRange = 50
            emitter.emissionAngle = 0
            emitter.emissionAngleRange = CGFloat.pi * 2
            emitter.particleAlpha = 0.8
            emitter.particleAlphaRange = 0.2
            emitter.particleAlphaSpeed = -1.0
            emitter.particleScale = 0.2
            emitter.particleScaleRange = 0.1
            emitter.particleColor = .green
            
        case "NoteMissEffect":
            emitter.particleBirthRate = 80
            emitter.numParticlesToEmit = 20
            emitter.particleLifetime = 0.3
            emitter.particleSpeed = 80
            emitter.particleSpeedRange = 40
            emitter.emissionAngle = CGFloat.pi * 1.5
            emitter.emissionAngleRange = CGFloat.pi / 2
            emitter.particleAlpha = 0.8
            emitter.particleAlphaRange = 0.2
            emitter.particleAlphaSpeed = -2.0
            emitter.particleScale = 0.2
            emitter.particleScaleRange = 0.1
            emitter.particleColor = .red
            
        case "GoldCoinEffect":
            emitter.particleBirthRate = 150
            emitter.numParticlesToEmit = 50
            emitter.particleLifetime = 0.7
            emitter.particleSpeed = 120
            emitter.particleSpeedRange = 60
            emitter.emissionAngle = 0
            emitter.emissionAngleRange = CGFloat.pi * 2
            emitter.particleAlpha = 1.0
            emitter.particleAlphaRange = 0.2
            emitter.particleAlphaSpeed = -1.0
            emitter.particleScale = 0.3
            emitter.particleScaleRange = 0.1
            emitter.particleColor = .yellow
            
        default:
            break
        }
        
        return emitter
    }
    
    // метод для отладки
    private func checkAssetsAvailability() {
        var missingAssets: [String] = []
        
        for noteType in NoteType.allCases {
            let testSprite = SKSpriteNode(imageNamed: noteType.imageName)
            if testSprite.texture == nil {
                print("⚠️ Warning: Texture not found for \(noteType.imageName)")
                missingAssets.append(noteType.imageName)
            } else {
                print("✅ Texture loaded successfully for \(noteType.imageName)")
            }
        }
        
        // Проверяем текстуру золотой монеты
        let goldCoin = SKSpriteNode(imageNamed: "goldCoin")
        if goldCoin.texture == nil {
            print("⚠️ Warning: Texture not found for goldCoin")
            missingAssets.append("goldCoin")
        } else {
            print("✅ Texture loaded successfully for goldCoin")
        }
        
        // Проверяем текстуру гитары
        let guitar = SKSpriteNode(imageNamed: "guitar")
        if guitar.texture == nil {
            print("⚠️ Warning: Texture not found for guitar")
            missingAssets.append("guitar")
        } else {
            print("✅ Texture loaded successfully for guitar")
        }
        
        // Если есть отсутствующие текстуры, сообщаем об этом в консоль
        if !missingAssets.isEmpty {
            print("🚨 CRITICAL ERROR: Missing asset textures: \(missingAssets.joined(separator: ", "))")
        }
    }
}

// Вспомогательное расширение для конвертации SwiftUI Color в UIColor
extension Color {
    func uiColor() -> UIColor {
        UIColor(self)
    }
}
