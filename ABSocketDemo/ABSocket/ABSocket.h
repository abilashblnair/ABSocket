//
//  ABSocket.h
//  LibreChecker
//
//  Created by Abilash Cumulations on 09/05/17.
//  Copyright © 2017 Abilash Cumulations. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>


typedef enum {
    
    ABTCPSocket = 0,
    ABUDPSocket
    
}SocketConnectionType;

typedef enum {
    
    ABipv4 = 0,
    ABipv6
    
}ConnectionRefType;


@interface ABSocket : NSObject
{
    CFSocketRef ipv4cfsock;
    CFSocketRef ipv6cfsock;
}

@property (nonatomic,assign) u_int port;

@property (nonatomic,assign) SocketConnectionType socketType;
@property (nonatomic,assign) ConnectionRefType connectionRefType;

- (instancetype)initWithSocketConnectionType:(SocketConnectionType)socketType withConnectionRefType:(ConnectionRefType)refType;

- (void)openSocketForConnectionPort:(u_int)prt;

@end
