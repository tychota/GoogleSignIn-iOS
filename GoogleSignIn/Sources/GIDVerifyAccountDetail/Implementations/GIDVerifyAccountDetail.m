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

#import "GoogleSignIn/Sources/GIDEMMSupport.h"
#import "GoogleSignIn/Sources/GIDSignInCallbackSchemes.h"
#import "GoogleSignIn/Sources/GIDSignInInternalOptions.h"
#import "GoogleSignIn/Sources/GIDSignInPreferences.h"

@import GTMAppAuth;

#ifdef SWIFT_PACKAGE
@import AppAuth;
@import GTMSessionFetcherCore;
#else
#import <AppAuth/OIDAuthorizationRequest.h>
#import <AppAuth/OIDServiceConfiguration.h>
#endif


// Expected path in the URL scheme to be handled.
static NSString *const kBrowserCallbackPath = @"/oauth2callback";

// The EMM support version
static NSString *const kEMMVersion = @"1";

// Parameters for the auth and token exchange endpoints.
static NSString *const kAudienceParameter = @"audience";
static NSString *const kIncludeGrantedScopesParameter = @"include_granted_scopes";
static NSString *const kLoginHintParameter = @"login_hint";
static NSString *const kHostedDomainParameter = @"hd";

@implementation GIDVerifyAccountDetail {
  // This value is used when sign-in flows are resumed via the handling of a URL. Its value is
  // set when a sign-in flow is begun via |signInWithOptions:| when the options passed don't
  // represent a sign in continuation.
  GIDSignInInternalOptions *_currentOptions;
  // AppAuth configuration object.
  OIDServiceConfiguration *_appAuthConfiguration;
}

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

- (void)verifyAccountDetailsInteractivelyWithOptions:(GIDSignInInternalOptions *)options {
  if (!options.continuation) {
    _currentOptions = options;
  }

  if (!options.interactive) {
    return;
    // [insert error]
  }

  // Ensure that a configuration is set.
  if (!_configuration) {
    // [insert error]
    // NOLINTNEXTLINE(google-objc-avoid-throwing-exception)
    [NSException raise:NSInvalidArgumentException
                format:@"No active configuration.  Make sure GIDClientID is set in Info.plist."];
    return;    
  }

  // Explicitly throw exception for missing client ID here. This must come before
  // scheme check because schemes rely on reverse client IDs.
  [self assertValidParameters];

  [self assertValidPresentingViewController];

  GIDSignInCallbackSchemes *schemes =
  [[GIDSignInCallbackSchemes alloc] initWithClientIdentifier:options.configuration.clientID];
  NSArray<NSString *> *unsupportedSchemes = [schemes unsupportedSchemes];
  if (unsupportedSchemes.count != 0) {
    // NOLINTNEXTLINE(google-objc-avoid-throwing-exception)
    [NSException raise:NSInvalidArgumentException
                format:@"Your app is missing support for the following URL schemes: %@",
     [unsupportedSchemes componentsJoinedByString:@", "]];
  }
  NSURL *redirectURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@",
                                             [schemes clientIdentifierScheme],
                                             kBrowserCallbackPath]];

  NSString *emmSupport;
#if TARGET_OS_IOS
  emmSupport = [[self class] isOperatingSystemAtLeast9] ? kEMMVersion : nil;
#endif // TARGET_OS_IOS

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
  
#if TARGET_OS_IOS
  [additionalParameters addEntriesFromDictionary:
   [GIDEMMSupport parametersWithParameters:options.extraParams
                                emmSupport:emmSupport
                    isPasscodeInfoRequired:NO]];
#endif // TARGET_OS_IOS
  additionalParameters[kSDKVersionLoggingParameter] = GIDVersion();
  additionalParameters[kEnvironmentLoggingParameter] = GIDEnvironment();    

  NSMutableArray *scopes = [NSMutableArray array];
for (GIDVerifiableAccountDetail *detail in options.accountDetailsToVerify) {
    NSString *scope = [detail scope];
    if (scope) {
        [scopes addObject:scope];
    } else {
        // figure out error
    }
}

  OIDAuthorizationRequest *request =
  [[OIDAuthorizationRequest alloc] initWithConfiguration:_appAuthConfiguration
                                                clientId:options.configuration.clientID
                                                  scopes:scopes
                                             redirectURL:redirectURL
                                            responseType:OIDResponseTypeCode
                                    additionalParameters:additionalParameters];  
}

// #endif // TARGET_OS_IOS

#pragma mark - Helpers

+ (BOOL)isOperatingSystemAtLeast9 {
  NSProcessInfo *processInfo = [NSProcessInfo processInfo];
  return [processInfo respondsToSelector:@selector(isOperatingSystemAtLeastVersion:)] &&
  [processInfo isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){.majorVersion = 9}];
}

// Asserts the parameters being valid.
- (void)assertValidParameters {
  if (![_currentOptions.configuration.clientID length]) {
    // NOLINTNEXTLINE(google-objc-avoid-throwing-exception)
    [NSException raise:NSInvalidArgumentException
                format:@"You must specify |clientID| in |GIDConfiguration|"];
  }
}

// Assert that the presenting view controller has been set.
- (void)assertValidPresentingViewController {
#if TARGET_OS_IOS
  if (!_currentOptions.presentingViewController)
#endif // TARGET_OS_IOS
  {
    // NOLINTNEXTLINE(google-objc-avoid-throwing-exception)
    [NSException raise:NSInvalidArgumentException
                format:@"|presentingViewController| must be set."];
  }
}

@end
