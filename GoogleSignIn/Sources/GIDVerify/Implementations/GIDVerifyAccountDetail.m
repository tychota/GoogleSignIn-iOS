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

#import "GoogleSignIn/Sources/Public/GoogleSignIn/GIDVerifyAccountDetail.h"

// #import "GIDVerifyAccountDetail.h"
// #import "GoogleSignIn/Sources/GIDSignInInternalOptions.h"
// #import "GoogleSignIn/Sources/GIDSignInCallbackSchemes.h"

// #import "GIDAuthentication.h"
// #import "GIDAuthentication_Private.h"
// #import "GIDErrorUtilities.h"
// #import "GIDSignIn.h"
// #import "GIDSignIn_Private.h"
// #import "GIDSignInUIDelegate.h"
#import "GoogleSignIn/Sources/Public/GoogleSignIn/GIDConfiguration.h"
#import "GoogleSignIn/Sources/Public/GoogleSignIn/GIDVerifyAccountDetail.h"
#import "GoogleSignIn/Sources/Public/GoogleSignIn/GIDProfileData.h"

#import "GoogleSignIn/Sources/Public/GoogleSignIn/GIDVerifiableAccountDetail.h"
#import "GoogleSignIn/Sources/Public/GoogleSignIn/GIDVerifiedAccountDetailsResult.h"

#import "GoogleSignIn/Sources/GIDSignInPreferences.h"
#import "GoogleSignIn/Sources/GIDEMMSupport.h"
#import "GoogleSignIn/Sources/GIDSignInCallbackSchemes.h"
#import "GoogleSignIn/Sources/GIDSignInInternalOptions.h"
#import "GoogleSignIn/Sources/GIDCallbackQueue.h"


// #import "GIDAppAuthHelper.h"
// #import "GIDVerifyAccountDetailsResult.h"
// @import GTMAppAuth
// #import <AppAuth/OIDResponseTypes.h>
// #import <AppAuth/OIDServiceConfiguration.h>
@import GTMAppAuth;

#ifdef SWIFT_PACKAGE
@import AppAuth;
@import GTMSessionFetcherCore;
#else
#import <AppAuth/OIDAuthState.h>
#import <AppAuth/OIDAuthorizationRequest.h>
#import <AppAuth/OIDExternalUserAgentSession.h>
#import <AppAuth/OIDTokenRequest.h>
#import <AppAuth/OIDAuthorizationService.h>

// #import <AppAuth/OIDAuthorizationService.h>
#endif

static NSString *const kBrowserCallbackPath = @"/oauth2callback";

static NSString *const kEMMVersion = @"1";

static NSString *const kEMMPasscodeInfoRequiredKeyName = @"emm_passcode_info_required";

static NSString *const kAudienceParameter = @"audience";

static NSString *const kOpenIDRealmParameter = @"openid.realm";
static NSString *const kIncludeGrantedScopesParameter = @"include_granted_scopes";
static NSString *const kLoginHintParameter = @"login_hint";
static NSString *const kHostedDomainParameter = @"hd";

static const NSTimeInterval kMinimumRestoredAccessTokenTimeToExpire = 600.0;

@interface GIDAuthFlow : GIDCallbackQueue

@property(nonatomic, strong, nullable) OIDAuthState *authState;
@property(nonatomic, strong, nullable) NSError *error;
@property(nonatomic, copy, nullable) NSString *emmSupport;
@property(nonatomic, nullable) GIDProfileData *profileData;

@end

@implementation GIDAuthFlow
@end

@implementation GIDVerifyAccountDetail {
    OIDServiceConfiguration *_appAuthConfiguration;
  id<OIDExternalUserAgentSession> _currentVerifyFlow;
  GIDSignInInternalOptions *_currentOptions;
}

#if TARGET_OS_IOS || TARGET_OS_MACCATALYST

