//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Сергей Скориков on 09.02.2025.
//

import Foundation


final class StatisticServiceImplementation: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    private let magicNumber = 10.0
    
    private enum Keys: String {
        case correct, bestGame, total, gamesCount
    }
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
         guard let data = storage.data(forKey: Keys.bestGame.rawValue),
               let record = try? JSONDecoder().decode(GameResult.self, from: data) else {
             return .init(correct: 0, total: 0, date: Date())
         }
               return record
            }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            storage.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    var totalScore: Int {
        get {
            storage.integer(forKey: Keys.total.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            return Double(totalScore) / Double(gamesCount) * magicNumber
        }
    }
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        totalScore += count
        
        let currentGameRecord = GameResult(correct: count, total: amount, date: Date())
        let lastGamesRecord = bestGame
        if lastGamesRecord < currentGameRecord {
            bestGame = currentGameRecord
        }
    }
}

