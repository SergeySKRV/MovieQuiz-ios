//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Сергей Скориков on 09.02.2025.
//

import Foundation

protocol StatisticServiceProtocol {
    func store(correct count: Int, total amount: Int)
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
}
