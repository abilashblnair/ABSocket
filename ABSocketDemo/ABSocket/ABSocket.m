//
//  ABSocket.m
//  LibreChecker
//
//  Created by Abilash Cumulations on 09/05/17.
//  Copyright © 2017 Abilash Cumulations. All rights reserved.
//

#import "ABSocket.h"

CFReadStreamRef inputStream;
CFWriteStreamRef outputStream;
CFStreamClientContext streamContext;

@implementation ABSocket

- (instancetype)initWithSocketConnectionType:(SocketConnectionType)socketType withConnectionRefType:(ConnectionRefType)refType
{
    self = [super init];
    if (self) {
        self.socketType = socketType;
        self.connectionRefType = refType;
        
    }
    
    return self;
}


- (void)openSocketForConnectionPort:(u_int)prt
{
    _port = prt;
    if (_socketType == ABTCPSocket) {
        
        if (_connectionRefType == ABipv4) {
            
            ipv4cfsock  = CFSocketCreate(
                                         kCFAllocatorDefault,
                                         PF_INET,
                                         SOCK_STREAM,
                                         IPPROTO_TCP,
                                         kCFSocketAcceptCallBack  , (CFSocketCallBack)&handleCallBack, NULL);
            
        }else
        {
            ipv6cfsock = CFSocketCreate(
                                        kCFAllocatorDefault,
                                        PF_INET6,
                                        SOCK_STREAM,
                                        IPPROTO_TCP,
                                        kCFSocketAcceptCallBack  ,(CFSocketCallBack)&handleCallBack, NULL);
        }
        
        
    }else
    {
        
    }
    
    [self creatingSocketAdd];
}

- (void)creatingSocketAdd
{
    
    if (_connectionRefType == ABipv4) {
        struct sockaddr_in sin;
        
        memset(&sin, 0, sizeof(sin));
        sin.sin_len = sizeof(sin);
        sin.sin_family = AF_INET; /* Address family */
        sin.sin_port = htons(_port); /* Or a specific port */
        sin.sin_addr.s_addr= INADDR_ANY;
        
        CFDataRef sincfd = CFDataCreate(
                                        kCFAllocatorDefault,
                                        (UInt8 *)&sin,
                                        sizeof(sin));
        
        CFSocketSetAddress(ipv4cfsock, sincfd);
        CFRelease(sincfd);
    }else
    {
        
        struct sockaddr_in6 sin6;
        
        memset(&sin6, 0, sizeof(sin6));
        sin6.sin6_len = sizeof(sin6);
        sin6.sin6_family = AF_INET6; /* Address family */
        sin6.sin6_port = htons(_port); /* Or a specific port */
        sin6.sin6_addr = in6addr_any;
        
        CFDataRef sin6cfd = CFDataCreate(
                                         kCFAllocatorDefault,
                                         (UInt8 *)&sin6,
                                         sizeof(sin6));
        
        CFSocketSetAddress(ipv6cfsock, sin6cfd);
        CFRelease(sin6cfd);
    }
    [self addSocketToRunloop];
}

- (void)addSocketToRunloop
{
    if (_connectionRefType == ABipv4) {
        
        
        CFRunLoopSourceRef socketsource = CFSocketCreateRunLoopSource(
                                                                      kCFAllocatorDefault,
                                                                      ipv4cfsock,
                                                                      0);
        
        CFRunLoopAddSource(
                           CFRunLoopGetCurrent(),
                           socketsource,
                           kCFRunLoopDefaultMode);
    }else
    {
        
        CFRunLoopSourceRef socketsource6 = CFSocketCreateRunLoopSource(
                                                                       kCFAllocatorDefault,
                                                                       ipv6cfsock,
                                                                       0);
        
        CFRunLoopAddSource(
                           CFRunLoopGetCurrent(),
                           socketsource6,
                           kCFRunLoopDefaultMode);
    }
}




static void handleCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    if (kCFSocketAcceptCallBack == type) {
        // Local socket handle
        CFSocketNativeHandle nativeSocketHandle = * (CFSocketNativeHandle *) data;
        uint8_t name [SOCK_MAXADDRLEN];
        socklen_t nameLen = sizeof (name);
        if (0 != getpeername (nativeSocketHandle, (struct sockaddr *) name, & nameLen)) {
            NSLog (@"error");
            //            Exit (1);
        }
        NSLog (@ "%s connected.", inet_ntoa (((struct sockaddr_in *) name) -> sin_addr));
        
        
        CFReadStreamClientCallBack readStream = NULL;
        CFReadStreamClientCallBack writeStream = NULL;
        //CFWriteStreamRef wStream;
        // Create a socket connection can read and write
        CFStreamCreatePairWithSocket (kCFAllocatorDefault, nativeSocketHandle, &inputStream, & outputStream);
        if (inputStream && outputStream) {
            CFStreamClientContext streamContext = {0, NULL, NULL, NULL};
            if (! CFReadStreamSetClient (inputStream, kCFStreamEventHasBytesAvailable,
                                         readStream, // callback function is called when the data readable
                                         &streamContext)) {
                //                 Exit (1);
            }
            
            if (! CFReadStreamSetClient (inputStream, kCFStreamEventCanAcceptBytes, writeStream, &streamContext)) {
                //                 Exit (1);
            }
            
            CFReadStreamScheduleWithRunLoop (inputStream, CFRunLoopGetCurrent (), kCFRunLoopCommonModes);
            CFWriteStreamScheduleWithRunLoop (outputStream, CFRunLoopGetCurrent (), kCFRunLoopCommonModes);
            CFReadStreamOpen (inputStream);
            CFWriteStreamOpen (outputStream);
      ///
            
           // NSAssert((readStream != NULL && writeStream != NULL), @"Read/Write stream is null");
            
            streamContext.version = 0;
            streamContext.info = info;
            streamContext.retain = nil;
            streamContext.release = nil;
            streamContext.copyDescription = nil;
            
            CFOptionFlags readStreamEvents = kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered;
            
                readStreamEvents |= kCFStreamEventHasBytesAvailable;
            
            if (!CFReadStreamSetClient(inputStream, readStreamEvents, &ReadStreamCallback, &streamContext))
            {
               // return NO;
                NSLog(@"Read stream not set successfully");
            }
            
            CFOptionFlags writeStreamEvents = kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered;
           
                writeStreamEvents |= kCFStreamEventCanAcceptBytes;
            
            if (!CFWriteStreamSetClient(outputStream, writeStreamEvents, &WriteStreamCallback, &streamContext))
            {
                //return NO;
                NSLog(@"write stream not set successfully");
            }

        }
        else
        {
            NSLog(@"Sockect closed");
            close (nativeSocketHandle);
        }
    }
    
}


static void ReadStreamCallback (CFReadStreamRef stream, CFStreamEventType type, void *pInfo)
{
    UInt8 buff [255];
    CFReadStreamRead (stream, buff, 255);
    printf ("received:%s", buff);
}
static void WriteStreamCallback (CFWriteStreamRef stream, CFStreamEventType type, void *pInfo)
{
//    UInt8 buff [255];
//    CFWriteStreamWrite(stream, buff, 255);
//    printf ("written:%s", buff);
}


@end
