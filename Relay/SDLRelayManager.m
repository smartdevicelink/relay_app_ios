//
//  SDLRelayManager.m
//  Relay
//

#import "SDLRelayManager.h"
#import "SDLiAPManager.h"
#import "SDLTCPServer.h"

NSString* const SDLNotificationInfoKey = @"SDLNotificationInfoKey";

NSString* const SDLRelayManagerUSBConnectedNotification = @"com.smartdevicelink.sdlrelaymanager.usbconnected";
NSString* const SDLRelayManagerUSBDisconnectedNotification = @"com.smartdevicelink.sdlrelaymanager.usbdisconnected";
NSString* const SDLRelayManagerControlSessionEstablishedNotification = @"com.smartdevicelink.sdlrelaymanager.controlsessionestablished";
NSString* const SDLRelayManagerDataSessionEstablishedNotification = @"com.smartdevicelink.sdlrelaymanager.datasessionestablished";

NSString* const SDLRelayManagerTCPServerStartedNotification = @"com.smartdevicelink.sdlrelaymanager.tcpserverstarted";
NSString* const SDLRelayManagerTCPServerConnectedNotification = @"com.smartdevicelink.sdlrelaymanager.tcpserverconnected";
NSString* const SDLRelayManagerTCPServerDisconnectedNotification = @"com.smartdevicelink.sdlrelaymanager.tcpserverdisconnected";

@interface SDLRelayManager () <SDLiAPManagerDelegate, SDLTCPServerDelegate>

@end

@implementation SDLRelayManager

+ (instancetype)sharedManager {
    static SDLRelayManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[SDLRelayManager alloc] init];
    });

    return sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
        [SDLTCPServer sharedService].delegate = self;
        [SDLiAPManager sharedService].delegate = self;
    }

    return self;
}

#pragma mark - Private
- (void)sdl_postNotification:(NSString *)name info:(id)info {
    NSDictionary *userInfo = nil;
    if (info != nil) {
        userInfo = @{
            SDLNotificationInfoKey : info
        };
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:name
                                                        object:self
                                                      userInfo:userInfo];
}

#pragma mark - Public Functions
- (void)startTCPServer {
    [[SDLTCPServer sharedService] startServer];
}

- (void)stopTCPServer {
    [[SDLTCPServer sharedService] stopServer];
    [[SDLiAPManager sharedService] restartEASession];
}

#pragma mark - Delegates
#pragma mark SDLTCPServer
- (void)TCPServer:(SDLTCPServer *)server hasAvailableConnection:(SDLTCPConnection *)connection {
    [self sdl_postNotification:SDLRelayManagerTCPServerStartedNotification
                          info:connection];
}

- (void)TCPServerDidConnect:(SDLTCPServer *)server {
    [self sdl_postNotification:SDLRelayManagerTCPServerConnectedNotification
                          info:nil];
}

- (void)TCPServerDidDisconnect:(SDLTCPServer *)server {
    [[SDLiAPManager sharedService] restartEASession];
    [self sdl_postNotification:SDLRelayManagerTCPServerDisconnectedNotification
                          info:nil];
}

- (void)TCPServer:(SDLTCPServer *)server didReceiveData:(NSData *)data {
    [[SDLiAPManager sharedService] sendData:data];
}

#pragma mark SDLiAPManager
- (void)iAPManager:(SDLiAPManager *)iAPManager didReceiveData:(NSData *)data {
    [[SDLTCPServer sharedService] sendData:data];
}

- (void)iAPManagerUSBConnected:(SDLiAPManager *)iAPManager {
    [self sdl_postNotification:SDLRelayManagerUSBConnectedNotification
                          info:nil];
}

- (void)iAPManagerUSBDisconnected:(SDLiAPManager *)iAPManager {
    [self sdl_postNotification:SDLRelayManagerUSBDisconnectedNotification
                          info:nil];
}

- (void)iAPManagerControlSessionEstablished:(SDLiAPManager *)iAPManager {
    [self sdl_postNotification:SDLRelayManagerControlSessionEstablishedNotification
                          info:nil];
}

- (void)iAPManagerDataSessionEstablished:(SDLiAPManager *)iAPManager {
    [self sdl_postNotification:SDLRelayManagerDataSessionEstablishedNotification
                          info:nil];
}

@end
