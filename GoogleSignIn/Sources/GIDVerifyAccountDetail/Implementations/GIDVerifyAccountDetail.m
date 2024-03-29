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

#import "GoogleSignIn/Sources/Public/GoogleSignIn/GIDVerifyAccountDetail.h"

#import "GoogleSignIn/Sources/Public/GoogleSignIn/GIDVerifiableAccountDetail.h"
#import "GoogleSignIn/Sources/Public/GoogleSignIn/GIDVerifiedAccountDetailResult.h"
#import "GoogleSignIn/Sources/Public/GoogleSignIn/GIDConfiguration.h"

#import "GoogleSignIn/Sources/GIDSignInCallbackSchemes.h"
#import "GoogleSignIn/Sources/GIDSignInInternalOptions.h"

// #import <AppAuth/OIDServiceConfiguration.h>

@implementation GIDVerifyAccountDetail {
  GIDSignInInternalOptions *_currentOptions;

  // AppAuth configuration object.
//   OIDServiceConfiguration *_appAuthConfiguration;
}

#if TARGET_OS_IOS || TARGET_OS_MACCATALYST

- (void)verifyAccountDetails:(NSArray<GIDVerifiableAccountDetail *> *)accountDetails
    presentingViewController:(UIViewController *)presentingViewController
                  completion:(nullable void (^)(GIDVerifiedAccountDetailResult *_Nullable verifyResult,
                                                NSError *_Nullable error))completion {
    // TODO(#383): Implement this method.
}

- (void)verifyAccountDetails:(NSArray<GIDVerifiableAccountDetail *> *)accountDetails
    presentingViewController:(UIViewController *)presentingViewController
                        hint:(nullable NSString *)hint
                  completion:(nullable void (^)(GIDVerifiedAccountDetailResult *_Nullable verifyResult,
                                                NSError *_Nullable error))completion {
    // TODO(#383): Implement this method.
}

- (void)verifyAccountDetails:(NSArray<GIDVerifiableAccountDetail *> *)accountDetails
    presentingViewController:(UIViewController *)presentingViewController
                        hint:(nullable NSString *)hint
            additionalScopes:(nullable NSArray<NSString *> *)additionalScopes
                  completion:(nullable void (^)(GIDVerifiedAccountDetailResult *_Nullable verifyResult,
                                                NSError *_Nullable error))completion {
    // TODO(#383): Implement this method.
}

- (void)verifyAccountDetailsInteractivelyWithOptions:(GIDSignInInternalOptions *)options {

    // ensure client has valid parameters, presenting view controller, and proper callback schemes

    // assert valid parameters
    if (![options.configuration.clientID length]) {
        // double check if theres another error to be using
        // NOLINTNEXTLINE(google-objc-avoid-throwing-exception)
        [NSException raise:NSInvalidArgumentException
                    format:@"You must specify |clientID| in |GIDConfiguration|"];
    }

    // assert valid presenting view controller 
    if (!options.presentingViewController) {
        // double check if theres another error to be using
        // NOLINTNEXTLINE(google-objc-avoid-throwing-exception)
        [NSException raise:NSInvalidArgumentException
                    format:@"|presentingViewController| must be set."];
    }

    // assert proper callback scheme
    GIDSignInCallbackSchemes *schemes =
        [[GIDSignInCallbackSchemes alloc] initWithClientIdentifier:options.configuration.clientID];
    // NSURL *redirectURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@",
    //                                             [schemes clientIdentifierScheme],
    //                                             kBrowserCallbackPath]];

        // scope preparation
        NSMutableArray *scopes = [NSMutableArray array];
        for (GIDVerifiableAccountDetail *detail in options.accountDetailsToVerify) {
            NSString *scope = [detail retrieveScope];
            if (scope) {
                [scopes addObject:scope];
            } else {
                // figure out error
            }
        }


    // OIDAuthorizationRequest *request =
    //     [[OIDAuthorizationRequest alloc] initWithConfiguration:_appAuthConfiguration
    //                                                     clientId:options.configuration.clientID
    //                                                     scopes:options.scopes
    //                                                 redirectURL:redirectURL
    //                                                 responseType:OIDResponseTypeCode
    //                                         additionalParameters:additionalParameters];

}

#endif // TARGET_OS_IOS || TARGET_OS_MACCATALYST

@end
