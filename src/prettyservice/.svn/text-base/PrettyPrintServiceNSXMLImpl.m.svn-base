//
//  PrettyPrintServiceNSXMLImpl.m
//  AquaPath
//
//  Created by Todd Ditchendorf on 7/18/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PrettyPrintServiceNSXMLImpl.h"

static NSData *compiledStylesheet;

@interface PrettyPrintServiceNSXMLImpl (Private)
+ (void)compileXSLT;
@end

@implementation PrettyPrintServiceNSXMLImpl

+ (void)initialize;
{
	[self compileXSLT];
}


+ (void)compileXSLT;
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"prettyxml" ofType:@"xsl"];
	compiledStylesheet = [[NSData alloc] initWithContentsOfFile:path];
}


- (id)initWithDelegate:(id)aDelegate;
{
	self = [super init];
	if (self != nil) {
		delegate = [aDelegate retain];
	}
	return self;
}


- (void)dealloc;
{
	[delegate release]l
	[super dealloc];
}


#pragma mark -
#pragma mark Public

- (void)prettyPrintXMLString:(NSString *)XMLString;
{
	[NSThread detachNewThreadSelector:@selector(doPrettyPrintXMLString:)
							 toTarget:self
						   withObject:XMLString];
}


- (void)doPrettyPrintXMLString:(NSString *)XMLString;
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSXMLDocument *doc = [[NSXMLDocument alloc] initWithXMLString:XMLString
														  options:NSXMLDocumentTidyHTML
															error:nil];

	id res = [doc objectByApplyingXSLT:compiledStylesheet arguments:nil error:nil];
	//NSLog(@"res : %@", res);
	//NSLog(@"[res class] : %@", [res class]);

	[self performSelectorOnMainThread:selector(finish:)
						   withObject:[res XMLString]
						waitUntilDone:NO];
	
	[pool release];
}


- (void)finish:(NSString *)prettyString;
{
	[delegate prettyPrintService:self didFinish:prettyString];
}

@end
