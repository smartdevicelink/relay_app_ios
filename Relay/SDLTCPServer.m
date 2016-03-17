//
//  SDLTCPServer.m
//  Relay
//

#import "SDLTCPServer.h"

#import "NSStream+Connection.h"

#import <arpa/inet.h>

@interface SDLTCPServer ()

@property (strong, nonatomic) NSInputStream *inputStream;
@property (strong, nonatomic) NSOutputStream *outputStream;
@property CFSocketRef socket;
@property dispatch_queue_t tcpLinkQueue;

@end

@implementation SDLTCPServer

+ (instancetype)sharedService {
    static SDLTCPServer *sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedService = [[SDLTCPServer alloc] init];
    });

    return sharedService;
}

- (instancetype)init {
    if (self = [super init]) {
        self.tcpLinkQueue = dispatch_queue_create("com.queue.tcpLinkQueue", NULL);
    }

    return self;
}


#pragma mark Server lifecycle methods
- (void)startServer {
    CFSocketContext context = {0, (__bridge void *)self, NULL, NULL, NULL};

    self.socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, &openConnection, &context);

    SDLTCPConnection* connection = [SDLTCPConnection connection];
    
    struct sockaddr_in sin;
    
    memset(&sin, 0, sizeof(sin));
    sin.sin_len = sizeof(sin);
    sin.sin_family = AF_INET; /* address family */
    sin.sin_port = htons(connection.port);
    sin.sin_addr.s_addr = INADDR_ANY;

    // allow address/port to be reused after server is closed and restarted
    setsockopt(CFSocketGetNative(self.socket), SOL_SOCKET, SO_REUSEADDR, &(int){1}, sizeof(int));
    setsockopt(CFSocketGetNative(self.socket), SOL_SOCKET, SO_REUSEPORT, &(int){1}, sizeof(int));

    CFDataRef sincfd = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&sin, sizeof(sin));

    CFSocketSetAddress(self.socket, sincfd);
    CFRelease(sincfd);

    CFRunLoopSourceRef socketSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, self.socket, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), socketSource, kCFRunLoopDefaultMode);

    [self.delegate TCPServer:self hasAvailableConnection:connection];

    CFRelease(socketSource);
}

static void openConnection(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;

    CFSocketNativeHandle *socketNumber = (int *)data;

    CFStreamCreatePairWithSocket(kCFAllocatorDefault, *socketNumber, &readStream, &writeStream);

    SDLTCPServer *weakServer = (__bridge SDLTCPServer *)info;
    weakServer.inputStream = (__bridge_transfer NSInputStream *)readStream;
    weakServer.outputStream = (__bridge_transfer NSOutputStream *)writeStream;

    [weakServer.inputStream openStreamWithDelegate:weakServer];
    [weakServer.outputStream openStreamWithDelegate:weakServer];
    
    [weakServer.delegate TCPServerDidConnect:weakServer];
}

- (void)stopServer {
    [self.inputStream closeStream];
    [self.outputStream closeStream];

    if (self.socket) {
        CFSocketInvalidate(self.socket);
        CFRelease(self.socket);
        self.socket = nil;
    }
}


#pragma mark Handle stream events

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventNone:
        case NSStreamEventOpenCompleted:
        case NSStreamEventHasSpaceAvailable:
        case NSStreamEventErrorOccurred:
            // no-op
            break;
        case NSStreamEventHasBytesAvailable:
            [self sdl_processIncomingBytesForStream:aStream];
            break;
        case NSStreamEventEndEncountered:
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSDefaultRunLoopMode];
            [self.delegate TCPServerDidDisconnect:self];
            break;
        default: {
            break;
        }
    }
}

- (void)sdl_processIncomingBytesForStream:(NSStream *)theStream {
    uint8_t buf[1024];
    NSInteger len = 0;
    len = [(NSInputStream *)theStream read:buf maxLength:1024];
    if (len > 0) {
        NSData* data = [NSData dataWithBytes:buf length:len];

        [self.delegate TCPServer:self didReceiveData:data];
    }
}

- (void)sendData:(NSData *)data {
    dispatch_async(self.tcpLinkQueue, ^{
        NSData *localData = [[NSData alloc] initWithData:data];

        while (localData != nil) {
            if (self.outputStream.hasSpaceAvailable) {
                [self.outputStream write:[localData bytes] maxLength:[localData length]];
                localData = nil;
            }
        }
    });
}

@end