- (void)verifyAccountDetails:(NSArray<GIDVerifableAccountDetail *> *)accountDetails
    presentingViewController:(UIViewController *)presentingViewController
                  completion:(nullable void (^)(GIDVerifyAccountDetailsResult *_Nullable verifyResult, NSError *_Nullable error))completion {
    [self verifyAccountDetails:accountDetails
        presentingViewController:presentingViewController
                            hint:nil
                    completion:completion];
}

- (void)verifyAccountDetails:(NSArray<GIDVerifableAccountDetail *> *)accountDetails
    presentingViewController:(UIViewController *)presentingViewController
                        hint:(nullable NSString *)hint
                  completion:(nullable void (^)(GIDVerifyAccountDetailsResult *_Nullable verifyResult, NSError *_Nullable error))completion {
//   GIDSignInInternalOptions *options =
//       [GIDSignInInternalOptions defaultOptionsWithConfiguration:_configuration
//                                        presentingViewController:presentingViewController
//                                                       loginHint:hint
//                                                   addScopesFlow:NO
//                                                      completion:completion];

}

- (void)verifyAccountDetails:(NSArray<GIDVerifableAccountDetail *> *)accountDetails
    presentingViewController:(UIViewController *)presentingViewController
                        hint:(nullable NSString *)hint
            additionalScopes:(nullable NSArray<NSString *> *)additionalScopes
                  completion:(nullable void (^)(GIDVerifyAccountDetailsResult *_Nullable verifyResult, NSError *_Nullable error))completion {
//   if (![GIDSignIn sharedInstance].currentUser.authentication.canHandleAuthorizationFlow) {
//     if (completion) {
//       completion(nil, [GIDErrorUtilities errorWithCode:kGIDErrorInvalidCredential]);
//     }
//     return;
//   }

//   GIDAuthentication *authentication = [GIDSignIn sharedInstance].currentUser.authentication;
//   [authentication verifyAccountDetails:accountDetails
//                    presentingViewController:presentingViewController
//                                    hint:hint
//                        additionalScopes:additionalScopes
//                              completion:completion];
}

- (void)verifyAccountDetailsInteractivelyWithOptions:(GIDSignInInternalOptions *)options {
    GIDSignInCallbackSchemes *schemes =
      [[GIDSignInCallbackSchemes alloc] initWithClientIdentifier:options.configuration.clientID];
  NSURL *redirectURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@",
                                             [schemes clientIdentifierScheme],
                                             kBrowserCallbackPath]];

  NSString *emmSupport;
// #if TARGET_OS_IOS && !TARGET_OS_MACCATALYST
  emmSupport = [[self class] isOperatingSystemAtLeast9] ? kEMMVersion : nil;
// #endif // TARGET_OS_MACCATALYST || TARGET_OS_OSX
// 1. check parameters

// 2. make oid auth request
  NSMutableDictionary<NSString *, NSString *> *additionalParameters = [@{} mutableCopy];
  additionalParameters[kIncludeGrantedScopesParameter] = @"true";
  if (options.configuration.serverClientID) {
    additionalParameters[kAudienceParameter] = options.configuration.serverClientID;
  }
  if (options.loginHint) {
    additionalParameters[kLoginHintParameter] = options.loginHint;
  }
  if (options.configuration.hostedDomain) {
    additionalParameters[kHostedDomainParameter] = options.configuration.hostedDomain;
  }

  [additionalParameters addEntriesFromDictionary:
      [GIDEMMSupport parametersWithParameters:options.extraParams
                                   emmSupport:emmSupport
                       isPasscodeInfoRequired:NO]];

  additionalParameters[kSDKVersionLoggingParameter] = GIDVersion();
  additionalParameters[kEnvironmentLoggingParameter] = GIDEnvironment();

  OIDAuthorizationRequest *verifyRequest =
      [[OIDAuthorizationRequest alloc] initWithConfiguration:_appAuthConfiguration
                                                    clientId:options.configuration.clientID
                                                      scopes:options.accountDetailsToVerify
                                                 redirectURL:redirectURL
                                                responseType:OIDResponseTypeCode
                                        additionalParameters:additionalParameters];

  _currentVerifyFlow = [OIDAuthorizationService presentAuthorizationRequest:verifyRequest
                                                               presentingViewController:options.presentingViewController
                                                                       callback:^(OIDAuthorizationResponse *_Nullable response,
                                                                                  NSError *_Nullable error) {
[self processAuthorizationResponse:response
                            error:error
                            emmSupport:emmSupport];
                                                            }];

