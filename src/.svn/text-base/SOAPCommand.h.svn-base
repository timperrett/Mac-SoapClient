//
//  SOAPCommand.h
//  SOAP Client
//
//  Created by Todd Ditchendorf on 10/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SOAPCommand : NSObject {
	NSString *headerXMLString;
	NSString *endpointURI;
	NSString *bindingStyle;
	NSString *method;
	NSString *methodId;
	NSString *namespace;
	NSString *SOAPAction;
	NSArray *paramOrder;
	NSArray *paramTypes;
	NSDictionary *params;
	NSMutableDictionary *requestHeaders;
	NSMutableArray *requestHeaderOrder;
}
- (id)paramValueForKey:(NSString *)key;

- (NSString *)headerXMLString;
- (void)setHeaderXMLString:(NSString *)newStr;
- (NSString *)endpointURI;
- (void)setEndpointURI:(NSString *)newStr;
- (NSString *)bindingStyle;
- (void)setBindingStyle:(NSString *)newStr;
- (NSString *)method;
- (void)setMethod:(NSString *)newStr;
- (NSString *)methodId;
- (void)setMethodId:(NSString *)newStr;
- (NSString *)namespace;
- (void)setNamespace:(NSString *)newStr;
- (NSString *)SOAPAction;
- (void)setSOAPAction:(NSString *)newStr;
- (NSArray *)paramOrder;
- (void)setParamOrder:(NSArray *)newOrder;
- (NSArray *)paramTypes;
- (void)setParamTypes:(NSArray *)newTypes;
- (NSDictionary *)params;
- (void)setParams:(NSDictionary *)newParams;
- (NSMutableDictionary *)requestHeaders;
- (void)setRequestHeaders:(NSMutableDictionary *)newHeaders;
- (NSMutableArray *)requestHeaderOrder;
- (void)setRequestHeaderOrder:(NSMutableArray *)newOrder;
@end
