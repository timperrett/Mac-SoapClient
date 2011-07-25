//
//  ComplexType.m
//  SOAP Client
//
//  Created by Todd Ditchendorf on 11/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ComplexType.h"
#import "MySOAPUtils.h"

static NSString * const MethodName = @"fakeMethodName";
static NSString * const MethodXQuery = @"//*:fakeMethodName/*";

 static WSProtocolHandlerRef Handler;

 
@interface ComplexType (Private)
- (void)setProps:(NSMutableDictionary *)newProps;
- (void)setSerializedForm:(NSString *)newForm;
@end

@implementation ComplexType

#pragma mark -
#pragma mark NSCoding support

+ (void)initialize;
{
	Handler = WSProtocolHandlerCreate(kCFAllocatorDefault, kWSSOAP2001Protocol);
}

- (id)initWithCoder:(NSCoder *)coder;
{
	self = [super init];
	[self setProps:			[coder decodeObjectForKey:@"props"]];
	[self setPropOrder:		[coder decodeObjectForKey:@"propOrder"]];
	[self setSerializedForm:[coder decodeObjectForKey:@"serializedForm"]];
	[self setTypeName:		[coder decodeObjectForKey:@"typeName"]];
	[self setPrefix:		[coder decodeObjectForKey:@"prefix"]];
	[self setLocalName:		[coder decodeObjectForKey:@"localName"]];
	[self setNamespaceURI:	[coder decodeObjectForKey:@"namespaceURI"]];
	return self;
}


- (void)encodeWithCoder:(NSCoder *)coder;
{
	[coder encodeObject:props			forKey:@"props"];
	[coder encodeObject:propOrder		forKey:@"propOrder"];
	[coder encodeObject:serializedForm	forKey:@"serializedForm"];
	[coder encodeObject:typeName		forKey:@"typeName"];
	[coder encodeObject:prefix			forKey:@"prefix"];
	[coder encodeObject:localName		forKey:@"localName"];
	[coder encodeObject:namespaceURI	forKey:@"namespaceURI"];
}


#pragma mark -

- (id)init;
{
	self = [super init];
	if (self != nil) {
		[self setProps:[NSMutableDictionary dictionary]];
	}
	return self;
}


- (void)dealloc;
{
	[self setProps:nil];
	[self setPropOrder:nil];
	[self setTypeName:nil];
	[self setPrefix:nil];
	[self setNamespaceURI:nil];
	[self setSerializedForm:nil];
	[super dealloc];
}


#pragma mark -

- (id)valueForKey:(id)key;
{
	return [props objectForKey:key];
}


- (void)setValue:(id)value forKey:(id)key;
{
	[props setObject:value forKey:key];
}


- (NSString *)serializedForm;
{	
	NSXMLNode *ns = [NSXMLNode namespaceWithName:prefix stringValue:namespaceURI];
	NSXMLElement *el = [NSXMLNode elementWithName:localName];
	[el addNamespace:ns];
	NSXMLNode *attr = [NSXMLNode attributeWithName:@"xsi:type" URI:@"http://www.w3.org/2001/XMLSchema-instance" stringValue:[NSString stringWithFormat:@"%@:%@", prefix, typeName]];
	[el addAttribute:attr];
	NSXMLDocument *doc = [[[NSXMLDocument alloc] initWithRootElement:el] autorelease];
		
	CFDictionaryRef params = checkDictionaryForIntegers(props);
	
	
	// add custom serializer
	WSProtocolHandlerSetSerializationOverride(Handler,
											  CFArrayGetTypeID(),
											  (WSProtocolHandlerSerializationProcPtr)myProtocolHandlerSerializationProcFunc,
											  (WSClientContext *)NULL);

	NSData *data = [(id)WSProtocolHandlerCopyRequestDocument(Handler,
                                                             (CFStringRef)MethodName,
                                                             (CFDictionaryRef)params,
                                                             (CFArrayRef)propOrder,
                                                             NULL) autorelease];

	//NSString *str = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	NSXMLDocument *fakeDoc = [[[NSXMLDocument alloc] initWithData:data options:0 error:nil] autorelease];
	NSArray *els = [fakeDoc objectsForXQuery:MethodXQuery error:nil];
	NSEnumerator *e = [els objectEnumerator];
	NSXMLElement *child = nil;
	while (child = [e nextObject]) {
		[el addChild:[[child copy] autorelease]]; // ??
	}
	
	[self setSerializedForm:[doc XMLString]];
	//NSLog(@"%@", serializedForm);
	return serializedForm;
}


#pragma mark -
#pragma mark Private

// for NSCoding support -- so it can be saved
- (void)setSerializedForm:(NSString *)newForm;
{
	if (newForm != serializedForm) {
		[serializedForm autorelease];
		serializedForm = [newForm retain];
	}
}


- (void)setProps:(NSMutableDictionary *)newProps;
{
	if (newProps != props) {
		[props autorelease];
		props = [newProps retain];
	}
}


- (NSString *)typeName;
{
	return typeName;
}


- (void)setTypeName:(NSString *)newName;
{
	if (newName != typeName) {
		[typeName autorelease];
		typeName = [newName retain];
	}
}


- (NSString *)localName;
{
	return localName;
}


- (void)setLocalName:(NSString *)newName;
{
	if (newName != localName) {
		[localName autorelease];
		localName = [newName retain];
	}
}


- (NSString *)prefix;
{
	return prefix;
}


- (void)setPrefix:(NSString *)newPrefix;
{
	if (newPrefix != prefix) {
		[prefix autorelease];
		prefix = [newPrefix retain];
	}
}


- (NSString *)namespaceURI;
{
	return namespaceURI;
}


- (void)setNamespaceURI:(NSString *)nsURI;
{
	if (nsURI != namespaceURI) {
		[namespaceURI autorelease];
		namespaceURI = [nsURI retain];
	}
}


- (NSArray *)propOrder;
{
	return propOrder;
}


- (void)setPropOrder:(NSArray *)newOrder;
{
	if (newOrder != propOrder) {
		[propOrder autorelease];
		propOrder = [newOrder retain];
	}
}

@end
