//
//  WSDLViewController.m
//  SOAP Client
//
//  Created by Todd Ditchendorf on 11/29/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "WSDLViewController.h"

@interface WSDLViewController (Private)
- (void)setupFonts;
@end

@implementation WSDLViewController

- (id)init;
{
	self = [super initWithWindowNibName:@"WSDLViewWindow"];
	if (self != nil) {
		
	}
	return self;
}


- (void) dealloc {
	[self setWSDLString:nil];
	[self setTitle:nil];
	[super dealloc];
}


#pragma mark -

- (void)awakeFromNib;
{
	[self setupFonts];
	[self makeTextViewScrollHorizontally:textView
						withinScrollView:scrollView];
}


- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
	return title;
}


#pragma mark -
#pragma mark Private

- (void)setupFonts;
{
	NSFont *monaco = [NSFont fontWithName:@"Monaco" size:10.];
	[textView setFont:monaco];
}


#pragma mark -
#pragma mark Accessors

- (NSString *)WSDLString;
{
	return WSDLString;
}


- (void)setWSDLString:(NSString *)newStr;
{
	if (WSDLString != newStr) {
		[WSDLString autorelease];
		WSDLString = [newStr retain];
	}
}


- (NSString *)title;
{
	return title;
}


- (void)setTitle:(NSString *)newStr;
{
	if (title != newStr) {
		[title autorelease];
		title = [newStr retain];
	}
}


@end
