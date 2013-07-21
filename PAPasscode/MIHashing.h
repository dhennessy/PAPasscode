//
//  MACHashing.h
//  Punch Clock
//
//  Created by Matt Croxson on 15/06/13.
//  Copyright (c) 2013 Macro Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MIHashing : NSObject

+ (NSString *) hashForString:(NSString*)input;
+ (BOOL)compareHash: (NSString *)hash withHash: (NSString *)compareHash;

@end
