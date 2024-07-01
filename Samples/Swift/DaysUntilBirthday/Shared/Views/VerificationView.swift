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

import SwiftUI
import GoogleSignIn

struct VerificationView: View {
  @ObservedObject var authViewModel: AuthenticationViewModel

//  private let verifyBaseUrlString = "https://autopush-verifywithgoogle.sandbox.googleapis.com/v1/ageVerification"

  
//
//  private lazy var session: URLSession? = {
//    guard let accessToken = GIDSignIn
//            .sharedInstance
//            .currentUser?
//            .accessToken
//            .tokenString else { return nil }
//    let configuration = URLSessionConfiguration.default
//    configuration.httpAdditionalHeaders = [
//      "Authorization": "Bearer \(accessToken)"
//    ]
//    return URLSession(configuration: configuration)
//  }()'

//  private func sessionWithFreshToken(completion: @escaping (Result<URLSession, Error>) -> Void) {
//    GIDSignIn.sharedInstance.currentUser?.refreshTokensIfNeeded { user, error in
//      guard let token = user?.accessToken.tokenString else {
//        completion(.failure(.couldNotCreateURLSession(error)))
//        return
//      }
//      let configuration = URLSessionConfiguration.default
//      configuration.httpAdditionalHeaders = [
//        "Authorization": "Bearer \(token)"
//      ]
//      let session = URLSession(configuration: configuration)
//      completion(.success(session))
//    }
//  }

  var body: some View {
    switch authViewModel.verificationState {
    case .verified(let result):
      VStack {
        Text("List of result object properties:")
          .font(.headline)

        List {
          Text("Access Token: \(result.accessTokenString ?? "Not available")")
          Text("Refresh Token: \(result.refreshTokenString ?? "Not available")")

          if let expirationDate = result.expirationDate {
              Text("Expiration Date: \(formatDateWithDateFormatter(expirationDate))")
          } else {
              Text("Expiration Date: Not available")
          }
        }

        Spacer()
        Text("Letsgeddit:")
          .font(.title)

//        sessionWithFreshToken(completion: <#T##(Result<URLSession, Error>) -> Void#>)
      }
      .navigationTitle(NSLocalizedString("Verified account", comment: "Verified account label"))
      .toolbar {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
          Button(NSLocalizedString("Refresh", comment: "Refresh button"), action:{refresh(results: result)})
        }
      }
    case .unverified:
            ProgressView()
              .navigationTitle(NSLocalizedString("Unverified account",
                                                 comment: "Unverified account label"))
    }
  }

  func refresh(results: GIDVerifiedAccountDetailResult) {
    results.refreshTokens { (result, error) in
      print("you made it")
      authViewModel.verificationState = .verified(result)
    }
  }

  func formatDateWithDateFormatter(_ date: Date) -> String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateStyle = .medium
      dateFormatter.timeStyle = .short
      return dateFormatter.string(from: date)
  }
}
