//
//  APIManager.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 22/7/23.
//

import Foundation

final class APIManager {
    // MARK: - Properties
    static let shared = APIManager()
    
    private init() {}
    private var basicURL: String = ProcessInfo.processInfo.environment["baseURL"] ?? "https://api.spotify.com/v1"
    
    // MARK: - Methods
    enum APIError: Error {
        case failedToGetData
    }
    // MARK: - UserProfile
    
    public func getCurrentUserProfile( completion: @escaping (Result<UserProfile, Error>) -> Void) {
        createRequest(with: URL(string: basicURL + "/me"), type: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                //                print(self.basicURL + "/me")
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do{
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(UserProfile.self, from: data)
                    completion(.success(result))
                }catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
                
            }
            task.resume()
            
        }
    }
    
    
    // MARK: - Albums
    
    
    public func getAlbumDetail(with album: AlbumResponse,
                               completion: @escaping (Result<AlbumsDetailsResponse,Error>) -> Void) {
        createRequest(
            with: URL(string: basicURL + "/albums/\(album.id)"),
            type: .GET) { request in
            
                let task = URLSession.shared.dataTask(with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        completion(.failure(APIError.failedToGetData))
                        return
                    }
                    do{
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let result = try decoder.decode(AlbumsDetailsResponse.self, from: data)
//                        print(result)
                        completion(.success(result))
                    }catch {
                        print(error)
                        completion(.failure(error))
                    }
                }
                task.resume()
        }
    }
    
    public func getCurrentUserAlbums(completion: @escaping (Result<[AlbumResponse], Error>) -> Void) {
        createRequest(
            with: URL(string: basicURL + "/me/albums"),
            type: .GET) { request in
                
                
                let task = URLSession.shared.dataTask(
                    with: request) { data, _, error in
                        guard let data = data, error == nil else {
                            return
                        }
                        
                        do{
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            let result = try decoder.decode(LibraryAlbumsResponse.self, from: data)
                            completion(.success(result.items.compactMap({ $0.album })))
                        }catch {
                            print(error)
                            completion(.failure(error))
                        }
                    }
                task.resume()
            }
    }
    
    public func saveAlbum(album: AlbumResponse, completion: @escaping (Bool) -> Void ) {
        createRequest(
            with: URL(string: basicURL + "/me/albums?ids=\(album.id)"),
            type: .PUT) { baseRequest in
                var request = baseRequest
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let task = URLSession.shared.dataTask(
                    with: request) { data, response, error in
                        guard let code = (response as? HTTPURLResponse)?.statusCode,
                              error == nil else {
                            completion(false)
                            return
                        }
                        
                        print(code)
                        completion(code == 200)
                    }
                task.resume()
            }
    }
    // MARK: - Playlist
    
    public func getPlaylistDetail(with playlist: Playlist,
                               completion: @escaping (Result<PlaylistDetailResponse,Error>) -> Void) {
        createRequest(
            with: URL(string: basicURL + "/playlists/\(playlist.id)"),
            type: .GET) { request in
            
                let task = URLSession.shared.dataTask(with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        completion(.failure(APIError.failedToGetData))
                        return
                    }
                    do{
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let result = try decoder.decode(PlaylistDetailResponse.self, from: data)
//                        print(result)
                        completion(.success(result))
                    }catch {
                        print(error)
                        completion(.failure(error))
                    }
                }
                task.resume()
        }
    }
    
    public func getCurrentUserPlaylists(
        completion: @escaping (Result<[Playlist], Error>) -> Void) {
        createRequest(with: URL(string: basicURL + "/me/playlists?limit=50"),
                      type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(LibraryPlaylistResponse.self, from: data)
                    completion(.success(result.items))
                } catch {
                    print(error)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func createPlaylist(
        with name: String,
        completion: @escaping (Bool) -> Void ) {
            getCurrentUserProfile {  [weak self] result in
                switch result {
                case .success(let profile):
                    let url = "\(self?.basicURL ?? "")/users/\(profile.id)/playlists"
                    
                    self?.createRequest(with: URL(string: url),
                                  type: .POST) { baseRequest in
                        var request = baseRequest
                        let json = [
                            "name": name
                        ]
                        request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
                        
                        let task = URLSession.shared.dataTask(with: request) { data, _, error in
                            guard let data = data, error == nil else {
                                completion(false)
                                return
                            }
                            
                            do {
                                let decoder = JSONDecoder()
                                decoder.keyDecodingStrategy = .convertFromSnakeCase
                                let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                                if let response = result as? [String: Any], response["id"] as? String != nil {
                                    print("created")
                                    completion(true)
                                }else {
                                    print("error")
                                    completion(false)
                                }
                               
                            } catch  {
                                print(error)
                                completion(false)
                            }
                        }
                        task.resume()

                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
    }
    
    public func addTrackPlaylist(
        track: AudioTrack,
        playlist: Playlist,
        completion: @escaping (Bool) -> Void ) {
        
            createRequest(
                with: URL(string: basicURL + "/playlists/\(playlist.id)/tracks"),
                type: .POST
            ) { baseRequest in
                //add header
                var request = baseRequest
                let json = [
                    "uris": [
                        "spotify:track:\(track.id)"
                    ]
                ]
                request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                //Task
                let task = URLSession.shared.dataTask(with: request) { data, _, error in
                    
                    guard let data = data, error == nil else {
                        completion(false)
                        return
                    }
                    
                    do {
                        let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        print(result)
                        if let response = result as? [String: Any],
                           response["snapshot_id"] as? String != nil {
                            
                            completion(true)
                        }else {
                            completion(false)
                        }
                    } catch {
                        completion(false)
                        print("error adding new track")
                    }

                    
                }
                task.resume()
            }
    }
    
    public func removeTrackFromPlaylist(
        track: AudioTrack,
        playlist: Playlist,
        completion: @escaping (Bool) -> Void ) {
            createRequest(
                with: URL(string: basicURL + "/playlists/\(playlist.id)/tracks"),
                type: .DELETE
            ) { baseRequest in
                //add header
                var request = baseRequest
                let json: [String: Any] = [
                    "tracks": [
                        [
                            "uri": "spotify:track:\(track.id)"
                        ]
                    ]
                ]
                request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                //Task
                let task = URLSession.shared.dataTask(with: request) { data, _, error in
                    
                    guard let data = data, error == nil else {
                        completion(false)
                        return
                    }
                    
                    do {
                        let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        print(result)
                        if let response = result as? [String: Any],
                           response["snapshot_id"] as? String != nil {
                            
                            completion(true)
                        }else {
                            completion(false)
                        }
                    } catch {
                        completion(false)
                        print("error adding new track")
                    }

                    
                }
                task.resume()
            }
        }
    
    // MARK: - Data Releases
    
    public func getReleases(completion: @escaping ((Result<NewReleasesResponse, Error>) -> Void)) {
        createRequest(with: URL(string: basicURL + "/browse/new-releases?limit=50"), type: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do{
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(NewReleasesResponse.self, from: data)
                    completion(.success(result))
                }catch{
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - FeaturePlaylists
    public func getFeaturedPlaylist(completion: @escaping (Result<FeaturedPlaylistResponse, Error>) -> Void) {
        createRequest(with: URL(string: basicURL + "/browse/featured-playlists?limit=20"),
                      type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(FeaturedPlaylistResponse.self, from: data)
//                    print(result)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
                
            }
            task.resume()
        }
    }
    
    // MARK: - Recommendations
    public func getRecomendations(genres: Set<String>, completion: @escaping (Result<RecomendationsResponse, Error>) -> Void) {
        
        let seends = genres.joined(separator: ",")
            createRequest(with: URL(string: basicURL + "/recommendations?limit=40&seed_genres=\(seends)"),
                          type: .GET) { request in
                let task = URLSession.shared.dataTask(with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        completion(.failure(APIError.failedToGetData))
                        return
                    }
    
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let result = try decoder.decode(RecomendationsResponse.self, from: data)
//                        print(result)
                        completion(.success(result))
                    } catch {
                        completion(.failure(error))
                    }
    
                }
                task.resume()
            }
        }
    
    public func getRecommendedGenres(completion: @escaping (Result<GenresResponse, Error>) -> Void ) {
        createRequest(with: URL(string: basicURL + "/recommendations/available-genre-seeds"),
                      type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(GenresResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
                
            }
            task.resume()
        }
    }
    
    // MARK: - GetCategories
    
    public func getCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
        createRequest(with: URL(string: basicURL + "/browse/categories?limit=50"),
                      type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request,
                                                  completionHandler: { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do{
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(AllCategoriesResponse.self, from: data)
                    completion(.success(result.categories.items))
                }catch{
                    completion(.failure(error))
                }
            })
            task.resume()
        }
    }
    
    public func getCategoryPlaylist(category: Category, completion: @escaping (Result<[Playlist], Error>) -> Void) {
        createRequest(with: URL(string: basicURL + "/browse/categories/\(category.id)/playlists?limit=30"),
                      type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request,
                                                  completionHandler: { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }

                do{
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(CategoryPlaylistResponse.self, from: data)
                    let playlists = result.playlists.items
//                    print(playlists)
                    completion(.success(playlists ))
                }catch {
                    completion(.failure(error))
                }
                
            })
            task.resume()
        }
    }
    
    // MARK: - Search
    public func search(with query: String, completion: @escaping (Result<[SearchResult], Error>) -> Void ) {
        createRequest(
            with: URL(string: basicURL + "/search?limit=10&type=album,artist,playlist,track&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"),
            type: .GET) { request in

                let task = URLSession.shared.dataTask(
                    with: request) { data, _, error in
                        guard let data = data, error == nil else {
                            completion(.failure(APIError.failedToGetData))
                            return
                        }

                        do{
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            let result = try decoder.decode(SearchResultResponse.self, from: data)
                            print(result.artists.items[0])
                            var searchResult: [SearchResult] = []
                            searchResult.append(contentsOf: result.tracks.items.compactMap({ SearchResult.track(model: $0) }))
                            searchResult.append(contentsOf: result.playlists.items.compactMap({ SearchResult.playlist(model: $0) }))
                            searchResult.append(contentsOf: result.albums.items.compactMap({ SearchResult.album(model: $0) }))
                            searchResult.append(contentsOf: result.artists.items.compactMap({ SearchResult.artist(model: $0) }))
                            completion(.success(searchResult))
                        }catch{
                            completion(.failure(error))
                        }
                    }
                task.resume()
            }
    }
    
    // MARK: - Base Request
    
    enum HTTPMethods: String {
        case GET
        case PUT
        case POST
        case DELETE
    }
    
    private func createRequest(with url: URL?, type: HTTPMethods,
                               completion: @escaping (URLRequest) -> Void) {
        AuthManager.shared.withValidToken { token in
            guard let apiUrl = url else {
                return
            }
            
            var request = URLRequest(url: apiUrl)
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            request.setValue("Bearer \(token)",
                             forHTTPHeaderField: "Authorization")
            completion(request)
        }
    }
}
