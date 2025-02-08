//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Сергей Скориков on 03.02.2025.
//

import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion() 
}

private var questionFactory: QuestionFactoryProtocol?


