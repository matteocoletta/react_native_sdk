//
//  AdjustSdk.h
//  Adjust SDK
//
//  Created by Abdullah Obaied (@obaied) on 25th October 2016.
//  Copyright © 2012-2018 Adjust GmbH. All rights reserved.
//

#import "AdjustSdk.h"
#import "AdjustSdkDelegate.h"

@implementation AdjustSdk

RCT_EXPORT_MODULE(Adjust);

BOOL _isAttributionCallbackImplemented;
BOOL _isEventTrackingSucceededCallbackImplemented;
BOOL _isEventTrackingFailedCallbackImplemented;
BOOL _isSessionTrackingSucceededCallbackImplemented;
BOOL _isSessionTrackingFailedCallbackImplemented;
BOOL _isDeferredDeeplinkCallbackImplemented;

#pragma mark - Public methods

RCT_EXPORT_METHOD(create:(NSDictionary *)dict) {
    NSString *appToken              = dict[@"appToken"];
    NSString *environment           = dict[@"environment"];
    NSString *logLevel              = dict[@"logLevel"];
    NSString *sdkPrefix             = dict[@"sdkPrefix"];
    NSString *defaultTracker        = dict[@"defaultTracker"];
    NSNumber *eventBufferingEnabled = dict[@"eventBufferingEnabled"];
    NSNumber *sendInBackground      = dict[@"sendInBackground"];
    NSNumber *shouldLaunchDeeplink  = dict[@"shouldLaunchDeeplink"];
    NSString *userAgent             = dict[@"userAgent"];
    NSNumber *delayStart            = dict[@"delayStart"];
    NSNumber *isDeviceKnown         = dict[@"isDeviceKnown"];

    NSString *secretId              = dict[@"secretId"];
    NSString *info1                 = dict[@"info1"];
    NSString *info2                 = dict[@"info2"];
    NSString *info3                 = dict[@"info3"];
    NSString *info4                 = dict[@"info4"];

    BOOL allowSuppressLogLevel = NO;

    // Log level
    if ([self isFieldValid:logLevel]) {
        if ([logLevel isEqualToString:@"SUPPRESS"]) {
            allowSuppressLogLevel = YES;
        }
    }

    ADJConfig *adjustConfig = [ADJConfig configWithAppToken:appToken environment:environment allowSuppressLogLevel:allowSuppressLogLevel];

    if ([adjustConfig isValid]) {
        // Log level
        if ([self isFieldValid:logLevel]) {
            [adjustConfig setLogLevel:[ADJLogger logLevelFromString:[logLevel lowercaseString]]];
        }

        // Event buffering
        if ([self isFieldValid:eventBufferingEnabled]) {
            [adjustConfig setEventBufferingEnabled:[eventBufferingEnabled boolValue]];
        }

        // SDK prefix
        if ([self isFieldValid:sdkPrefix]) {
            [adjustConfig setSdkPrefix:sdkPrefix];
        }

        // Default tracker
        if ([self isFieldValid:defaultTracker]) {
            [adjustConfig setDefaultTracker:defaultTracker];
        }

        // Attribution delegate & other delegates
        BOOL shouldLaunchDeferredDeeplink = [self isFieldValid:shouldLaunchDeeplink] ? [shouldLaunchDeeplink boolValue] : YES;

        if (_isAttributionCallbackImplemented
            || _isEventTrackingSucceededCallbackImplemented
            || _isEventTrackingFailedCallbackImplemented
            || _isSessionTrackingSucceededCallbackImplemented
            || _isSessionTrackingFailedCallbackImplemented
            || _isDeferredDeeplinkCallbackImplemented) {
            [adjustConfig setDelegate:
             [AdjustSdkDelegate getInstanceWithSwizzleOfAttributionCallback:_isAttributionCallbackImplemented
                                                     eventSucceededCallback:_isEventTrackingSucceededCallbackImplemented
                                                        eventFailedCallback:_isEventTrackingFailedCallbackImplemented
                                                   sessionSucceededCallback:_isSessionTrackingSucceededCallbackImplemented
                                                      sessionFailedCallback:_isSessionTrackingFailedCallbackImplemented
                                                   deferredDeeplinkCallback:_isDeferredDeeplinkCallbackImplemented
                                               shouldLaunchDeferredDeeplink:shouldLaunchDeferredDeeplink]];
        }

        // Send in background
        if ([self isFieldValid:sendInBackground]) {
            [adjustConfig setSendInBackground:[sendInBackground boolValue]];
        }

        // User agent
        if ([self isFieldValid:userAgent]) {
            [adjustConfig setUserAgent:userAgent];
        }

        // App Secret
        if ([self isFieldValid:secretId]
            && [self isFieldValid:info1]
            && [self isFieldValid:info2]
            && [self isFieldValid:info3]
            && [self isFieldValid:info4]) {
            [adjustConfig setAppSecret:[[NSNumber numberWithLongLong:[secretId longLongValue]] unsignedIntegerValue]
                             info1:[[NSNumber numberWithLongLong:[info1 longLongValue]] unsignedIntegerValue]
                             info2:[[NSNumber numberWithLongLong:[info2 longLongValue]] unsignedIntegerValue]
                             info3:[[NSNumber numberWithLongLong:[info3 longLongValue]] unsignedIntegerValue]
                             info4:[[NSNumber numberWithLongLong:[info4 longLongValue]] unsignedIntegerValue]];
        }

        // Device known
        if ([self isFieldValid:isDeviceKnown]) {
            [adjustConfig setIsDeviceKnown:[isDeviceKnown boolValue]];
        }

        // Delay start
        if ([self isFieldValid:delayStart]) {
            [adjustConfig setDelayStart:[delayStart doubleValue]];
        }

        [Adjust appDidLaunch:adjustConfig];
        [Adjust trackSubsessionStart];
    }
}

