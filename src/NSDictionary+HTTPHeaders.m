//
//  NDictionary+HTTPHeaders.m
//  RESTEasy
//
//  Created by itod on 3/31/06.
//  Copyright 2006 Apple Computer. All rights reserved.
//

#import "NSDictionary+HTTPHeaders.h"
//8QzOol1QFHIYu7s9G9GFVOG8LiIN1p4+

static NSString * const Whitespace = @" ";

@implementation NSDictionary (HTTPHeaders) 

- (NSString *)serializedHTTPHeaders;
{
	NSMutableString *result = [NSMutableString string];

	id key = nil;
	NSString *value = nil;
	NSEnumerator *e = [self keyEnumerator];
	while (key = [e nextObject]) {
		if (![key isEqualToString:Whitespace]) {
			value = [self valueForKey:key];
			if ([key isEqualToString:@"User-Agent"]) {
				NSUInteger i = [value rangeOfString:@" --- "].location;
				if (NSNotFound != i) {
					value = [value substringFromIndex:i+5];
				}
			}
			[result appendFormat:@"%@: %@\n", key, value];
		}
	}

	return result;
}

@end
