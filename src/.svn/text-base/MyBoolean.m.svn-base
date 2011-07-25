//
//  MyBoolean.m
//  SOAP Client
//
//  Created by Todd Ditchendorf on 11/3/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "MyBoolean.h"


@implementation MyBoolean

- (id)initWithCoder:(NSCoder *)coder;
{
	self = [super init];
	[self setBoolValue:[coder decodeBoolForKey:@"boolValue"]];
	return self;
}


- (void)encodeWithCoder:(NSCoder *)coder;
{
	[coder encodeBool:boolValue forKey:@"boolValue"];
}


- (NSString *)description;
{
	return (boolValue) ? @"true" : @"false";
}


- (BOOL)boolValue;
{
	return boolValue;
}


- (void)setBoolValue:(BOOL)yn;
{
	boolValue = yn;
}

@end
