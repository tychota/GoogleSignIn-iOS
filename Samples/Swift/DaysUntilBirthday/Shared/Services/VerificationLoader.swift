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
import Foundation
import GoogleSignIn

#if os(iOS)

/// An observable class for verifying via Google.
final class VerificationLoader: ObservableObject {
  @Published private(set) var verification: Verification?

  private var verifiedAgeViewModel: VerifiedAgeViewModel

  private let baseUrlString = "https://autopush-verifywithgoogle.sandbox.googleapis.com/v1/ageVerification"

  private lazy var components: URLComponents? = {
    var comps = URLComponents(string: baseUrlString)
    return comps
  }()

  private lazy var request: URLRequest? = {
    guard let components = components, let url = components.url else {
      return nil
    }
    return URLRequest(url: url)
  }()

  /// Creates an instance of this loader.
  /// - parameter verifiedAgeViewModel: The view model to use to set verification status on.
  init(verifiedViewAgeModel: VerifiedAgeViewModel) {
    self.verifiedAgeViewModel = verifiedViewAgeModel
  }

  /// Verifies the user's age based upon the selected account.
  /// - note: Successful calls to this method will set the `verificationState` property of the
  /// `verifiedAgeViewModel` instance passed to the initializer.
  func verifyAccountDetails() {
    guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
      print("There is no root view controller!")
      return
    }

    let accountDetails: [GIDVerifiableAccountDetail] = [
      GIDVerifiableAccountDetail(accountDetailType: .ageOver18)
    ]
    let verifyAccountDetail = GIDVerifyAccountDetail()
    verifyAccountDetail.verifyAccountDetails(accountDetails, presenting: rootViewController) {
      verifyResult, error in
      guard let verifyResult else {
        self.verifiedAgeViewModel.verificationState = .unverified
        print("Error! \(String(describing: error))")
        return
      }
      self.fetchAgeVerificationSignal(verifyResult: verifyResult)
    }
  }

  private var cancellable: AnyCancellable?

  func fetchAgeVerificationSignal(verifyResult: GIDVerifiedAccountDetailResult) {
    self.verificationPublisher(verifyResult: verifyResult) { publisher in
      self.cancellable = publisher.sink { completion in
        switch completion {
        case .finished:
          break
        case .failure(let error):
          self.verification = Verification.noVerificationStatus
          print("Error retrieving age verification: \(error)")
        }
      } receiveValue: { verification in
        self.verifiedAgeViewModel.ageVerificationStatus = verification.statusString
        self.verifiedAgeViewModel.verificationState = .verified(verifyResult)
      }
    }
  }

  private func createSession(verifyResult: GIDVerifiedAccountDetailResult,
                             completion: @escaping (Result<URLSession, Error>) -> Void) {
    guard let token = verifyResult.accessTokenString else {
      completion(.failure(.couldNotCreateURLSession))
      return
    }
    let configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = [
      "Authorization": "Bearer \(token)"
    ]
    let session = URLSession(configuration: configuration)
    completion(.success(session))
  }

  func verificationPublisher(verifyResult: GIDVerifiedAccountDetailResult,
                             completion: @escaping (AnyPublisher<Verification, Error>) -> Void) {
    createSession(verifyResult: verifyResult) { [weak self] result in
      switch result {
      case .success(let urlSession):
        guard let request = self?.request else {
          return completion(Fail(error:.couldNotCreateURLRequest).eraseToAnyPublisher())
        }
        let verificationPublisher = urlSession.dataTaskPublisher(for: request)
          .tryMap { data, error -> Verification in
            let decoder = JSONDecoder()
            let verificationResponse = try decoder.decode(VerificationResponse.self, from: data)
            return verificationResponse.firstVerification
          }
          .mapError { error -> Error in
            guard let loaderError = error as? Error else {
              return Error.couldNotFetchVerificationSignal(underlying: error)
            }
            return loaderError
          }
          .receive(on: DispatchQueue.main)
          .eraseToAnyPublisher()
        completion(verificationPublisher)
      case .failure(let error):
        completion(Fail(error: error).eraseToAnyPublisher())
      }
    }
  }
}

extension VerificationLoader {
  enum Error: Swift.Error {
    case couldNotFetchVerificationSignal(underlying: Swift.Error)
    case couldNotCreateURLRequest
    case couldNotCreateURLSession
  }
}

#endif
