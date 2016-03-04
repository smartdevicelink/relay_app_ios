//
//  NSObject+Notifications.h
//  Relay
//
//  Created by Muller, Alexander (A.) on 3/3/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Notifications)

- (void)addSelfObserverForNotificationNamed:(NSString *)name selector:(SEL)selector;

@end
