//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Сергей Скориков on 09.02.2025.
//

import Foundation

protocol StatisticServiceProtocol {
    //MARK: - Public Properties
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    //MARK: - Public Methods
    func store(correct count: Int, total amount: Int)
}


