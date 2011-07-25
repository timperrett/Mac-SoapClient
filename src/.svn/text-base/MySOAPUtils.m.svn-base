/*
 *  MySOAPUtils.c
 *  SOAP Client
 *
 *  Created by Todd Ditchendorf on 11/7/06.
 *  Copyright 2006 __MyCompanyName__. All rights reserved.
 *
 */

#import "MySOAPUtils.h"
#import "ComplexType.h"
#import "MyBoolean.h"
#import "SimpleType.h"
#import <WebKit/WebKit.h>

CFDictionaryRef checkDictionaryForIntegers(NSDictionary *paramsIn)
{
	
	//leaking!!!
	CFMutableDictionaryRef result = CFDictionaryCreateMutableCopy(kCFAllocatorDefault,
																  [paramsIn count],
																  (CFDictionaryRef)paramsIn);
	NSString *key = nil;
	NSString *desc = nil;
	NSRange r = NSMakeRange(0, 0);
	id value = nil;
	NSEnumerator *e = [paramsIn keyEnumerator];
	while (key = [e nextObject]) {
		value = [paramsIn objectForKey:key];
		if ([value isKindOfClass:[NSNumber class]]) {
			desc = [value description];
			r = [desc rangeOfString:@"."];
			if (r.length) {
				CFDictionarySetValue(result,key,value);
			} else {
				int j = [value intValue];
				CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt32Type,&j);
				CFDictionarySetValue(result, key, num);
                CFRelease(num);
			}
		} else if ([value isKindOfClass:[MyBoolean class]]) {
			CFBooleanRef b = ([value boolValue]) ? kCFBooleanTrue : kCFBooleanFalse;
			CFDictionarySetValue(result, key, b);
		} else if ([value isKindOfClass:[NSDictionary class]]) {
			value = (NSDictionary *)checkDictionaryForIntegers(value);
			CFDictionarySetValue(result, key, value);
		} else if ([value isKindOfClass:[NSArray class]]) {
			value = (NSArray *)checkArrayForIntegers(value);
			CFDictionarySetValue(result, key, value);
		}
	}
	
	//[paramsIn release];
	return result;
	
}


CFArrayRef checkArrayForIntegers(NSArray *paramsIn)
{
	CFMutableArrayRef result = CFArrayCreateMutableCopy(kCFAllocatorDefault,
														[paramsIn count],
														(CFArrayRef)paramsIn);
    [(id)result autorelease];

	NSString *desc = nil;
	NSRange r = NSMakeRange(0, 0);
	CFIndex index = 0;
	id value = nil;
	NSEnumerator *e = [paramsIn objectEnumerator];
	while (value = [e nextObject]) {
		if ([value isKindOfClass:[NSNumber class]]) {
			desc = [value description];
			r = [desc rangeOfString:@"."];
			if (r.length) {
				CFArraySetValueAtIndex(result,index,value);
			} else {
				int j = [value intValue];
				CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt32Type,&j);
				CFArraySetValueAtIndex(result, index, num);
                CFRelease(num);
			}
		} else if ([value isKindOfClass:[MyBoolean class]]) {
			CFBooleanRef b = ([value boolValue]) ? kCFBooleanTrue : kCFBooleanFalse;
			CFArraySetValueAtIndex(result, index, b);
		} else if ([value isKindOfClass:[NSDictionary class]]) {
			value = (NSDictionary *)checkDictionaryForIntegers(value);
			CFArraySetValueAtIndex(result, index, value);
		} else if ([value isKindOfClass:[NSArray class]]) {
			value = (NSArray *)checkArrayForIntegers(value);
			CFArraySetValueAtIndex(result, index, value);
		}
		index++;
	}
	
	//[paramsIn release];
	return result;
}


static CFStringRef doMySerializationProcFunc(CFTypeRef obj)
{
	// check to see if this is a wrapper for our custom type. if so, add custom serialization
	NSArray *a = (NSArray *)obj;
	if (1 == [a count]) {
		id customObj = [a objectAtIndex:0];
		if (customObj && [customObj isMemberOfClass:[ComplexType class]]) {
			// ok we found it. do custom serialization
			return (CFStringRef)[customObj serializedForm];
		} else if (customObj && [customObj isMemberOfClass:[SimpleType class]]) {
			// found a long
			return (CFStringRef)[customObj serializedForm];
		}
	}
	// didn't find custom type. return NULL to execute default array serializer
	return NULL;
}


CFStringRef myProtocolHandlerSerializationProcFunc(WSProtocolHandlerRef handler, CFTypeRef obj, void *info)
{
	return doMySerializationProcFunc(obj);
}


CFStringRef myMethodInvocationSerializationProcFunc(WSMethodInvocationRef invocation, CFTypeRef obj, void *info)
{
	return doMySerializationProcFunc(obj);
}