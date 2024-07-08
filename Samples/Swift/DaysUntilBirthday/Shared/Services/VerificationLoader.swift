/*
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Combine
import GoogleSignIn

final class VerificationLoader: ObservableObject {
  private let baseUrlString = "https://autopush-verifywithgoogle.sandbox.googleapis.com/v1/ageVerification"

  private lazy var components: URLComponents? = {
    var comps = URLComponents(string: baseUrlString)
    // check for what I can query for
    return comps
  }()

  private lazy var request: URLRequest? = {
    guard let components = components, let url = components.url else {
      return nil
    }
    return URLRequest(url: url)
  }()

  private func session(result: GIDVerifiedAccountDetailResult, completion: @escaping (Result<URLSession, Error>) -> Void) {
    guard let token = result.accessTokenString else {
      completion(.failure(.couldNotCreateURLSession))
      return
    }
    let configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = [
      "Authorization": "Bearer \(token)" // maybe change this
    ]
    let session = URLSession(configuration: configuration)
    completion(.success(session))
  }

  func verificationPublisher(result: GIDVerifiedAccountDetailResult, completion: @escaping (AnyPublisher<Verification, Error>) -> Void) {
    // Assuming you have a GIDVerifiedAccountDetailResult object named 'verificationResult'

    // session is returned, we get a result we expect
    session(result: result) {result in
      switch result {
      case .success(let authSession):
        guard let request = self.request else {
          print("AHHHHH ERROR")
          return
        }

        let vPublisher = authSession.dataTaskPublisher(for: request)
          .tryMap { data, error -> Verification in
            if let jsonString = String(data:data, encoding: .utf8) {
              print("Raw JSON Response: \(jsonString)")
            } // this prints the expected json response

            let decoder = JSONDecoder()
            do {
              let verificationResponse = try decoder.decode(VerificationResponse.self, from: data)
//              let firstVerification = verificationResponse.firstVerification
              guard let firstVerification = verificationResponse.firstVerification else {
                  throw Error.noVerificationInResult // Or a custom error
              }
              return firstVerification
            } catch {
              print("IM FINDING YOU: \(error)")
            }
            print("im still here") // never gets printed
            throw Error.noVerificationInResult
          }
          .mapError { error -> Error in
            guard let loaderError = error as? Error else {
              return Error.couldNotGetVerificationSignal(underlying: error)
            }
            return loaderError
          }
          .receive(on: DispatchQueue.main)
          .eraseToAnyPublisher()
        completion(vPublisher)
      case .failure(let error):
        // Handle the error that occurred while creating the session
        print("Error creating URLSession: \(error)")
        completion(Fail(error: error).eraseToAnyPublisher())
      }
    }
  }
}

extension VerificationLoader {
  enum Error: Swift.Error {
    case couldNotGetVerificationSignal(underlying: Swift.Error)
    case couldNotCreateURLSession
    case noVerificationInResult
  }
}
