//
//  SDLStatusViewController.m
//  Relay
//

#import "SDLStatusViewController.h"
#import "SDLRelayManager.h"
#import "SDLTCPConnection.h"
#import "SDLLabel.h"

#import "NSObject+Notifications.h"

static NSString* const SDLStatusAvailable = @"Available";
static NSString* const SDLStatusClosed = @"Closed";
static NSString* const SDLStatusConnected = @"Connected";
static NSString* const SDLStatusConnecting = @"Connecting…";
static NSString* const SDLStatusDisconnected = @"Disconnected";
static NSString* const SDLStatusError = @"Error";
static NSString* const SDLStatusNotStarted = @"Not Started";

@interface SDLStatusViewController ()

@property (nonatomic, readonly) SDLRelayManager *sharedManager;

@property (weak) IBOutlet UIScrollView* scrollView;
@property (nonatomic, weak) IBOutlet SDLLabel *usbStatusLabel;
@property (nonatomic, weak) IBOutlet SDLLabel *eaStatusLabel;
@property (nonatomic, weak) IBOutlet SDLLabel *serverStatusLabel;
@property (nonatomic, weak) IBOutlet SDLLabel *serverAddressLabel;
@property (nonatomic, weak) IBOutlet SDLLabel *serverPortLabel;
@property (nonatomic, weak) IBOutlet SDLLabel *sdlStatusLabel;
@property (nonatomic, weak) IBOutlet UISwitch *serverSwitch;

@end

@implementation SDLStatusViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.title = @"Status";

        [self sdl_registerForNotifications];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self usbDisconnected:nil];
    [self tcpServerDisconnected:nil];
    [self serverToggleAction:nil];
}

- (void)sdl_registerForNotifications {
    [self addSelfObserverForNotificationNamed:SDLRelayManagerUSBConnectedNotification
                                     selector:@selector(usbConnected:)];
    [self addSelfObserverForNotificationNamed:SDLRelayManagerUSBDisconnectedNotification
                                     selector:@selector(usbDisconnected:)];
    [self addSelfObserverForNotificationNamed:SDLRelayManagerDataSessionEstablishedNotification
                                     selector:@selector(dataSessionEstablished:)];
    [self addSelfObserverForNotificationNamed:SDLRelayManagerControlSessionEstablishedNotification
                                     selector:@selector(controlSessionEstablished:)];
    [self addSelfObserverForNotificationNamed:SDLRelayManagerTCPServerStartedNotification
                                     selector:@selector(tcpServerStarted:)];
    [self addSelfObserverForNotificationNamed:SDLRelayManagerTCPServerConnectedNotification
                                     selector:@selector(tcpServerConnected:)];
    [self addSelfObserverForNotificationNamed:SDLRelayManagerTCPServerDisconnectedNotification
                                     selector:@selector(tcpServerDisconnected:)];
}

#pragma mark - Actions
- (IBAction)serverToggleAction:(id)selector {
    if ([_serverSwitch isOn]) {
        [self.relayManager startTCPServer];
    } else {
        [self.relayManager stopTCPServer];
        [_serverStatusLabel updateToErrorStateWithString:SDLStatusNotStarted];
        _serverAddressLabel.text = @"";
        _serverPortLabel.text = @"";
    }
}

#pragma mark - Notifications
- (void)usbConnected:(NSNotification*)notification {
    [_usbStatusLabel updateToSuccessStateWithString:SDLStatusConnected];
}

- (void)usbDisconnected:(NSNotification*)notification {
    [_usbStatusLabel updateToErrorStateWithString:SDLStatusDisconnected];
    [_eaStatusLabel updateToErrorStateWithString:SDLStatusClosed];
}

- (void)controlSessionEstablished:(NSNotification*)notification {
    [_eaStatusLabel updateToWaitingStateWithString:SDLStatusConnecting];
}

- (void)dataSessionEstablished:(NSNotification*)notification {
    [_eaStatusLabel updateToSuccessStateWithString:SDLStatusConnected];
}

- (void)tcpServerStarted:(NSNotification *)notification {
    NSString* ip = SDLStatusError;
    NSString* port = SDLStatusError;
    
    id notificationObject = notification.userInfo[SDLNotificationInfoKey];
    if ([notificationObject isKindOfClass:[SDLTCPConnection class]]) {
        SDLTCPConnection* connection = (SDLTCPConnection*)notificationObject;
        ip = connection.ipAddress;
        port = [NSString stringWithFormat:@"%lu", (unsigned long)connection.port];
    }
    
    [_serverStatusLabel updateToSuccessStateWithString:SDLStatusAvailable];
    _serverAddressLabel.text = ip;
    _serverPortLabel.text = port;
}

- (void)tcpServerConnected:(NSNotification *)notification {
    [_sdlStatusLabel updateToSuccessStateWithString:SDLStatusConnected];
}

- (void)tcpServerDisconnected:(NSNotification *)notification {
    [_sdlStatusLabel updateToErrorStateWithString:SDLStatusDisconnected];
}

#pragma mark - Private
#pragma mark Getters
- (SDLRelayManager*)relayManager {
    return [SDLRelayManager sharedManager];
}

@end
