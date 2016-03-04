//
//  NSStream+Connection.m
//  Relay
//

#import "NSStream+Connection.h"

@implementation NSStream (Connection)

- (void)openStreamWithDelegate:(id<NSStreamDelegate>)delegate {
    [self setDelegate:delegate];
    [self scheduleInRunLoop:[NSRunLoop currentRunLoop]
                    forMode:NSDefaultRunLoopMode];
    [self open];

}

- (void)closeStream {
    [self setDelegate:nil];
    [self close];
    [self removeFromRunLoop:[NSRunLoop currentRunLoop]
                    forMode:NSDefaultRunLoopMode];

}

@end
