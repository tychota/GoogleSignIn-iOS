/*
 * Copyright 2021 Google LLC
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

/// An observable class representing the current user's `Birthday` and the number of days until that date.
final class AgeViewModel: ObservableObject {
  /// The `Birthday` of the current user.
  /// - note: Changes to this property will be published to observers.
  @Published private(set) var verification: Verification?

  private var cancellable: AnyCancellable?
  private let verificationLoader = VerificationLoader()
  func fetchAge(result: GIDVerifiedAccountDetailResult) {
    verificationLoader.verificationPublisher(result: result) { publisher in
      self.cancellable = publisher.sink { completion in
        switch completion {
        case .finished:
            print("um finished right?")
            break
        case .failure(let error):
          print("hehehe not finished")
        }
      } receiveValue: {
        verification in
        self.verification = verification
        print("what is a verification")
      }
      print("afuera!!!")
    }
  }
}