RCT_EXPORT_METHOD(trackEvent:(NSDictionary *)dict) {
    NSString *eventToken = dict[@"eventToken"];
    NSString *revenue = dict[@"revenue"];
    NSString *currency = dict[@"currency"];
    NSString *transactionId = dict[@"transactionId"];
    NSDictionary *callbackParameters = dict[@"callbackParameters"];
    NSDictionary *partnerParameters = dict[@"partnerParameters"];

    ADJEvent *adjustEvent = [ADJEvent eventWithEventToken:eventToken];

    if ([adjustEvent isValid]) {
        if ([self isFieldValid:revenue]) {
            double revenueValue = [revenue doubleValue];

            [adjustEvent setRevenue:revenueValue currency:currency];
        }

        if ([self isFieldValid:callbackParameters]) {
            for (NSString *key in callbackParameters) {
                NSString *value = [callbackParameters objectForKey:key];

                [adjustEvent addCallbackParameter:key value:value];
            }
        }

        if ([self isFieldValid:partnerParameters]) {
            for (NSString *key in partnerParameters) {
                NSString *value = [partnerParameters objectForKey:key];

                [adjustEvent addPartnerParameter:key value:value];
            }
        }

        if ([self isFieldValid:transactionId]) {
            [adjustEvent setTransactionId:transactionId];
        }

        [Adjust trackEvent:adjustEvent];
    }
}

RCT_EXPORT_METHOD(setOfflineMode:(NSNumber * _Nonnull)isEnabled) {
    [Adjust setOfflineMode:[isEnabled boolValue]];
}

RCT_EXPORT_METHOD(setEnabled:(NSNumber * _Nonnull)isEnabled) {
    [Adjust setEnabled:[isEnabled boolValue]];
}

RCT_EXPORT_METHOD(isEnabled:(RCTResponseSenderBlock)callback) {
    BOOL isEnabled = [Adjust isEnabled];
    NSNumber *boolNumber = [NSNumber numberWithBool:isEnabled];

    callback(@[boolNumber]);
}

RCT_EXPORT_METHOD(setPushToken:(NSString *)token) {
    if (!([self isFieldValid:token])) {
        return;
    }

    [Adjust setDeviceToken:[token dataUsingEncoding:NSUTF8StringEncoding]];
}

