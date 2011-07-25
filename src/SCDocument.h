//
//  SCDocument.h
//  SOAP Client
//
//  Created by Todd Ditchendorf on 10/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SCController;

@interface SCDocument : NSDocument {
	SCController *controller;
}

@end
