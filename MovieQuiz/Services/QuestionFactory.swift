//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Сергей Скориков on 03.02.2025.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                
                switch result {
                case .success(let response):
                    self.movies = response.items
                    
                    if self.movies.isEmpty {
                        self.delegate?.didFailToLoadData(with: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Список фильмов пуст"]))
                        return
                    }
                    
                    self.delegate?.didLoadDataFromServer()
                    
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        delegate?.didStartLoadingNextQuestion()
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self, !self.movies.isEmpty else {
                self?.delegate?.didFailToLoadData(with: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Список фильмов пуст"]))
                return
            }
            
            let index = (0..<self.movies.count).randomElement() ?? 0
            guard let movie = self.movies[safe: index] else {
                self.delegate?.didFailToLoadData(with: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось получить фильм"]))
                return
            }
            
            let comparisonType = ComparisonType.allCases.randomElement()!
            let thresholdRating = self.generateThresholdRating(for: movie.rating)
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
                
                if imageData.isEmpty {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось загрузить изображение"])
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    
                    let errorMessage = "Не удалось загрузить изображение."
                    self.delegate?.didFailToLoadData(with: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                    
                }
                return
            }
            
            if let ratingFloat = Float(movie.rating) {
                let ratingInt = Int(ratingFloat.rounded())
                
                let text = self.formulateQuestionText(
                    comparisonType: comparisonType,
                    thresholdRating: thresholdRating,
                    actualRating: ratingInt
                )
                
                let correctAnswer = self.isAnswerCorrect(
                    comparisonType: comparisonType,
                    thresholdRating: thresholdRating,
                    actualRating: ratingInt
                )
                
                let question = QuizQuestion(image: imageData,
                                            text: text,
                                            correctAnswer: correctAnswer)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    
                    self.delegate?.didFinishLoadingNextQuestion(question)
                    self.delegate?.didReceiveNextQuestion(question: question)
                }
            }
        }
    }
    
    // MARK: - Private methods
    private func generateThresholdRating(for rating: String) -> Int {
        if let ratingFloat = Float(rating) {
            let ratingInt = Int(ratingFloat.rounded())
            let lowerBound = max(2, ratingInt - 4)
            let upperBound = min(8, ratingInt + 4)
            
            return Int.random(in: lowerBound...upperBound)
        } else {
            return Int.random(in: 2...8)
        }
    }
    
    private func formulateQuestionText(comparisonType: ComparisonType, thresholdRating: Int, actualRating: Int) -> String {
        return "Рейтинг этого фильма \(comparisonType.rawValue) чем \(thresholdRating)?"
    }
    
    private func isAnswerCorrect(comparisonType: ComparisonType, thresholdRating: Int, actualRating: Int) -> Bool {
        switch comparisonType {
        case .greaterThan:
            return actualRating > thresholdRating
        case .lessThan:
            return actualRating < thresholdRating
        }
    }
}

// MARK: - ComparisonType enum
enum ComparisonType: String {
    case greaterThan = "больше"
    case lessThan = "меньше"
    
    static var allCases: [ComparisonType] {
        [.greaterThan, .lessThan]
    }
}
