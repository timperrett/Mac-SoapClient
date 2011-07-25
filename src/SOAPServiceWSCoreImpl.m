//
//  SOAPServiceWSCoreImpl.m
//  SOAP Client
//
//  Created by Todd Ditchendorf on 10/22/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SOAPServiceWSCoreImpl.h"
#import "MySOAPUtils.h"
#import <WebKit/WebKit.h>

@interface SOAPServiceWSCoreImpl (Private)
- (void)doExecuteCommand:(SOAPCommand *)command;
- (WSMethodInvocationRef)methodInvocationWith:(NSURL *)url
									   method:(NSString *)method
									namespace:(NSString *)namespace
								  HTTPHeaders:(NSDictionary *)reqHeaders
								  SOAPHeaders:(NSArray *)soapHeaders
								 bindingStyle:(CFStringRef)bindingStyle
								   paramOrder:(NSArray *)paramOrder
								   paramTypes:(NSArray *)paramTypes
									   params:(CFDictionaryRef)params;
- (void)error:(NSString *)msg;
- (void)doError:(NSString *)msg;
- (void)finish:(NSDictionary *)info;
- (void)doFinish:(NSDictionary *)info;
@end

@implementation SOAPServiceWSCoreImpl

- (id)initWithDelegate:(id)aDelegate;
{
	self = [super init];
	if (self != nil) {
		delegate = [aDelegate retain];
	}
	return self;
}


- (void)dealloc;
{
	[delegate release];
	[super dealloc];
}


#pragma mark -
#pragma mark SOAPService

- (void)executeCommand:(SOAPCommand *)command;
{
	[NSThread detachNewThreadSelector:@selector(doExecuteCommand:)
							 toTarget:self
						   withObject:command];
}


#pragma mark -
#pragma mark Private

- (void)doExecuteCommand:(SOAPCommand *)command;
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSURL *url = [NSURL URLWithString:[command endpointURI]];
	NSString *method = [command method];
	NSString *namespace = [command namespace];
	
	// setup HTTP request headers
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[command requestHeaders]];
	[dict setObject:[command SOAPAction] forKey:@"SOAPAction"];
	NSMutableDictionary *reqHeaders = [NSMutableDictionary dictionaryWithDictionary:dict];
	[reqHeaders removeObjectForKey:@" "];

	NSString *headerXMLString = [command headerXMLString];
	NSArray *soapHeaders;
	if ([headerXMLString length]) {
		soapHeaders = [NSArray arrayWithObject:headerXMLString];
	} else {
		soapHeaders = nil;
	}

	// get binding style
	CFStringRef bindingStyle = kWSSOAPStyleRPC;
	if ([[[command bindingStyle] lowercaseString] isEqualToString:@"document"]) {
		bindingStyle = kWSSOAPStyleDoc;
	}
	
	// setup soap request params
	NSArray *paramOrder  = [command paramOrder];
	NSArray *paramTypes  = [command paramTypes];
	NSDictionary *params = [command params];
		
	CFDictionaryRef cfParams = nil;
	if (params) {
		cfParams = checkDictionaryForIntegers(params);
	}	
	
	WSMethodInvocationRef soapCall = [self methodInvocationWith:url
														 method:method
													  namespace:namespace
													HTTPHeaders:reqHeaders
													SOAPHeaders:soapHeaders
												   bindingStyle:bindingStyle
													 paramOrder:paramOrder
													 paramTypes:paramTypes
														 params:cfParams];
	
	// invoke soap call
	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:
			(NSDictionary*)WSMethodInvocationInvoke(soapCall)];
	
	// check for fault
	BOOL isFault = WSMethodResultIsFault((CFDictionaryRef)result);
	[result setValue:[NSNumber numberWithBool:isFault] forKey:@"isFault"];
	
	//NSLog(@"result: %@", result);
	
	CFHTTPMessageRef res = (CFHTTPMessageRef)[result objectForKey:(id)kWSHTTPResponseMessage];
	

	if (res) {
		int resStatusCode = CFHTTPMessageGetResponseStatusCode(res);
		int count = 0;
		
		while (401 == resStatusCode || 407 == resStatusCode) {
			
			//NSDictionary *headers = [(NSDictionary *)CFHTTPMessageCopyAllHeaderFields(res) autorelease];
			//NSLog(@"headers: %@", headers);
			//NSString *line = [(NSString *)CFHTTPMessageCopyResponseStatusLine(res) autorelease];
			//NSLog(@"line: %@", line);

			// create a custom HTTP req to which we will add auth creds
			CFHTTPMessageRef req = CFHTTPMessageCreateRequest(kCFAllocatorDefault,
															  (CFStringRef)@"POST",
															  (CFURLRef)url,
															kCFHTTPVersion1_1);
			// add HTTP headers
			NSEnumerator *e = [dict keyEnumerator];
			id key, val;
			while (key = [e nextObject]) {
				val = [dict objectForKey:key];
				CFHTTPMessageSetHeaderFieldValue(req, (CFStringRef)key, (CFStringRef)val);
			}
			
			req = [delegate SOAPService:self needsAuthForRequest:req forAuthDeniedResponse:res isRetry:count];
			if (!req) {
				NSLog(@"SOAP Request not authorized by server");
				[self error:@"SOAP Request not authorized by server"];
				req = NULL;
				goto leave;
			}
			
			soapCall = [self methodInvocationWith:url
										   method:method
										namespace:namespace
									  HTTPHeaders:reqHeaders
									  SOAPHeaders:soapHeaders
									 bindingStyle:bindingStyle
									   paramOrder:paramOrder
									   paramTypes:paramTypes
										   params:cfParams];

			WSMethodInvocationSetProperty(soapCall, kWSHTTPMessage, req);

			result = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary*)WSMethodInvocationInvoke(soapCall)];
			
			// check for fault
			isFault = WSMethodResultIsFault((CFDictionaryRef)result);
			[result setValue:[NSNumber numberWithBool:isFault] forKey:@"isFault"];
						
			if (res) {
				CFRelease(res);
				res = NULL;
			}

			res = (CFHTTPMessageRef)[result objectForKey:(id)kWSHTTPResponseMessage];
			resStatusCode = CFHTTPMessageGetResponseStatusCode(res);
			count++;
			
			if (req) {
				CFRelease(req);
				req = NULL;
			}
		}
	}
	[self finish:result];

