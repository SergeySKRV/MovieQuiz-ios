//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Сергей Скориков on 03.02.2025.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    //MARK: - Public Methods
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
    func didStartLoadingNextQuestion()
    func didFinishLoadingNextQuestion(_ question: QuizQuestion?)
}
