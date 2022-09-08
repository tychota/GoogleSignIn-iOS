// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "GoogleSignIn/Tests/Unit/OIDAuthState+Testing.h"

#import "GoogleSignIn/Tests/Unit/OIDAuthorizationResponse+Testing.h"
#import "GoogleSignIn/Tests/Unit/OIDTokenResponse+Testing.h"

@implementation OIDAuthState (Testing)

+ (instancetype)testInstance {
  return [[OIDAuthState alloc] initWithAuthorizationResponse:[OIDAuthorizationResponse testInstance]
                                               tokenResponse:[OIDTokenResponse testInstance]];
}

+ (instancetype)testInstanceWithIDToken:(NSString *)idToken {
  return [self testInstanceWithTokenResponse:[OIDTokenResponse testInstanceWithIDToken:idToken]];
}

+ (instancetype)testInstanceWithTokenResponse:(OIDTokenResponse *)tokenResponse {
  return [[OIDAuthState alloc] initWithAuthorizationResponse:[OIDAuthorizationResponse testInstance]
                                               tokenResponse:tokenResponse];
}

+ (instancetype)testInstanceWithIDToken:(NSString *)idToken
                            accessToken:(NSString *)accessToken
                  accessTokenExpireTime:(NSTimeInterval)accessTokenExpireTime {
  NSNumber *accessTokenExpiresIn =
      @(accessTokenExpireTime - [[NSDate date] timeIntervalSinceReferenceDate]);
  OIDTokenResponse *newResponse =
    [OIDTokenResponse testInstanceWithIDToken:idToken
                                  accessToken:accessToken
                                    expiresIn:accessTokenExpiresIn
                                 tokenRequest:nil];
  return [OIDAuthState testInstanceWithTokenResponse:newResponse];
}

@end
