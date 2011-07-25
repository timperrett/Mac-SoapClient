//
//  SOAPService.h
//  SOAP Client
//
//  Created by Todd Ditchendorf on 10/22/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SOAPCommand.h"

@protocol SOAPService <NSObject>
- (id)initWithDelegate:(id)aDelegate;
- (void)executeCommand:(SOAPCommand *)command;
@end

@interface NSObject (SOAPServiceDelegate)
- (void)SOAPService:(id <SOAPService>)service didFinish:(NSDictionary *)info;
- (void)SOAPService:(id <SOAPService>)service didError:(NSString *)msg;
- (CFHTTPMessageRef)SOAPService:(id <SOAPService>)service needsAuthForRequest:(CFHTTPMessageRef)req forAuthDeniedResponse:(CFHTTPMessageRef)res isRetry:(BOOL)isRetry;
@end
