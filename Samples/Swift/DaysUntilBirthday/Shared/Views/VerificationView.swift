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
  @StateObject var ageViewModel = AgeViewModel()

  private let verificationLoader = VerificationLoader()

  @State private var ageVerificationStatus = "no updated status" // Default to pending

  var body: some View {
    switch authViewModel.verificationState {
    case .verified(let result):
      // honestly next task is to just fr clean this up, make a design, figure out what structs we need but we get the signal !!
      VStack {
//        Button(NSLocalizedString("Age verification status: \(ageVerificationStatus)", comment: "Age Verfication Status Button")) {
//          self.ageViewModel.fetchAge(result: result) { ageVerified in
//            self.ageVerificationStatus = ageVerified ? "AGE_OVER_18_STANDARD" : "AGE_PENDING"
//          }
//        }

//          Button(NSLocalizedString("Age verification status:", comment: "Age Verfication Status Button"), action:{self.ageViewModel.fetchAge(result: result)})


        Text("Age verification status: \(ageVerificationStatus)")

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

          Button(NSLocalizedString("Age it up", comment: "Age button"), action:{self.ageViewModel.fetchAge(result: result)})

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

  func grabAge() {

  }
}
