//
//  WSDLParsingService.h
//  SOAP Client
//
//  Created by Todd Ditchendorf on 10/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol WSDLParsingService <NSObject>
- (id)initWithDelegate:(id)aDelegate;
- (void)parseWSDL:(NSData *)WSDLData;
@end

@interface NSObject (WSDLParsingServiceDelegate)
- (void)WSDLParsingService:(id <WSDLParsingService>)service didFinish:(NSString *)HTMLString;
- (void)WSDLParsingService:(id <WSDLParsingService>)service didError:(NSString *)msg;
@end
