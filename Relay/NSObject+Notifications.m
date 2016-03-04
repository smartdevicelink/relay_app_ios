//
//  NSObject+Notifications.m
//  Relay
//
//  Created by Muller, Alexander (A.) on 3/3/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import "NSObject+Notifications.h"

@implementation NSObject (Notifications)

- (void)addSelfObserverForNotificationNamed:(NSString *)name selector:(SEL)selector {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:selector
                                                 name:name
                                               object:nil];
}

@end
