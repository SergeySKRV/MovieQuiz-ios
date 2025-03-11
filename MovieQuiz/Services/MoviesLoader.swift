//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Сергей Скориков on 19.02.2025.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    //MARK: - Private Properties
    private let networkClient: NetworkRouting
    
    //MARK: - URL
    private var mostPopularMoviesURL: URL {
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    //MARK: - Initialization
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    //MARK: - Public Methods
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesURL) { result in
            switch result {
            case .success(let data):
                do {
                    let moviesResponse = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    
                    if let errorMessage = moviesResponse.errorMessage, !errorMessage.isEmpty {
                        handler(.failure(MoviesLoaderError.serverError(errorMessage)))
                        return
                    }
                    if moviesResponse.items.isEmpty {
                        handler(.failure(MoviesLoaderError.emptyMoviesList))
                        return
                    }
                    handler(.success(moviesResponse))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                if let networkError = error as? NetworkClient.NetworkError {
                    switch networkError {
                    case .codeError(let statusCode):
                        if statusCode == 401 {
                            handler(.failure(MoviesLoaderError.invalidAPIKey))
                        } else if statusCode == 429 {
                            handler(.failure(MoviesLoaderError.rateLimitExceeded))
                        } else {
                            handler(.failure(MoviesLoaderError.serverError("Ошибка сервера: \(statusCode)")))
                        }
                    }
                } else {
                    handler(.failure(error))
                }
            }
        }
    }
}

    //MARK: - MoviesLoaderError
    enum MoviesLoaderError: Error {
        case invalidAPIKey
        case rateLimitExceeded
        case serverError(String?)
        case emptyMoviesList
        case imageLoadingFailed
    }

