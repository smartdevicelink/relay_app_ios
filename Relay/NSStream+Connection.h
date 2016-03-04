//
//  NSStream+Connection.h
//  Relay
//

#import <Foundation/Foundation.h>

@interface NSStream (Connection)

/**
 *  Convenience method that opens the stream, sets it's delegate, and adds it to the
 *  currentRunLoop.
 *  
 *  @param delegate Delegate that will respond to NSStream's delegate notifications.
 */
- (void)openStreamWithDelegate:(id<NSStreamDelegate>)delegate;

/**
 *  Convenience method that closes the stream, sets it's delegate to nil, and removes it 
 *  from the currentRunLoop.
 */
- (void)closeStream;

@end
