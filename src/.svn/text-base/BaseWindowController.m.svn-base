//
//  BaseWindowController.m
//  SOAP Client
//
//  Created by Todd Ditchendorf on 11/29/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BaseWindowController.h"
#import "PreferenceController.h"


@implementation BaseWindowController

- (void)makeTextViewScrollHorizontally:(NSTextView *)textView 
					  withinScrollView:(NSScrollView *)scrollView;
{
	BOOL wrap = [[NSUserDefaults standardUserDefaults] boolForKey:SCWrapTextViewTextKey];
	
	if (!wrap) {
		[scrollView setHasHorizontalScroller:YES];
		[textView setHorizontallyResizable:YES];
		[textView setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
		[[textView textContainer] setContainerSize:NSMakeSize(MAXFLOAT, MAXFLOAT)];
		[[textView textContainer] setWidthTracksTextView:NO];	
		[textView setMaxSize:NSMakeSize(MAXFLOAT, MAXFLOAT)];
	}
	
}

@end