RCT_EXPORT_METHOD(appWillOpenUrl:(NSString *)urlStr) {
    if (urlStr == nil) {
        return;
    }

    NSURL *url;

    if ([NSString instancesRespondToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        url = [NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
#pragma clang diagnostic pop

    [Adjust appWillOpenUrl:url];
}

RCT_EXPORT_METHOD(sendFirstPackages) {
    [Adjust sendFirstPackages];
}

RCT_EXPORT_METHOD(addSessionCallbackParameter:(NSString *)key value:(NSString *)value) {
    if (!([self isFieldValid:key]) || !([self isFieldValid:value])) {
        return;
    }

    [Adjust addSessionCallbackParameter:key value:value];
}

RCT_EXPORT_METHOD(removeSessionCallbackParameter:(NSString *)key) {
    if (!([self isFieldValid:key])) {
        return;
    }

    [Adjust removeSessionCallbackParameter:key];
}

RCT_EXPORT_METHOD(resetSessionCallbackParameters) {
    [Adjust resetSessionCallbackParameters];
}

RCT_EXPORT_METHOD(addSessionPartnerParameter:(NSString *)key value:(NSString *)value) {
    if (!([self isFieldValid:key]) || !([self isFieldValid:value])) {
        return;
    }

    [Adjust addSessionPartnerParameter:key value:value];
}

RCT_EXPORT_METHOD(removeSessionPartnerParameter:(NSString *)key) {
    if (!([self isFieldValid:key])) {
        return;
    }

    [Adjust removeSessionPartnerParameter:key];
}

RCT_EXPORT_METHOD(resetSessionPartnerParameters) {
    [Adjust resetSessionPartnerParameters];
}

RCT_EXPORT_METHOD(getIdfa:(RCTResponseSenderBlock)callback) {
    NSString *idfa = [Adjust idfa];

    if (nil == idfa) {
        callback(@[@""]);
    } else {
        callback(@[idfa]);
    }
}

RCT_EXPORT_METHOD(getGoogleAdId:(RCTResponseSenderBlock)callback) {
    callback(@[@""]);
}

RCT_EXPORT_METHOD(getAmazonAdId:(RCTResponseSenderBlock)callback) {
    callback(@[@""]);
}

RCT_EXPORT_METHOD(getAdid:(RCTResponseSenderBlock)callback) {
    NSString *adid = [Adjust adid];

    if (nil == adid) {
        callback(@[@""]);
    } else {
        callback(@[adid]);
    }
}

RCT_EXPORT_METHOD(setReferrer:(NSString *)referrer) {}

RCT_EXPORT_METHOD(getAttribution:(RCTResponseSenderBlock)callback) {
    ADJAttribution *attribution = [Adjust attribution];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    if (attribution == nil) {
        callback(@[dictionary]);

        return;
    }

    [self addValueOrEmpty:dictionary key:@"trackerToken" value:attribution.trackerToken];
    [self addValueOrEmpty:dictionary key:@"trackerName" value:attribution.trackerName];
    [self addValueOrEmpty:dictionary key:@"network" value:attribution.network];
    [self addValueOrEmpty:dictionary key:@"campaign" value:attribution.campaign];
    [self addValueOrEmpty:dictionary key:@"creative" value:attribution.creative];
    [self addValueOrEmpty:dictionary key:@"adgroup" value:attribution.adgroup];
    [self addValueOrEmpty:dictionary key:@"clickLabel" value:attribution.clickLabel];
    [self addValueOrEmpty:dictionary key:@"adid" value:attribution.adid];

    callback(@[dictionary]);
}

RCT_EXPORT_METHOD(setAttributionCallbackListener) {
    _isAttributionCallbackImplemented = true;
}

RCT_EXPORT_METHOD(setEventTrackingSucceededCallbackListener) {
    _isEventTrackingSucceededCallbackImplemented = true;
}

RCT_EXPORT_METHOD(setEventTrackingFailedCallbackListener) {
    _isEventTrackingFailedCallbackImplemented = true;
}

RCT_EXPORT_METHOD(setSessionTrackingSucceededCallbackListener) {
    _isSessionTrackingSucceededCallbackImplemented = true;
}

RCT_EXPORT_METHOD(setSessionTrackingFailedCallbackListener) {
    _isSessionTrackingFailedCallbackImplemented = true;
}

RCT_EXPORT_METHOD(setDeferredDeeplinkCallbackListener) {
    _isDeferredDeeplinkCallbackImplemented = true;
}

#pragma mark - Private & helper methods

- (BOOL)isFieldValid:(NSObject *)field {
    if (![field isKindOfClass:[NSNull class]]) {
        if (field != nil) {
            return YES;
        }
    }

    return NO;
}

- (void)addValueOrEmpty:(NSMutableDictionary *)dictionary
                    key:(NSString *)key
                  value:(NSObject *)value {
    if (nil != value) {
        [dictionary setObject:[NSString stringWithFormat:@"%@", value] forKey:key];
    } else {
        [dictionary setObject:@"" forKey:key];
    }
}

@end
