//
//  ViewController.m
//  ABSocketDemo
//
//  Created by Abilash Cumulations on 05/06/17.
//  Copyright © 2017 Abilash. All rights reserved.
//

#import "ViewController.h"
#import "ABSocket.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Do any additional setup after loading the view, typically from a nib.
    ABSocket *socket = [[ABSocket alloc]initWithSocketConnectionType:ABTCPSocket withConnectionRefType:ABipv4];
    [socket openSocketForConnectionPort:5555];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
