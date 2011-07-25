//
//  PreferenceController.h
//  SOAP Client
//
//  Created by Todd Ditchendorf on 11/29/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseWindowController.h"

extern NSString * const SCWrapTextViewTextKey;

@interface PreferenceController : BaseWindowController {
	IBOutlet NSButton *wrapTextViewTextButton;
}
- (IBAction)chageWrapTextViewText:(id)sender;
- (BOOL)wrapTextViewText;
@end
