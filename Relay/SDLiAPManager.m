//
//  SDLiAPManager.m
//  Relay
//

#import "SDLiAPManager.h"

#import "EASession+Streams.h"
#import "NSObject+Notifications.h"

#import <ExternalAccessory/ExternalAccessory.h>
#import <UIKit/UIKit.h>

static NSString* const ControlProtocolString = @"com.smartdevicelink.prot0";
static NSString* const IndexedProtocolString = @"com.smartdevicelink.prot%i";
static NSString* const LegacyProtocolString = @"com.ford.sync.prot0";

@interface SDLiAPManager () <NSStreamDelegate>

@property BOOL protocolRerouted;
@property (nonatomic, strong) EASession* session;

@property dispatch_queue_t iAPManagerQueue;

@end

@implementation SDLiAPManager
+ (instancetype)sharedService {
    static SDLiAPManager *sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedService = [[SDLiAPManager alloc] init];
    });

    return sharedService;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        _protocolRerouted = NO;

        // register for EAAccessory notifications
        [self addSelfObserverForNotificationNamed:EAAccessoryDidConnectNotification
                                         selector:@selector(accessoryDidConnect:)];
        [self addSelfObserverForNotificationNamed:EAAccessoryDidDisconnectNotification
                                         selector:@selector(accessoryDidDisconnect:)];
        [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];

        // monitor battery state
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
        [self addSelfObserverForNotificationNamed:UIDeviceBatteryStateDidChangeNotification
                                         selector:@selector(batteryStateChanged:)];

        // attempt to connect on app start
        [self performSelector:@selector(sdl_connectToEAOnAppStart) withObject:nil afterDelay:2.0];

        self.iAPManagerQueue = dispatch_queue_create("com.queue.iapManager", NULL);
    }

    return self;
}

#pragma mark - Notifications
- (void)accessoryDidConnect:(NSNotification *)notification {
    [self.delegate iAPManagerUSBConnected:self];
    _session = [self sdl_openSessionForProtocol:ControlProtocolString];
}

- (void)accessoryDidDisconnect:(NSNotification *)notification {
    [self sdl_closeSession];
    [self.delegate iAPManagerUSBDisconnected:self];
}

- (void)batteryStateChanged:(NSNotification*)notification {
    if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateUnplugged) {
        [self sdl_closeSession];
        [self.delegate iAPManagerUSBDisconnected:self];
        _protocolRerouted = NO;
    } else if ([[UIDevice currentDevice] batteryState] != UIDeviceBatteryStateUnplugged
               && !_session) {
        _session = [self sdl_openSessionForProtocol:ControlProtocolString];
        if (_session) {
            [self.delegate iAPManagerUSBConnected:self];
        }
    }
}

#pragma mark - Public Functions
- (void)sendData:(NSData *)data {
    dispatch_async(self.iAPManagerQueue, ^{
        NSData *localData = [[NSData alloc] initWithData:data];
        
        while (localData != nil) {
            if (_session.outputStream.hasSpaceAvailable) {
                [_session.outputStream write:[localData bytes] maxLength:[localData length]];
                localData = nil;
            }
        }
    });
}

- (void)restartEASession {
    if (_session) {
        [self sdl_closeSession];
    }
    
    if ([[UIDevice currentDevice] batteryState] != UIDeviceBatteryStateUnplugged && _session == nil) {
        _session = [self sdl_openSessionForProtocol:ControlProtocolString];
    }
}

#pragma mark - Delegates
#pragma mark NSStream
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable:
            [self sdl_processIncomingBytesForStream:aStream];
            break;
        case NSStreamEventEndEncountered:
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            break;
        case NSStreamEventNone:
        case NSStreamEventOpenCompleted:
        case NSStreamEventHasSpaceAvailable:
        case NSStreamEventErrorOccurred:
        default:
            break;
    }
}


#pragma mark - Private
#pragma mark Helpers
- (void)sdl_connectToEAOnAppStart {
    if ([[UIDevice currentDevice] batteryState] != UIDeviceBatteryStateUnplugged) {
        if ((_session = [self sdl_openSessionForProtocol:ControlProtocolString])) {
            [self.delegate iAPManagerUSBConnected:self];
        }
    }
}

- (void)sdl_processIncomingBytesForStream:(NSStream *)aStream {
    while ([_session.inputStream hasBytesAvailable]) {
        NSMutableData *incomingEAData = nil;
        uint8_t buf[1024];
        NSUInteger len = 0;
        len = [(NSInputStream *)aStream read:buf maxLength:1024];
        NSData *recBytes = [[NSData alloc] initWithBytes:buf length:len];

        if (len) {
            if (_protocolRerouted) {
                incomingEAData = [[NSMutableData alloc] init];
                [incomingEAData appendBytes:(const void *)buf length:len];

                [self.delegate iAPManager:self didReceiveData:incomingEAData];
            } else {
                int protocol = CFSwapInt32LittleToHost(*(int *)([recBytes bytes]));
                NSString *newProtocol = [NSString stringWithFormat:IndexedProtocolString, protocol];
                [self sdl_closeSession];

                _session = [self sdl_openSessionForProtocol:newProtocol];


                [self.delegate iAPManagerDataSessionEstablished:self];
                _protocolRerouted = YES;
            }
        }
    }
}

- (EASession *)sdl_openSessionForProtocol:(NSString *)protocolString {
    NSArray *accessories = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
    EAAccessory *accessory = nil;
    EASession *session = nil;
    
    for (EAAccessory *obj in accessories) {
        if ([[obj protocolStrings] containsObject:protocolString]) {
            accessory = obj;
            break;
        } else {
            if ([[obj protocolStrings] containsObject:LegacyProtocolString] && ![[obj protocolStrings] containsObject:ControlProtocolString]) {
                protocolString = LegacyProtocolString;
                _protocolRerouted = YES;
                accessory = obj;
                break;
            }
        }
    }
    
    if (accessory) {
        session = [[EASession alloc] initWithAccessory:accessory
                                           forProtocol:protocolString];
        if (session) {
            [session openStreamsWithDelegate:self];
        }
        
        if ([protocolString isEqualToString:ControlProtocolString]) {
            [self.delegate iAPManagerControlSessionEstablished:self];
        } else {
            [self.delegate iAPManagerDataSessionEstablished:self];
        }
    }
    
    accessory = nil;
    
    return session;
}

- (void)sdl_closeSession {
    [_session closeStreams];
    
    _protocolRerouted = NO;
    _session = nil;
}

@end