//   GIDSignInCallbackSchemes *schemes =
//       [[GIDSignInCallbackSchemes alloc] initWithClientIdentifier:options.configuration.clientID];
//   NSURL *redirectURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@",
//                                              [schemes clientIdentifierScheme],
//                                              kBrowserCallbackPath]];
// // 1. input validation *valid parameters, view controller, callback schemes
//     if (!options || !options.addScopesFlow || !options.accountDetailsToVerify || options.accountDetailsToVerify < 1
//         || !options.presentingViewController || !options.completion) {
//         // completion(nil, error); NSERROR IT
//         // ERROR HERE
//         return;
//     }
// // 2. scope mapping
// NSMutableArray *scopes = [NSMutableArray array];
// for (GIDVerifableAccountDetail *detail in options.accountDetailsToVerify) {
//     if (detail.type == GIDAccountDetailTypeAgeOver18) {
//         [scopes addObect:@"https://www.googleapis.com/auth/verified.age.over18.standard"];
//     }
// }
// // 3. build authorization request
//   OIDAuthorizationRequest *request =
//       [[OIDAuthorizationRequest alloc] initWithConfiguration:_appAuthConfiguration
//                                                     clientId:options.configuration.clientID
//                                                       scopes:options.scopes
//                                                  redirectURL:redirectURL
//                                                 responseType:OIDResponseTypeCode
//                                         additionalParameters:additionalParameters];

// 4. initiate web flow
// 5. handle response

// passed in valid parameters
// valid presenting view controller
// proper callback schemes
// 1. check options != nil


    // if (![GIDSignIn sharedInstance].currentUser.authentication.canHandleAuthorizationFlow) {
    // if (options.completion) {
    //     options.completion(nil, [GIDErrorUtilities errorWithCode:kGIDErrorInvalidCredential]);
    // }
    // return;
    // }

    // GIDAuthentication *authentication = [GIDSignIn sharedInstance].currentUser.authentication;
    // GIDVerifyAccountDetailsResult *result = [authentication verifyAccountDetails:options.accountDetails
    //                                                     presentingViewController:options.presentingViewController
    //                                                                     hint:options.loginHint
    //                                                         additionalScopes:options.additionalScopes];
    // if (options.completion) {
    // options.completion(result, nil);
    // }

    // // 1. check options != nil
    // if (!options || !options.addScopesFlow || !options.accountDetailsToVerify || options.accountDetailsToVerify < 1
    //     || !options.presentingViewController || !options.completion) {
    // // completion(nil, error); NSERROR IT
    //     return;
    // }

    // NSArray *allowedSchemes = [self loadAllowedCallbackSchemes]; // Replace with your logic
    // NSURL *redirectURL = /* ... Extract from your OIDAuthorizationRequest */;
    // BOOL schemeIsValid = [allowedSchemes containsObject:redirectURL.scheme];

    // if (!schemeIsValid) {
    //     // ... Create NSError 
    //     completion(nil, error);
    //      return;
    // }

}

