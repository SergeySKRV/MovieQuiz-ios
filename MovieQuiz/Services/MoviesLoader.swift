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
    private let networkClient = NetworkClient()
    
    private var mostPopularMoviesURL: URL {
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
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
                handler(.failure(error))
            }
        }
    }
}

enum MoviesLoaderError: Error {
    case invalidAPIKey
    case rateLimitExceeded
    case serverError(String?)
    case emptyMoviesList
}
