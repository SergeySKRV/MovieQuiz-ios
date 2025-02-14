//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Сергей Скориков on 09.02.2025.
//

import Foundation


final class StatisticServiceImplementation: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    
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
            let correct = storage.integer(forKey: Keys.correct.rawValue)
            if let date = storage.object(forKey: Keys.bestGame.rawValue) as? Date {
                return GameResult(correct: correct, total: 10, date: date)
            } else {
                return GameResult(correct: 0, total: 10, date: Date())
            }
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGame.rawValue)
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
        let totalQuestions = gamesCount * 10
        return totalQuestions > 0 ? (Double(totalScore) / Double(totalQuestions)) * 100 : 0
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        totalScore += count
        
        let currentGameRecord = GameResult(correct: count, total: 10, date: Date())
        if currentGameRecord > bestGame {
            bestGame = currentGameRecord
        }
    }
}

