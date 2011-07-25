//
//  SimpleType.m
//  SOAP Client
//
//  Created by Todd Ditchendorf on 11/12/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SimpleType.h"

static NSString * const SOAP_ENC_URI = @"http://schemas.xmlsoap.org/soap/encoding/";

@interface SimpleType (Private)
- (void)setSerializedForm:(NSString *)newStr;
@end

@implementation SimpleType

+ (NSString *)prefixForTypeUri:(NSString *)typeUri;
{
	if ([typeUri isEqualToString:SOAP_ENC_URI]) {
		return @"SOAP-ENC";
	} else {
		return @"xsd";		
	}
}

- (id)initWithCoder:(NSCoder *)coder;
{
	self = [super init];
	[self setTypeUri:[coder decodeObjectForKey:@"typeUri"]];
	[self setTypeName:[coder decodeObjectForKey:@"typeName"]];
	[self setValue:[coder decodeObjectForKey:@"value"]];
	[self setLocalName:[coder decodeObjectForKey:@"localName"]];
	[self setSerializedForm:[coder decodeObjectForKey:@"serializedForm"]];
	return self;
}


- (void)encodeWithCoder:(NSCoder *)coder;
{
	[coder encodeObject:typeUri forKey:@"typeUri"];
	[coder encodeObject:typeName forKey:@"typeName"];
	[coder encodeObject:value forKey:@"value"];
	[coder encodeObject:localName forKey:@"localName"];
	[coder encodeObject:serializedForm forKey:@"serializedForm"];
}


- (void)dealloc;
{
	[self setTypeUri:nil];
	[self setTypeName:nil];
	[self setValue:nil];
	[self setLocalName:nil];
	[self setSerializedForm:nil];
	[super dealloc];
}


- (NSString *)description;
{
	return value;
}


- (NSString *)serializedForm;
{	
	NSXMLElement *el = [NSXMLNode elementWithName:localName];
	NSString *typeQName = [NSString stringWithFormat:@"%@:%@", [SimpleType prefixForTypeUri:typeUri], typeName];
	NSXMLNode *attr = [NSXMLNode attributeWithName:@"xsi:type" URI:@"http://www.w3.org/2001/XMLSchema-instance" stringValue:typeQName];
	[el addAttribute:attr];
	[el setStringValue:value];
	
	[self setSerializedForm:[el XMLString]];
	return [serializedForm retain];
}

// for NSCoding support -- so it can be saved
- (void)setSerializedForm:(NSString *)newStr;
{
	if (newStr != serializedForm) {
		[serializedForm autorelease];
		serializedForm = [newStr retain];
	}
}


- (NSString *)value;
{
	return value;
}


- (void)setValue:(NSString *)newStr;
{
	if (newStr != value) {
		[value autorelease];
		value = [newStr retain];
	}
}


- (NSString *)localName;
{
	return localName;
}


- (void)setLocalName:(NSString *)newStr;
{
	if (newStr != localName) {
		[localName autorelease];
		localName = [newStr retain];
	}
}


- (NSString *)typeName;
{
	return typeName;
}


- (void)setTypeName:(NSString *)newStr;
{
	if (newStr != typeName) {
		[typeName autorelease];
		typeName = [newStr retain];
	}
}


- (NSString *)typeUri;
{
	return typeUri;
}


- (void)setTypeUri:(NSString *)newStr;
{
	if (newStr != typeUri) {
		[typeUri autorelease];
		typeUri = [newStr retain];
	}
}


@end
