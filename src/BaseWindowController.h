//
//  BaseWindowController.h
//  SOAP Client
//
//  Created by Todd Ditchendorf on 11/29/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BaseWindowController : NSWindowController {

}
- (void)makeTextViewScrollHorizontally:(NSTextView *)textView
					  withinScrollView:(NSScrollView *)scrollView;
@end
