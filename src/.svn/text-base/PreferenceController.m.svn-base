//
//  PreferenceController.m
//  SOAP Client
//
//  Created by Todd Ditchendorf on 11/29/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PreferenceController.h"

NSString * const SCWrapTextViewTextKey = @"wrapTextViewText";

@implementation PreferenceController

- (id)init;
{
	self = [super initWithWindowNibName:@"PreferenceWindow"];
	if (self != nil) {
		
	}
	return self;
}


- (void)windowDidLoad;
{
	[wrapTextViewTextButton setState:[self wrapTextViewText]];
}


- (IBAction)chageWrapTextViewText:(id)sender;
{
	[[NSUserDefaults standardUserDefaults] setBool:[wrapTextViewTextButton state] 
											forKey:SCWrapTextViewTextKey];
}


- (BOOL)wrapTextViewText;
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:SCWrapTextViewTextKey];
}

@end
