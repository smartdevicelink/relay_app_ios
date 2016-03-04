//
//  SDLTCPConnection.h
//  Relay
//

#import <Foundation/Foundation.h>

/**
 *  Object to store current connection properties.
 */
@interface SDLTCPConnection : NSObject

/**
 *  Convenience initializer for creating a SDLTCPConnection object. This class will retrieve
 *  the IP Address from the current connected network.
 * *
 *  @return instance of SDLTCPConnection
 */
+ (instancetype)connection;

/**
 *  The IP Address the connection is using.
 */
@property (nonatomic, readonly) NSString* ipAddress;

/**
 *  The port the connection is using.
 */
@property (nonatomic, readonly) NSUInteger port;

@end
