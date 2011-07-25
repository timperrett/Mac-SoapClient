//
//  PrettyPrinter.m
//  AquaPath
//
//  Created by Todd Ditchendorf on 7/18/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PrettyPrinter.h"

static NSData *compiledStylesheet;
static NSString * const errorFormat = @"<b style='font-family:LucidaGrande; color:#900;'>%@</b>";

@interface PrettyPrinter (Private)
+ (void)compileXSLT;
- (NSString *)stringForError:(NSError *)err;
@end

@implementation PrettyPrinter

+ (void)initialize;
{
	[self compileXSLT];
}


+ (void)compileXSLT;
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"prettyxml" ofType:@"xsl"];
	compiledStylesheet = [[NSData alloc] initWithContentsOfFile:path];
}


- (void)dealloc;
{
	[super dealloc];
}


#pragma mark -
#pragma mark Public

- (NSString *)prettyStringForXMLString:(NSString *)XMLString;
{
	if (![XMLString length]) {
		return [NSString stringWithFormat:errorFormat, @"Null response"];
	}

	id result = nil;
	@try {
		NSError *err = nil;
		
		NSXMLDocument *doc = [[NSXMLDocument alloc] initWithXMLString:XMLString
															  options:NSXMLDocumentTidyXML
																error:nil];
		
		result = [doc objectByApplyingXSLT:compiledStylesheet arguments:nil error:&err];

		if (err) {
			return [self stringForError:err];
		}
	} 
	@catch (NSException *e) {
		return [NSString stringWithFormat:errorFormat, [e reason]];
	}

	return [result XMLString];
}


- (NSString *)stringForError:(NSError *)err;
{
	NSMutableString *str = [NSMutableString stringWithString:[err localizedDescription]];
	
	[str replaceOccurrencesOfString:@"<"
						 withString:@"&lt;"
							options:0
							  range:NSMakeRange(0, [str length])];
	
	return [NSString stringWithFormat:errorFormat, str];
}

@end
