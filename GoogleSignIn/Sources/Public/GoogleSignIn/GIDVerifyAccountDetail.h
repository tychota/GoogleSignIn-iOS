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
#import <TargetConditionals.h>

@class GIDVerifableAccountDetail;
@class GIDVerifyAccountDetailsResult;

NS_ASSUME_NONNULL_BEGIN

@interface GIDVerifyAccountDetail : NSObject

#if TARGET_OS_IOS || TARGET_OS_MACCATALYST

- (void)verifyAccountDetails:(NSArray<GIDVerifableAccountDetail *> *)accountDetails
    presentingViewController:(UIViewController *)presentingViewController
                  completion:(nullable void (^)(GIDVerifyAccountDetailsResult *_Nullable verifyResult, NSError *_Nullable error))completion;

- (void)verifyAccountDetails:(NSArray<GIDVerifableAccountDetail *> *)accountDetails
    presentingViewController:(UIViewController *)presentingViewController
                        hint:(nullable NSString *)hint
                  completion:(nullable void (^)(GIDVerifyAccountDetailsResult *_Nullable verifyResult, NSError *_Nullable error))completion;

- (void)verifyAccountDetails:(NSArray<GIDVerifableAccountDetail *> *)accountDetails
    presentingViewController:(UIViewController *)presentingViewController
                        hint:(nullable NSString *)hint
            additionalScopes:(nullable NSArray<NSString *> *)additionalScopes
                  completion:(nullable void (^)(GIDVerifyAccountDetailsResult *_Nullable verifyResult, NSError *_Nullable error))completion;

#endif

@end

NS_ASSUME_NONNULL_END
