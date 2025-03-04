//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Сергей Скориков on 02.03.2025.
//
import Foundation
import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = .zero
    var currentQuestion: QuizQuestion?
    var correctAnswers: Int = .zero
    var questionFactory: QuestionFactory?
    weak var viewController: MovieQuizViewController?
    var statisticService: StatisticServiceProtocol?
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool){
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    //MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
            self?.viewController?.hideLoadingIndicator()
        }
    }
    
    func showNextQuestionOrResult() {
        if self.isLastQuestion() {
            statisticService = StatisticServiceImplementation()
           if let statisticService = statisticService {
                statisticService.store(correct: correctAnswers, total: questionsAmount)
                
                let gamesCount = statisticService.gamesCount
                let bestGame = statisticService.bestGame
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.YY HH:mm"
                
                let text = """
                            Ваш результат: \(correctAnswers)/\(questionsAmount)
                            Количество сыгранных квизов: \(gamesCount)
                            Ваш рекорд: \(bestGame.correct)/\(bestGame.total) (\(dateFormatter.string(from: bestGame.date)))
                            Средняя точность: (\(String(format: "%.2f", statisticService.totalAccuracy))%)
                        """
                
                let viewModel = QuizResultsViewModel(
                    title: "Этот раунд окончен",
                    text: text,
                    buttonText: "Сыграть еще раз")
                    viewController?.show(quiz: viewModel)
            }
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}
