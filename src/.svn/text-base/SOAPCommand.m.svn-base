//
//  SOAPCommand.m
//  SOAP Client
//
//  Created by Todd Ditchendorf on 10/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SOAPCommand.h"
#import <WebKit/WebKit.h>


@implementation SOAPCommand

#pragma mark -
#pragma mark WebScripting

+ (BOOL)isKeyExcludedFromWebScript:(const char *)name
{
	return YES;
}


+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector;
{
	return [self webScriptNameForSelector:aSelector] == nil;
}


+ (NSString *)webScriptNameForSelector:(SEL)aSelector
{	
	if (@selector(endpointURI) == aSelector)
		return @"endpointURI";
	else if (@selector(bindingStyle) == aSelector)
		return @"bindingStyle";
	else if (@selector(method) == aSelector)
		return @"method";
	else if (@selector(methodId) == aSelector)
		return @"methodId";
	else if (@selector(namespace) == aSelector)
		return @"namespace";
	else if (@selector(SOAPAction) == aSelector)
		return @"soapAction";
	else if (@selector(params) == aSelector)
		return @"params";
	else if (@selector(paramOrder) == aSelector)
		return @"paramOrder";
	else if (@selector(paramValueForKey:) == aSelector)
		return @"paramValueForKey";
	else
		return nil;
}


#pragma mark -

- (id)init;
{
	self = [super init];
	if (self != nil) {
		[self setRequestHeaders:[NSMutableDictionary dictionaryWithObject:@" " forKey:@" "]];
		[self setRequestHeaderOrder:[NSMutableArray arrayWithObject:@" "]];
	}
	return self;
}


#pragma mark -
#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder;
{
	self = [super init];
	[self setHeaderXMLString:	[coder decodeObjectForKey:@"headerXMLString"]];
	[self setEndpointURI:		[coder decodeObjectForKey:@"endpointURI"]];
	[self setBindingStyle:		[coder decodeObjectForKey:@"bindingStyle"]];
	[self setMethod:			[coder decodeObjectForKey:@"method"]];
	[self setMethodId:			[coder decodeObjectForKey:@"methodId"]];
	[self setNamespace:			[coder decodeObjectForKey:@"namespace"]];
	[self setSOAPAction:		[coder decodeObjectForKey:@"SOAPAction"]];
	[self setParamOrder:		[coder decodeObjectForKey:@"paramOrder"]];
	[self setParamTypes:		[coder decodeObjectForKey:@"paramTypes"]];
	[self setParams:			[coder decodeObjectForKey:@"params"]];
	[self setRequestHeaders:	[coder decodeObjectForKey:@"requestHeaders"]];
	[self setRequestHeaderOrder:[coder decodeObjectForKey:@"requestHeaderOrder"]];
	return self;
}


- (void)encodeWithCoder:(NSCoder *)coder;
{
	[coder encodeObject:headerXMLString		forKey:@"headerXMLString"];
	[coder encodeObject:endpointURI			forKey:@"endpointURI"];
	[coder encodeObject:bindingStyle		forKey:@"bindingStyle"];
	[coder encodeObject:method				forKey:@"method"];
	[coder encodeObject:methodId			forKey:@"methodId"];
	[coder encodeObject:namespace			forKey:@"namespace"];
	[coder encodeObject:SOAPAction			forKey:@"SOAPAction"];
	[coder encodeObject:paramOrder			forKey:@"paramOrder"];
	[coder encodeObject:paramTypes			forKey:@"paramTypes"];
	[coder encodeObject:params				forKey:@"params"];
	[coder encodeObject:requestHeaders		forKey:@"requestHeaders"];
	[coder encodeObject:requestHeaderOrder	forKey:@"requestHeaderOrder"];
}


- (void)dealloc;
{
	[self setHeaderXMLString:nil];
	[self setEndpointURI:nil];
	[self setBindingStyle:nil];
	[self setMethod:nil];
	[self setMethodId:nil];
	[self setNamespace:nil];
	[self setSOAPAction:nil];
	[self setParamOrder:nil];
	[self setParamTypes:nil];
	[self setParams:nil];
	[self setRequestHeaders:nil];
	[self setRequestHeaderOrder:nil];
	[super dealloc];
}


