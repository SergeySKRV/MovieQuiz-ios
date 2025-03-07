//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Сергей Скориков on 03.02.2025.
//

import Foundation

protocol QuestionFactoryProtocol {
    //MARK: - Public Methods
    func requestNextQuestion()
    func loadData()
}
