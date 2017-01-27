

import Foundation

class TMDBConfig {
    /*
     * API HOST
     */
    static var API_HOST = "https://api.themoviedb.org"
    
    static var API_VERSION = "3"
    
     /*
     * To build an image URL
     * https://developers.themoviedb.org/3/configuration/get-api-configuration
     */
    static var IMAGE_BASE_URL = "https://image.tmdb.org/t/p/"
    
    /*
     * API Key (v3 auth)
     */
    static var API_KEY = "ccd0b996256371ffd03feb8e8f1763eb"
    
    /*
     * API Read Access Token (v4 auth)
     */
    static var READ_ACCESS_TOKEN = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJjY2QwYjk5NjI1NjM3MWZmZDAzZmViOGU4ZjE3NjNlYiIsInN1YiI6IjU4ODhiNTY1YzNhMzY4NDEzYjAwOGUzMiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fMUJ3XxsOjCE2C7ZjwQTA87trh70KoS8mvs8P4Vrkww"
    
    
    static var nowPlaying: String = "https://api.themoviedb.org/3/movie/now_playing"
    static var topRated: String = "https://api.themoviedb.org/3/movie/top_rated"
    static var search: String = "https://api.themoviedb.org/3/search/keyword"
    
    //https://api.themoviedb.org/3/person/popular?api_key=<<api_key>>&language=en-US&page=1
    static var popular: String = "https://api.themoviedb.org/3/person/popular?api_key="
    
    
     //Example API Request
    ///https://api.themoviedb.org/3/movie/550?api_key=d1a73364956004feea730e36d63946e4

    static var discoverAPIEndPoint = {
        return "\(API_HOST)/\(API_VERSION)/discover/movie?api_key=\(API_KEY)"
    }()
    
    
    static func buildImagePath(poster_path:String)->String{
        return "\(IMAGE_BASE_URL)w500\(poster_path)"
    }
    static func buildImagePathX3(poster_path:String)->String{
        return "\(IMAGE_BASE_URL)w1000\(poster_path)"
    }
    
}
