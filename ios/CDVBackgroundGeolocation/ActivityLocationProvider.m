//
//  ActivityLocationProvider.m
//  CDVBackgroundGeolocation
//
//  Created by Marian Hello on 14/09/2016.
//  Copyright © 2016 mauron85. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActivityLocationProvider.h"
#import "SOMotionDetector.h"
#import "Logging.h"

static NSString * const TAG = @"ActivityLocationProvider";
static NSString * const Domain = @"com.marianhello";

@implementation ActivityLocationProvider

- (id) init
{
    self = [super init];
    
    if (self == nil) {
        return self;
    }
    
    [SOMotionDetector sharedInstance].useM7IfAvailable = YES;
    
    [SOMotionDetector sharedInstance].motionTypeChangedBlock = ^(SOMotionType motionType) {
        DDLogDebug(@"motionTypeChanged: %u)", motionType);
    };
    
    [SOMotionDetector sharedInstance].locationChangedBlock = ^(CLLocation *location) {
        DDLogDebug(@"locationChanged: %@)", location);
        
        Location *bgloc = [Location fromCLLocation:location];
        [super.delegate onLocationChanged:bgloc];
    };
    
    [SOMotionDetector sharedInstance].accelerationChangedBlock = ^(CMAcceleration acceleration) {
        DDLogDebug(@"accelerationChanged x=%f y=%f z=%f)", acceleration.x, acceleration.y, acceleration.z);
    };
    
    [SOMotionDetector sharedInstance].locationWasPausedBlock = ^(BOOL changed) {
        DDLogDebug(@"motionTypeChanged: %d)", changed);
    };
    
    return self;
}

- (void) onCreate {/* noop */}

- (void) onDestroy {/* noop */}

- (BOOL) configure:(Config*)config error:(NSError * __autoreleasing *)outError
{
    if (outError != nil) {
        NSDictionary *errorDictionary = @{ @"code": [NSNumber numberWithInt:NOT_IMPLEMENTED], @"message" : @"Not implemented yet" };
        *outError = [NSError errorWithDomain:Domain code:NOT_IMPLEMENTED userInfo:errorDictionary];
    }
    
    return NO;
}

- (BOOL) start:(NSError * __autoreleasing *)outError
{
    [[SOMotionDetector sharedInstance] startDetection];
    return YES;
}

- (BOOL) stop:(NSError * __autoreleasing *)outError
{
    [[SOMotionDetector sharedInstance] stopDetection];
    return YES;
}

- (void) switchMode:(BGOperationMode)mode
{
    /* do nothing */
}

@end