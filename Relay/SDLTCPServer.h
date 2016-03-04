//
//  SDLTCPServer.h
//  Relay
//

#import <Foundation/Foundation.h>
#import "SDLTCPConnection.h"

@class SDLTCPServer;

/**
 *  Describes the protocol of a TCPServer delegate.
 */
@protocol SDLTCPServerDelegate <NSObject>

/**
 *  Called when TCPServer has data from the client.
 *
 *  @param server   Shared SDLTCPServer
 *  @param data     The data to be sent.
 */
- (void)TCPServer:(SDLTCPServer*)server didReceiveData:(NSData*)data;

/**
 *  Called when TCPServer has established an available server.
 *
 *  @param server       Shared SDLTCPServer
 *  @param connection   Object storing connection information.
 */
- (void)TCPServer:(SDLTCPServer*)server hasAvailableConnection:(SDLTCPConnection*)connection;

/**
 *  Called when TCPServer has accepted an incoming connection.
 *
 *  @param server   Shared SDLTCPServer
 */
- (void)TCPServerDidConnect:(SDLTCPServer *)server;

/**
 *  Called when TCPServer has closed the current connection.
 *
 *  @param server   Shared SDLTCPServer
 */
- (void)TCPServerDidDisconnect:(SDLTCPServer *)server;

@end

/**
 *  TCP Server.
 */
@interface SDLTCPServer : NSObject <NSStreamDelegate>

/**
 *  The delegate for TCPServer callbacks.
 */
@property (weak) id<SDLTCPServerDelegate> delegate;

/**
 *  Create the TCPServer object.
 *
 *  @return Singleton instance of SDLTCPServer.
 */
+ (instancetype)sharedService;

/**
 *  Establish a new server session.
 */
- (void)startServer;

/**
 *  Close the current server session.
 */
- (void)stopServer;

/**
 *  Sends data to client.
 *
 *  @param data The data to be sent.
 */
- (void)sendData:(NSData*)data;

@end
