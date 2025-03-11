//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Сергей Скориков on 19.02.2025.
//

import Foundation

struct MostPopularMovies: Codable {
    //MARK: - Public Properties
    let errorMessage: String?
    let items: [MostPopularMovie]
}

struct MostPopularMovie: Codable {
    //MARK: - Public Properties
    let title: String
    let rating: String
    let imageURL: URL
    
    var resizedImageURL: URL {
        let urlString = imageURL.absoluteString
        let imageUrlString = urlString.components(separatedBy: "._")[0] + "._V0_UX600_.jpg"
        
        guard let newURL = URL(string: imageUrlString) else {
            return imageURL
        }
        return newURL
    }
    
    //MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
}
