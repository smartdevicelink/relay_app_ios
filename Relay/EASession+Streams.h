//
//  EASession+Streams.h
//  Relay
//

#import <ExternalAccessory/ExternalAccessory.h>

@interface EASession (Streams)

/**
 *  Convenience method that opens both input and output streams, sets their delegates, and
 *  adds them to the currentRunLoop.
 *
 *  @param delegate Delegate that will respond to NSStream's delegate notifications.
 */
- (void)openStreamsWithDelegate:(id<NSStreamDelegate>)delegate;

/**
 *  Convenience method that closes both input and output streams, sets their delegates to 
 *  nil, and removes them from the currentRunLoop.
 */
- (void)closeStreams;

@end
