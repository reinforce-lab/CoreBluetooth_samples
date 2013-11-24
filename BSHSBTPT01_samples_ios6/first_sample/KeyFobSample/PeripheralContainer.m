//
//  PeripheralContainer.m
//  KeyFobSample
//
//  Created by akihiro uehara on 2013/03/21.
//  Copyright (c) 2013年 wa-fu-u, LLC. All rights reserved.
//

#import "PeripheralContainer.h"

@implementation PeripheralContainer
@synthesize RSSI;
@synthesize peripheral;

+(BOOL)contains:(NSSet *)containers peripheral:(CBPeripheral *)peripheral {
    for(PeripheralContainer *c in containers) {
        if(c.peripheral == peripheral) return YES;
    }
    return NO;
}

+(NSSet *)union:(NSSet *)a b:(NSSet *)b {
    NSMutableSet *dst = [[NSMutableSet alloc] init];
    NSMutableSet *p   = [[NSMutableSet alloc] init];

    for(PeripheralContainer *c in a) {
        if(![p containsObject:c.peripheral]) {
            [p addObject:c.peripheral];
            [dst addObject:c];
        }
    }
    for(PeripheralContainer *c in b) {
        if(![p containsObject:c.peripheral]) {
            [p addObject:c.peripheral];
            [dst addObject:c];
        }
    }
    return dst;
}
@end