- (NSString *)description;
{
	return [NSString stringWithFormat:@"SOAPCommand { \n\tendpointURI: '%@', \n\tbindingStyle: '%@', \n\tmethod: '%@', \n\tnamespace: '%@', \n\tSOAPAction: '%@', \n\tparamOrder: %@, \n\tparamTypes: %@, \n\tparams: %@, \n\trequestHeaderOrder: %@, \n\trequestHeaders: %@ }",
		endpointURI, bindingStyle, method, namespace, SOAPAction, paramOrder, paramTypes, params, requestHeaderOrder, requestHeaders];
}


#pragma mark -
#pragma mark Accessors

- (id)paramValueForKey:(NSString *)key;
{
	return [params objectForKey:key];
}


- (NSString *)headerXMLString;
{
	return headerXMLString;
}


- (void)setHeaderXMLString:(NSString *)newStr;
{
	if (newStr != headerXMLString) {
		[headerXMLString autorelease];
		headerXMLString = [newStr retain];
	}
}


- (NSString *)endpointURI;
{
	return endpointURI;
}


- (void)setEndpointURI:(NSString *)newStr;
{
	if (endpointURI != newStr) {
		[endpointURI autorelease];
		endpointURI = [newStr retain];
	}
}


- (NSString *)bindingStyle;
{
	return bindingStyle;
}


- (void)setBindingStyle:(NSString *)newStr;
{
	if (bindingStyle != newStr) {
		[bindingStyle autorelease];
		bindingStyle = [newStr retain];
	}
}


- (NSString *)method;
{
	return method;
}


- (void)setMethod:(NSString *)newStr;
{
	if (method != newStr) {
		[method autorelease];
		method = [newStr retain];
	}
}


- (NSString *)methodId;
{
	return methodId;
}


- (void)setMethodId:(NSString *)newStr;
{
	if (methodId != newStr) {
		[methodId autorelease];
		methodId = [newStr retain];
	}
}


- (NSString *)namespace;
{
	return namespace;
}


- (void)setNamespace:(NSString *)newStr;
{
	if (namespace != newStr) {
		[namespace autorelease];
		namespace = [newStr retain];
	}
}


- (NSString *)SOAPAction;
{
	return SOAPAction;
}


- (void)setSOAPAction:(NSString *)newStr;
{
	if (SOAPAction != newStr) {
		[SOAPAction autorelease];
		SOAPAction = [newStr retain];
	}
}


- (NSArray *)paramOrder;
{
	return paramOrder;
}


- (void)setParamOrder:(NSArray *)newOrder;
{
	if (paramOrder != newOrder) {
		[paramOrder autorelease];
		paramOrder = [newOrder retain];
	}
}


- (NSArray *)paramTypes;
{
	return paramTypes;
}


- (void)setParamTypes:(NSArray *)newTypes;
{
	if (paramTypes != newTypes) {
		[paramTypes autorelease];
		paramTypes = [newTypes retain];
	}
}


- (NSDictionary *)params;
{
	return params;
}


- (void)setParams:(NSDictionary *)newParams;
{
	if (params != newParams) {
		[params autorelease];
		params = [newParams retain];
	}
}


- (NSMutableDictionary *)requestHeaders;
{
	return requestHeaders;
}


- (void)setRequestHeaders:(NSMutableDictionary *)newHeaders;
{
	if (requestHeaders != newHeaders) {
		[requestHeaders autorelease];
		requestHeaders = [newHeaders retain];
	}
}


- (NSMutableArray *)requestHeaderOrder;
{
	return requestHeaderOrder;
}


- (void)setRequestHeaderOrder:(NSMutableArray *)newOrder;
{
	if (requestHeaderOrder != newOrder) {
		[requestHeaderOrder autorelease];
		requestHeaderOrder = [newOrder retain];
	}
}

@end
