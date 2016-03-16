//
//  EASession+Streams.m
//  Relay
//

#import "EASession+Streams.h"
#import "NSStream+Connection.h"

@implementation EASession (Streams)

- (void)openStreamsWithDelegate:(id<NSStreamDelegate>)delegate {
    [self.inputStream openStreamWithDelegate:delegate];
    [self.outputStream openStreamWithDelegate:delegate];
}

- (void)closeStreams {
    [self.inputStream closeStream];
    [self.outputStream closeStream];
}

@end