leave:
	if (res) {
		CFRelease(res);
		res = NULL;
	}
	[pool release];
}


- (CFHTTPMessageRef)askForAuth:(NSArray *)args;
{
	CFHTTPMessageRef req = (CFHTTPMessageRef)[args objectAtIndex:0];
	CFHTTPMessageRef res = (CFHTTPMessageRef)[args objectAtIndex:1];
	BOOL isRetry = [[args objectAtIndex:2] boolValue];
	
	return [delegate SOAPService:self needsAuthForRequest:req forAuthDeniedResponse:res isRetry:isRetry];
}


- (WSMethodInvocationRef)methodInvocationWith:(NSURL *)url
									   method:(NSString *)method
									namespace:(NSString *)namespace
								  HTTPHeaders:(NSDictionary *)reqHeaders
								  SOAPHeaders:(NSArray *)soapHeaders
								 bindingStyle:(CFStringRef)bindingStyle
								   paramOrder:(NSArray *)paramOrder
								   paramTypes:(NSArray *)paramTypes
									   params:(CFDictionaryRef)params;
{
	// create call
	WSMethodInvocationRef soapCall = WSMethodInvocationCreate((CFURLRef)url, (CFStringRef)method, kWSSOAP2001Protocol);
	
	// add SOAP Headers
	if ([soapHeaders count]) {
		WSMethodInvocationSetProperty(soapCall, kWSSOAPMessageHeaders, (CFArrayRef)soapHeaders);
	}
	
	// set SOAP props
	WSMethodInvocationSetProperty(soapCall, kWSSOAPMethodNamespaceURI, (CFStringRef)namespace);
	WSMethodInvocationSetProperty(soapCall, kWSSOAPBodyEncodingStyle, bindingStyle);
	
	// set params
	if (params) {
		WSMethodInvocationSetParameters(soapCall, params, (CFArrayRef)paramOrder);
	}	
	
	WSMethodInvocationSetProperty(soapCall, kWSHTTPExtraHeaders, (CFDictionaryRef)reqHeaders);
	WSMethodInvocationSetProperty(soapCall,	kWSHTTPFollowsRedirects, kCFBooleanTrue);
	
	// set debug props
	WSMethodInvocationSetProperty(soapCall, kWSDebugIncomingBody,	 kCFBooleanTrue);
	WSMethodInvocationSetProperty(soapCall, kWSDebugIncomingHeaders, kCFBooleanTrue);
	WSMethodInvocationSetProperty(soapCall, kWSDebugOutgoingBody,	 kCFBooleanTrue);
	WSMethodInvocationSetProperty(soapCall, kWSDebugOutgoingHeaders, kCFBooleanTrue);

	// add custom serializer
	WSMethodInvocationAddSerializationOverride(soapCall,
											   CFArrayGetTypeID(),
											   (WSMethodInvocationSerializationProcPtr)myMethodInvocationSerializationProcFunc,
											   (WSClientContext *)NULL);
	
	return soapCall;
}


- (void)error:(NSString *)msg;
{
	[self performSelectorOnMainThread:@selector(doError:)
						   withObject:msg
						waitUntilDone:NO];
}


- (void)doError:(NSString *)msg;
{
	[delegate SOAPService:self didError:msg];
}


- (void)finish:(NSDictionary *)info;
{
	[self performSelectorOnMainThread:@selector(doFinish:)
						   withObject:info
						waitUntilDone:NO];
}


- (void)doFinish:(NSDictionary *)info;
{
	[delegate SOAPService:self didFinish:info];
}


@end
