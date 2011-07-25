//
//  SCController.h
//  SOAP Client
//
//  Created by Todd Ditchendorf on 10/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseWindowController.h"

@class WebView;
@class SOAPCommand;
@protocol WSDLParsingService;
@protocol SOAPService;
@class PrettyPrinter;

@interface SCController : BaseWindowController <NSComboBoxCellDataSource> {
	IBOutlet WebView *WSDLWebView;
	IBOutlet NSTextField *WSDLTextField;
	IBOutlet NSTableView *headersTable;
	IBOutlet NSTabView *topTabView;
	IBOutlet NSTextView *headerXMLTextView;
	IBOutlet NSTabView *tabView;
	IBOutlet NSTextView *requestTextView;
	IBOutlet NSTextView *responseTextView;
	IBOutlet NSScrollView *requestScrollView;
	IBOutlet NSScrollView *responseScrollView;
	IBOutlet WebView *requestWebView;
	IBOutlet WebView *responseWebView;
	
	IBOutlet NSWindow *authWindow;
	IBOutlet NSTextField *usernameTextField;
	IBOutlet NSSecureTextField *passwordTextField;
	
	id <WSDLParsingService> parsingService;
	id <SOAPService> soapService;
	PrettyPrinter *prettyPrinter;
	SOAPCommand *command;
	id windowScriptObject;
	BOOL parsing;
	BOOL executing;
	BOOL canExecute;
	NSString *WSDLURLString;
	NSString *WSDLString;
	NSString *statusString;
	
	NSString *username;
	NSString *password;
	NSString *authMessage;
	BOOL rememberPassword;

	int lastClickedCol;
	NSArray *requestHeaderNames;
	NSDictionary *requestHeaderValues;
	NSMutableDictionary *requestHeaders;
	NSMutableArray *requestHeaderOrder;
}
// Actions
- (IBAction)openLocation:(id)sender;
- (IBAction)browse:(id)sender;
- (IBAction)parseWSDL:(id)sender;
- (IBAction)execute:(id)sender;
- (IBAction)clear:(id)sender;
- (IBAction)switchTab:(id)sender;
- (IBAction)viewWSDLSource:(id)sender;
- (IBAction)insertHeader:(id)sender;
- (IBAction)removeHeader:(id)sender;
- (IBAction)completeAuth:(id)sender;

// called by document to grab JS values
- (void)save;

// Accessors
- (BOOL)canExecute;
- (void)setCanExecute:(BOOL)yn;
- (SOAPCommand *)command;
- (void)setCommand:(SOAPCommand *)cmd;
- (id)windowScriptObject;
- (void)setWindowScriptObject:(id)newObj;
- (BOOL)isParsing;
- (void)setParsing:(BOOL)yn;
- (BOOL)isExecuting;
- (void)setExecuting:(BOOL)yn;
- (NSString *)WSDLURLString;
- (void)setWSDLURLString:(NSString *)newStr;
- (NSString *)WSDLString;
- (void)setWSDLString:(NSString *)newStr;
- (NSString *)statusString;
- (void)setStatusString:(NSString *)newStr;
- (NSString *)username;
- (void)setUsername:(NSString *)newStr;
- (NSString *)password;
- (void)setPassword:(NSString *)newStr;
- (NSString *)authMessage;
- (void)setAuthMessage:(NSString *)newStr;
- (NSMutableDictionary *)requestHeaders;
- (BOOL)rememberPassword;
- (void)setRememberPassword:(BOOL)yn;
- (void)setRequestHeaders:(NSMutableDictionary *)newHeaders;
- (NSMutableArray *)requestHeaderOrder;
- (void)setRequestHeaderOrder:(NSMutableArray *)newOrder;
@end
