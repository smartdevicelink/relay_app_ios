//
//  SDLiAPManager.h
//  Relay
//

#import <Foundation/Foundation.h>

@class SDLiAPManager;

/**
 *  Describes the protocol of an SDLiAPManager delegate.
 */
@protocol SDLiAPManagerDelegate <NSObject>

/**
 *  Called when SDLiAPManager has connected to an external accessory via USB.
 *
 *  @param iAPManager   Shared SDLiAPManager
 */
- (void)iAPManagerUSBConnected:(SDLiAPManager*)manager;

/**
 *  Called when SDLiAPManager has disconnected from an external accessory.
 *
 *  @param iAPManager   Shared SDLiAPManager
 */
- (void)iAPManagerUSBDisconnected:(SDLiAPManager *)manager;

/**
 *  Called when SDLiAPManager has established a control session with a TDK.
 *
 *  @param iAPManager   Shared SDLiAPManager
 */
- (void)iAPManagerControlSessionEstablished:(SDLiAPManager*)manager;

/**
 *  Called when SDLiAPManager has established a data session with a TDK.
 *
 *  @param iAPManager   Shared SDLiAPManager
 */
- (void)iAPManagerDataSessionEstablished:(SDLiAPManager*)manager;

/**
 *  Called when SDLiAPManager has data to send to send to the SDL app.
 *
 *  @param iAPManager   Shared SDLiAPManager
 *  @param data         The data to be sent.
 */
- (void)iAPManager:(SDLiAPManager*)manager didReceiveData:(NSData*)data;

@end

/**
 *  External Accessory session.
 */
@interface SDLiAPManager : NSObject

/**
 *  The delegate for SDLiAPManager callbacks.
 */
@property (weak) id<SDLiAPManagerDelegate> delegate;

/**
 *  Create the SDLiAPManager object.
 *
 *  @return Instance of SDLiAPManager.
 */
+ (instancetype)sharedService;

/**
 *  Called when SDLiAPManager has data to send to a TDK.
 *
 *  @param data The data to be sent.
 */
- (void)sendData:(NSData*)data;

/**
 *  Close the current external accessory session, attempt to create a new session.
 */
- (void)restartEASession;

@end
