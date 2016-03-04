//
//  SDLRelayManager.h
//  Relay
//

#import <Foundation/Foundation.h>

// Notification User Info Key
/**
 *  User Info key for Notifications.
 */
extern NSString* const SDLNotificationInfoKey;

/**
 *  Notification when USB is connected.
 */
extern NSString* const SDLRelayManagerUSBConnectedNotification;

/**
 *  Notification when USB is disonnected.
 */
extern NSString* const SDLRelayManagerUSBDisconnectedNotification;

/**
 *  Notification when Control Session is established.
 */
extern NSString* const SDLRelayManagerControlSessionEstablishedNotification;

/**
 *  Notification when Data Session is established.
 */
extern NSString* const SDLRelayManagerDataSessionEstablishedNotification;

/**
 *  Notification when TCP Server has been started.
 */
extern NSString* const SDLRelayManagerTCPServerStartedNotification;

/**
 *  Notification when TCP Server is connected.
 */
extern NSString* const SDLRelayManagerTCPServerConnectedNotification;

/**
 *  Notification when TCP Server is disconnected.
 */
extern NSString* const SDLRelayManagerTCPServerDisconnectedNotification;

/**
 *  Relay manager routes data and updates status'
 */
@interface SDLRelayManager : NSObject

/**
 *  Create the RelayManager object
 *
 *  @return Instance of RelayManager
 */
+ (instancetype)sharedManager;

/**
 *  Start TCP Server.
 */
- (void)startTCPServer;

/**
 *  Stop TCP Server.
 */
- (void)stopTCPServer;

@end
