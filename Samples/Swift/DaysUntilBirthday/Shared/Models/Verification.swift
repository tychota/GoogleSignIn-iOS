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

/// A model type representing that the user is age verified.
//struct Verification: Decodable {
//  let status: String
//
//  enum CodingKeys: String, CodingKey {
//      case status = "ageVerificationResults"  // Adjust the raw value to match your JSON
//  }
//    let status: String
//
//    enum CodingKeys: String, CodingKey {
//        case status
//    }
//
//  init(from decoder: Decoder) throws {
//
//  }


  // next step is trying to figure out how to decode this shiz
//}

//enum VerificationStatus: String, Decodable { // Make the enum Decodable
//    case agePending = "AGE_PENDING"
//    case ageOver18Standard = "AGE_OVER_18_STANDARD"
//}

/// A model representing the status of an age verification attempt.
struct Verification: Decodable {
  let status: VerificationStatus  // Use the enum here

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer() // Treat it as a single value
    var statusString = "squeak"
    statusString = try container.decode(String.self) // Decode the string
    guard let status = VerificationStatus(rawValue: statusString) else {
        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Invalid verification status: \(statusString)"
        )
    }
    self.status = status
  }

  enum VerificationStatus: String, Decodable {
      case agePending = "AGE_PENDING"
      case ageOver18Standard = "AGE_OVER_18_STANDARD"
  }
}

struct VerificationResponse: Decodable {
  var verifications: [Verification]
  var firstVerification: Verification?

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    print("aqui si")

    do {
        self.verifications = try container.decode([Verification].self, forKey: .ageVerificationResults)

        // Check for nil after the try block
        if self.verifications == nil {
            print("Decoding failed or key not found")
            // Handle the error (e.g., set a default value or display an error message)
        }

      guard let first = verifications.first else {
        print("you too young lol jk idky it error'd")
        throw Error.noVerificationInResult
      }
      let firstVerification = self.verifications.first
      self.firstVerification = firstVerification
      return
    } catch {
        // Handle other exceptions
        print("Error decoding verifications: \(error)")
    }

    self.verifications = [] // Empty array as default
//    self.firstVerification = Verification(from: <#T##Decoder#>)
    self.firstVerification = nil
//    self.firstVerification = Verification(
        // Provide default property values for Verification
//      from: .agePending // Or a default status that makes sense
        // ... (other properties with their defaults)
//    )
//    self.verifications = try container.decode([Verification].self, forKey: .ageVerificationResults)
    print("aqui no") // never gets printed 

    // won't even run these, jumps straight to end of init
//    guard !self.verifications.isEmpty else {
//                print("empty verifications yikes")
//                throw Error.noVerificationInResult
//            }
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
