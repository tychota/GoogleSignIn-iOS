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

  private func session(completion: @escaping (Result<URLSession, Error>) -> Void, result: GIDVerifiedAccountDetailResult) {
    let token = result.accessTokenString
    let configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = [
      "Authorization": "Bearer \(String(describing: token))" // maybe change this
    ]
    let session = URLSession(configuration: configuration)
    completion(.success(session))
  }

  func verificationPublisher(completion: (AnyPublisher<Verification, Error) -> Void) {
    session { [weak self] result in
      switch result {
      case .success(let authSession):
        guard let request = self?.request
      case .failure(let error):
        completion(Fail(error: error).eraseToAnyPublisher())
      }

    }

  }

}
