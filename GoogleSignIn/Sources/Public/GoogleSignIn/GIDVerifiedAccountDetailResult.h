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
#import <Foundation/Foundation.h>

@class GIDVerifiableAccountDetail;

NS_ASSUME_NONNULL_BEGIN

@interface GIDVerifiedAccountDetailsResult : NSObject

// When the access token expires, used to get a new one 
@property(nonatomic, readonly, nullable) NSDate *expirationDate;

// The access token that the developer can use to call Google APIs for verified info
@property(nonatomic, copy, readonly) NSString *accessTokenString;

// The refresh token that the developer can use with the access token expiration date
@property(nonatomic, copy, readonly) NSString *refreshTokenString;

// The list of successfully verified account details
@property(nonatomic, copy, readonly) NSArray<GIDVerifiableAccountDetail *> *verifiedAccountDetails;

@end

NS_ASSUME_NONNULL_END