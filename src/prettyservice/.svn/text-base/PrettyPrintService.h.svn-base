//
//  PrettyPrintService.h
//  SOAP Client
//
//  Created by Todd Ditchendorf on 10/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol PrettyPrintService <NSObject>
- (id)initWithDelegate:(id)aDelegate;
- (void)prettyPrintXMLString:(NSString *)XMLString;
@end

@interface NSObject (PrettyPrintServiceDelegate)
- (void)prettyPrintService:(id <PrettyPrintService>)service didFinish:(NSString *)prettyString;
@end