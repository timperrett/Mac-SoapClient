//
//  SCDocument.m
//  SOAP Client
//
//  Created by Todd Ditchendorf on 10/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SCDocument.h"
#import "SCController.h"
#import "SOAPCommand.h"

@interface SCDocument (Private)
@end

@implementation SCDocument

- (id)init;
{
	self = [super init];
	if (self != nil) {
		controller = [[SCController alloc] initWithWindowNibName:@"SCWindow"];
	}
	return self;
}


- (void)dealloc;
{
	[controller release];
	[super dealloc];
}


- (void)makeWindowControllers;
{
	[self addWindowController:controller];
}


- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError;
{
	[controller save];
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
	[dict setObject:[[controller window] stringWithSavedFrame] forKey:@"windowFrameString"];
	if ([controller WSDLURLString]) {
		[dict setObject:[controller WSDLURLString] forKey:@"WSDLURLString"];
	}
	SOAPCommand *cmd = [controller command];
	if (!cmd) {
		cmd = [[[SOAPCommand alloc] init] autorelease];
	}
	[cmd setRequestHeaders:[controller requestHeaders]];
	[cmd setRequestHeaderOrder:[controller requestHeaderOrder]];
	[dict setObject:cmd forKey:@"command"];

    return [NSKeyedArchiver archivedDataWithRootObject:dict];
}


- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError;
{
	NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];

	[[controller window] setFrameFromString:[dict valueForKey:@"windowFrameString"]];

	NSString *WSDLURLString = [dict valueForKey:@"WSDLURLString"];
	[controller setWSDLURLString:WSDLURLString];
	if ([WSDLURLString length]) {
		[controller parseWSDL:self];
	}
	SOAPCommand *cmd = [dict valueForKey:@"command"];
	[controller setCommand:cmd];
	[controller setRequestHeaders:[cmd requestHeaders]];
	[controller setRequestHeaderOrder:[cmd requestHeaderOrder]];

	//NSLog(@"reading: %@", dict);
    return YES;
}


@end