// check for whether or not the authorization response contains an authorization code 
- (void)processAuthorizationResponse:(OIDAuthorizationResponse *)authorizationResponse
                               error:(NSError *)error
                          emmSupport:(NSString *)emmSupport{
    GIDAuthFlow *authFlow = [[GIDAuthFlow alloc] init];
    authFlow.emmSupport = emmSupport;

    if (authorizationResponse) {
        if (authorizationResponse.authorizationCode.length) {
            authFlow.authState = [[OIDAuthState alloc] initWithAuthorizationResponse:authorizationResponse];
            [[self class] maybeFetchToken:authFlow]; //IMPLEMENT THIS
        } else {
            // IMPLEMENT ERROR
        }
    } else {
        // IMPLEMENT ERROR
    }
}

// Fetches the access token if necessary as part of the auth flow.
- (void)maybeFetchToken:(GIDAuthFlow *)authFlow {
  OIDAuthState *authState = authFlow.authState;
  // Do nothing if we have an auth flow error or a restored access token that isn't near expiration.
  if (authFlow.error ||
      (authState.lastTokenResponse.accessToken &&
        [authState.lastTokenResponse.accessTokenExpirationDate timeIntervalSinceNow] >
        kMinimumRestoredAccessTokenTimeToExpire)) {
    return;
  }
  NSMutableDictionary<NSString *, NSString *> *additionalParameters = [@{} mutableCopy];
  if (_currentOptions.configuration.serverClientID) {
    additionalParameters[kAudienceParameter] = _currentOptions.configuration.serverClientID;
  }
  if (_currentOptions.configuration.openIDRealm) {
    additionalParameters[kOpenIDRealmParameter] = _currentOptions.configuration.openIDRealm;
  }
#if TARGET_OS_IOS && !TARGET_OS_MACCATALYST
  NSDictionary<NSString *, NSObject *> *params =
      authState.lastAuthorizationResponse.additionalParameters;
  NSString *passcodeInfoRequired = (NSString *)params[kEMMPasscodeInfoRequiredKeyName];
  [additionalParameters addEntriesFromDictionary:
      [GIDEMMSupport parametersWithParameters:@{}
                                   emmSupport:authFlow.emmSupport
                       isPasscodeInfoRequired:passcodeInfoRequired.length > 0]];
#endif // TARGET_OS_IOS && !TARGET_OS_MACCATALYST
  additionalParameters[kSDKVersionLoggingParameter] = GIDVersion();
  additionalParameters[kEnvironmentLoggingParameter] = GIDEnvironment();

  OIDTokenRequest *tokenRequest;
  if (!authState.lastTokenResponse.accessToken &&
      authState.lastAuthorizationResponse.authorizationCode) {
    tokenRequest = [authState.lastAuthorizationResponse
        tokenExchangeRequestWithAdditionalParameters:additionalParameters];
  } else {
    [additionalParameters
        addEntriesFromDictionary:authState.lastTokenResponse.request.additionalParameters];
    tokenRequest = [authState tokenRefreshRequestWithAdditionalParameters:additionalParameters];
  }

  [authFlow wait];
  [OIDAuthorizationService
      performTokenRequest:tokenRequest
                 callback:^(OIDTokenResponse *_Nullable tokenResponse,
                            NSError *_Nullable error) {
    [authState updateWithTokenResponse:tokenResponse error:error];
    authFlow.error = error;

#if TARGET_OS_IOS && !TARGET_OS_MACCATALYST
    if (authFlow.emmSupport) {
      [GIDEMMSupport handleTokenFetchEMMError:error completion:^(NSError *error) {
        authFlow.error = error;
        [authFlow next];
      }];
    } else {
      [authFlow next];
    }
#elif TARGET_OS_OSX || TARGET_OS_MACCATALYST
    [authFlow next];
#endif // TARGET_OS_OSX || TARGET_OS_MACCATALYST
  }];
}

#endif

#pragma mark - Helpers

+ (BOOL)isOperatingSystemAtLeast9 {
  NSProcessInfo *processInfo = [NSProcessInfo processInfo];
  return [processInfo respondsToSelector:@selector(isOperatingSystemAtLeastVersion:)] &&
      [processInfo isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){.majorVersion = 9}];
}

@end
