//
//  MACHashing.m
//  Punch Clock
//
//  Created by Matt Croxson on 15/06/13.
//  Copyright (c) 2013 Macro Interactive. All rights reserved.
//

#import "MIHashing.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation MIHashing

+ (NSString *) hashForString:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

+ (BOOL)compareHash: (NSString *)hash withHash: (NSString *)compareHash
{
    BOOL compareResult;
    
    compareResult = [hash isEqualToString:compareHash];
    
    return compareResult;
}

@end
