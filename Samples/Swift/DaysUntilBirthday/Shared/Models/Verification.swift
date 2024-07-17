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

import Foundation

struct Verification: Decodable {
  let status: VerificationStatus
  let statusString: String

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.statusString = try container.decode(String.self)
    guard let status = VerificationStatus(rawValue: statusString) else {
        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Invalid verification status: \(statusString)"
        )
    }
    self.status = status
  }

  init(status: Status) {
    self.status = status.status
    self.statusString = status.statusString
  }

  static var noVerificationStatus: Verification? {
    return Verification(status: Status(status: VerificationStatus.agePending,
                                       statusString: "AGE_PENDING"))
  }

  enum VerificationStatus: String, Decodable {
      case agePending = "AGE_PENDING"
      case ageOver18Standard = "AGE_OVER_18_STANDARD"
  }
}

extension Verification {
  struct Status: Decodable {
    let status: VerificationStatus
    let statusString: String
  }
}

struct VerificationResponse: Decodable {
  let verifications: [Verification]
  let firstVerification: Verification

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.verifications = try container.decode([Verification].self, forKey:.ageVerificationResults)
    guard let first = verifications.first else {
      throw Error.noVerificationInResult
    }
    self.firstVerification = first
  }
}

extension VerificationResponse {
  enum CodingKeys: String, CodingKey {
    case ageVerificationResults
  }
}

extension VerificationResponse {
  enum Error: Swift.Error {
    case noVerificationInResult
  }
}

/*
 {
   "name": "ageVerification",
   "verificationId": "A verification id string",
   "ageVerificationResults": [
     "AGE_PENDING"
   ]
 }
 */
