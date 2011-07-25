//
//  ComplexType.h
//  SOAP Client
//
//  Created by Todd Ditchendorf on 11/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ComplexType : NSObject {
	NSString *typeName;
	NSString *namespaceURI;
	NSString *prefix;
	NSString *localName;
	NSMutableDictionary *props;
	NSMutableArray *propOrder;
	NSString *serializedForm;
}
- (NSString *)typeName;
- (void)setTypeName:(NSString *)newName;
- (NSString *)prefix;
- (void)setPrefix:(NSString *)newPrefix;
- (NSString *)localName;
- (void)setLocalName:(NSString *)newName;
- (NSString *)namespaceURI;
- (void)setNamespaceURI:(NSString *)nsURI;
- (NSString *)serializedForm;
- (NSArray *)propOrder;
- (void)setPropOrder:(NSArray *)newOrder;
@end
