//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Сергей Скориков on 03.02.2025.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
