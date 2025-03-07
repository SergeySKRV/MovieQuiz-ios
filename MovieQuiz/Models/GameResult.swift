//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Сергей Скориков on 09.02.2025.
//

import Foundation

struct GameResult: Codable, Comparable {
    //MARK: - Public Properties
    let correct: Int
    let total: Int
    let date: Date
    
    //MARK: - Comparable
    static func < (lhs: GameResult, rhs: GameResult) -> Bool {
        return lhs.correct < rhs.correct
    }
}
