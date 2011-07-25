//
//  SCController.m
//  SOAP Client
//
//  Created by Todd Ditchendorf on 10/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SCController.h"
#import "SOAPCommand.h"
#import "MyBoolean.h"
#import "SimpleType.h"
#import "ComplexType.h"
#import "WSDLParsingServiceLibxsltImpl.h"
#import "SOAPServiceWSCoreImpl.h"
#import "PrettyPrinter.h"
#import "AGRegex.h"
#import "NSDictionary+HTTPHeaders.h"
#import "WSDLViewController.h"
#import <WebKit/WebKit.h>
#import <Security/Security.h>
#import <CoreServices/CoreServices.h>

static NSString * const kSOAPRequestHeadersKey	= @"/WSDebugOutHeaders";
static NSString * const kSOAPRequestBodyKey		= @"/WSDebugOutBody";
static NSString * const kSOAPResponseHeadersKey	= @"/WSDebugInHeaders";
static NSString * const kSOAPResponseBodyKey	= @"/WSDebugInBody";


static NSString * const EmptyHTMLString			= @"<html></html>";
static NSString * const Whitespace				= @" ";
static NSString * const EmptyString				= @"";
static NSString * const HTMLErrorFormatString	= @"<b style='color:#999;'>%@</b>";
static NSString * const PreFormat				= @"<body style='margin:10px; background:rgb(255,242,239);'><p><b style='font:bold 12px LucidaGrande,sans-serif;color:#900;'>Error while parsing WSDL file:</b><pre>%@</pre></body>";
static NSString * const InnerHeightScript		= @"parseInt(document.defaultView.getComputedStyle(document.body, null).height)";
static AGRegex *regex;

@interface SCController (Private)
- (void)setupFonts;
- (void)consumeJsCommand:(id)jsCmd;
- (id)processJsValue:(id)value;
- (void)doParseWSDL;
- (NSData *)fetchWSDLData;
- (void)doExecute;
- (void)wasEdited;
- (SOAPCommand *)command;
- (void)setCommand:(SOAPCommand *)cmd;
- (void)doPrettyPrinting:(NSDictionary *)info;
- (void)finish:(NSDictionary *)info;
- (void)doError:(NSString *)msg;

// HTTP
- (NSData *)fetchResourceAtURL:(NSString *)sourceURLString 
					  finalURL:(NSString **)finalURLString;
- (NSData *)dataForStream:(CFReadStreamRef)stream;

// HTTP Auth
- (CFHTTPMessageRef)addAuthToRequest:(CFHTTPMessageRef)req forAuthDeniedResponse:(CFHTTPMessageRef)res isRetry:(BOOL)yn;
- (SecKeychainItemRef)keychainItemForURL:(NSURL *)url getPasswordString:(NSString **)passwordString;
- (NSString *)accountNameFromKeychainItem:(SecKeychainItemRef)item;
- (void)addAuthToKeychainItem:(SecKeychainItemRef)keychainItem forURL:(NSURL *)url realm:(NSString *)realm forProxy:(BOOL)forProxy;

- (void)doWSDLError:(NSString *)msg;

- (void)setupComboBoxDataSourceInfo;
- (void)registerForNotifications;
- (NSComboBoxCell *)newComboBoxCellWithTag:(int)tag;
- (void)setupHeadersTable;
- (NSImage *)plusImage;
- (NSImage *)minusImage;
- (void)insertHeaderAtIndex:(int)index;
- (void)removeHeaderAtIndex:(int)index;
- (NSDictionary *)constructRequestHeaders;
- (BOOL)isNameRequiringTodaysDateString:(NSString *)name;
- (NSString *)todaysDateString;
- (NSString *)valueForKey:(NSString *)key fromHeaders:(NSDictionary *)headers;
@end


@implementation SCController

+ (void)initialize;
{
	regex = [[AGRegex alloc] initWithPattern:@"\\s*$"];
}

#pragma mark -

- (id)initWithWindowNibName:(NSString *)name;
{
	self = [super initWithWindowNibName:name];
	if (self != nil) {
		parsingService = [[WSDLParsingServiceLibxsltImpl alloc] initWithDelegate:self];
		soapService = [[SOAPServiceWSCoreImpl alloc] initWithDelegate:self];
		prettyPrinter = [[PrettyPrinter alloc] init];
		[self setupComboBoxDataSourceInfo];
	}
	return self;
}


- (void)dealloc;
{
	[parsingService release];
	[soapService release];
	[self setCommand:nil];
	[self setWindowScriptObject:nil];
	[self setWSDLURLString:nil];
	[self setWSDLString:nil];
	[self setStatusString:nil];
	[self setUsername:nil];
	[self setPassword:nil];
	[self setRequestHeaders:nil];
	[self setRequestHeaderOrder:nil];
	[super dealloc];
}


- (void)awakeFromNib;
{
	[self setupFonts];
	[self setupHeadersTable];
	[self makeTextViewScrollHorizontally:requestTextView
						withinScrollView:requestScrollView];
	[self makeTextViewScrollHorizontally:responseTextView
						withinScrollView:responseScrollView];
	[self registerForNotifications];
}


#pragma mark -
#pragma mark Actions

- (IBAction)openLocation:(id)sender;
{
	[[self window] makeFirstResponder:WSDLTextField];
}


- (IBAction)browse:(id)sender;
{	
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	int result = [openPanel runModalForDirectory:nil file:nil types:nil];
	
	if (NSOKButton == result) {
		[self clear:self];
		[self setCanExecute:NO];
		[self setWSDLURLString:[openPanel filename]];
		[self parseWSDL:self];
	}
}


- (IBAction)parseWSDL:(id)sender;
{
	if (![WSDLURLString length]) {
		NSBeep();
		return;
	}
	
	[self setParsing:YES];
	[self clear:self];
	[self setCommand:nil];
	
	[self setWSDLURLString:[regex replaceWithString:EmptyString inString:WSDLURLString]];
	[topTabView selectTabViewItemAtIndex:0];
	[NSThread detachNewThreadSelector:@selector(doParseWSDL)
							 toTarget:self
						   withObject:nil];
}


- (IBAction)execute:(id)sender;
{
	[self setExecuting:YES];
	[[requestWebView  mainFrame] loadHTMLString:EmptyHTMLString baseURL:nil];
	[[responseWebView mainFrame] loadHTMLString:EmptyHTMLString baseURL:nil];
	[requestTextView  setString:EmptyString];
	[responseTextView setString:EmptyString];
	[self setStatusString:nil];
	
	[windowScriptObject callWebScriptMethod:@"submitClicked" withArguments:nil];
}


- (IBAction)clear:(id)sender;
{
	[[WSDLWebView	  mainFrame] loadHTMLString:EmptyHTMLString baseURL:nil];
	[[requestWebView  mainFrame] loadHTMLString:EmptyHTMLString baseURL:nil];
	[[responseWebView mainFrame] loadHTMLString:EmptyHTMLString baseURL:nil];
	[requestTextView  setString:EmptyString];
	[responseTextView setString:EmptyString];
	[self setStatusString:nil];
}


- (IBAction)switchTab:(id)sender;
{
	[tabView selectTabViewItemAtIndex:[sender tag]];
}


- (IBAction)viewWSDLSource:(id)sender;
{
	if (![WSDLURLString length]) {
		NSBeep();
		return;
	}
	
	[self setWSDLURLString:[regex replaceWithString:EmptyString inString:WSDLURLString]];

	[NSThread detachNewThreadSelector:@selector(doViewWSDLSource)
							 toTarget:self
						   withObject:nil];
}


- (IBAction)insertHeader:(id)sender;
{
	int index = [headersTable selectedRow];
	[self insertHeaderAtIndex:index+1];
	[headersTable reloadData];
}


- (IBAction)removeHeader:(id)sender;
{
	int index = [headersTable selectedRow];
	[self removeHeaderAtIndex:index];
	[headersTable reloadData];
}


- (IBAction)completeAuth:(id)sender;
{
	[NSApp stopModalWithCode:[sender tag]];
}


#pragma mark -
#pragma mark Public

- (void)save;
{
	[windowScriptObject callWebScriptMethod:@"save" withArguments:nil];
}


#pragma mark -
#pragma mark PrivateActions

- (void)handleTableClicked:(id)sender;
{
	lastClickedCol = [sender clickedColumn];
}


- (void)handleComboBoxTextChanged:(id)sender;
{
	int rowIndex = [sender selectedRow];
	int colIndex = [sender clickedColumn];
	if (-1 == colIndex) {
		colIndex = lastClickedCol;
	}
	
	NSMutableDictionary *reqHeaders = [self requestHeaders];
	NSMutableArray *headerOrder = [self requestHeaderOrder];
	
	//NSLog(@"row: %i, col: %i",rowIndex,colIndex);
	if (0 == colIndex) { // name changed
		
		NSString *oldName = [headerOrder objectAtIndex:rowIndex];
		NSString *newName = [sender stringValue];
		NSString *value   = [reqHeaders objectForKey:oldName];
		[headerOrder replaceObjectAtIndex:rowIndex withObject:newName];
		[reqHeaders removeObjectForKey:oldName];
		[reqHeaders setObject:value forKey:newName];
		
	} else { // value changed
		
		NSString *name = [headerOrder objectAtIndex:rowIndex];
		NSString *value = [sender stringValue];
		[reqHeaders setObject:value forKey:name];
		
	}
	[self wasEdited];
}


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
	if (@selector(consumeJsCommand:) == aSelector) {
		return @"consumeJsCommand";
	} else if (@selector(execute:) == aSelector) {
		return @"execute";
	} else if (@selector(doExecute) == aSelector) {
		return @"doExecute";
	} else if (@selector(wasEdited) == aSelector) {
		return @"wasEdited";
	} else if (@selector(log:) == aSelector) {
		return @"log";
	} else {
		return nil;
	}
}


#pragma mark -
#pragma mark Private

- (void)setupFonts;
{
	NSFont *monaco = [NSFont fontWithName:@"Monaco" size:10.];
	[headerXMLTextView setFont:monaco];
	[requestTextView setFont:monaco];
	[responseTextView setFont:monaco];	
}


- (void)setupHeadersTable;
{	
	[headersTable setTarget:self];
	[headersTable setAction:@selector(handleTableClicked:)];
	
	[[headersTable tableColumnWithIdentifier:@"name"] setDataCell:[[self newComboBoxCellWithTag:0] autorelease]];
	[[headersTable tableColumnWithIdentifier:@"value"] setDataCell:[[self newComboBoxCellWithTag:1] autorelease]];
	
	NSButtonCell *cell = [[headersTable tableColumnWithIdentifier:@"insertButton"] dataCell];
	[cell setTarget:self];
	[cell setAction:@selector(insertHeader:)];
	[cell setImage:[self plusImage]];
	[cell setImagePosition:NSImageOnly];
	
	cell = [[headersTable tableColumnWithIdentifier:@"removeButton"] dataCell];
	[cell setTarget:self];
	[cell setAction:@selector(removeHeader:)];
	[cell setImage:[self minusImage]];
	[cell setImagePosition:NSImageOnly];
	
	[headersTable setIntercellSpacing:NSMakeSize(7, 7)];
}


- (NSImage *)plusImage;
{
    float scaleFactor = 1.0;// hi dpi...? * [[NSScreen mainScreen] use
    float imageSize = 8 * scaleFactor;
    NSImage *result = [[[NSImage alloc] initWithSize:NSMakeSize(imageSize, imageSize)] autorelease];
    [result lockFocus];
    [[NSColor grayColor] set];
	
    // Horz line
    NSRectFill(NSMakeRect(0, 3 * scaleFactor, imageSize, 2 * scaleFactor));
    // Top part
    NSRectFill(NSMakeRect(3 * scaleFactor, 0, 2 * scaleFactor, 3 * scaleFactor));
    // Bottom part
    NSRectFill(NSMakeRect(3 * scaleFactor, imageSize - 3 * scaleFactor, 2 * scaleFactor, 3 * scaleFactor));
	
    [result unlockFocus];
	
    return result;
}


- (NSImage *)minusImage;
{
    float scaleFactor = 1.0;// hi dpi...? * [[NSScreen mainScreen] use
    float imageSize = 8 * scaleFactor;
    NSImage *result = [[[NSImage alloc] initWithSize:NSMakeSize(imageSize, imageSize)] autorelease];
    [result lockFocus];
    [[NSColor grayColor] set];
	
    // Horz line
    NSRectFill(NSMakeRect(0, 3 * scaleFactor, imageSize, 2 * scaleFactor));	
	
    [result unlockFocus];
	
    return result;
}


- (NSComboBoxCell *)newComboBoxCellWithTag:(int)tag;
{
	NSComboBoxCell *cbCell = [[NSComboBoxCell alloc] init];
	[cbCell setEditable:YES];
	[cbCell setFocusRingType:NSFocusRingTypeNone];
	[cbCell setControlSize:NSSmallControlSize];
	[cbCell setFont:[NSFont fontWithName:@"Lucida Grande" size:10.]];
	[cbCell setUsesDataSource:YES];
	[cbCell setDataSource:self];
	[cbCell setTarget:self];
	[cbCell setAction:@selector(handleComboBoxTextChanged:)];
	[cbCell setTag:tag];
	[cbCell setNumberOfVisibleItems:12];
	return cbCell;
}


- (void)setupComboBoxDataSourceInfo;
{
	[self setRequestHeaders:[NSMutableDictionary dictionaryWithObject:Whitespace forKey:Whitespace]];
	[self setRequestHeaderOrder:[NSMutableArray arrayWithObject:Whitespace]];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"headerNames"
													 ofType:@"plist"];
	requestHeaderNames = [[NSArray alloc] initWithContentsOfFile:path];
	
	path = [[NSBundle mainBundle] pathForResource:@"headerValues"
										   ofType:@"plist"];
	requestHeaderValues = [[NSDictionary alloc] initWithContentsOfFile:path];
	
}


- (void)registerForNotifications;
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

	[nc addObserver:self
		   selector:@selector(windowDidResize:)
			   name:NSWindowDidResizeNotification
			 object:[self window]];
	[nc addObserver:self
		   selector:@selector(controlTextDidChange:)
			   name:NSControlTextDidChangeNotification
			 object:headersTable];
	[nc addObserver:self
		   selector:@selector(controlTextDidEndEditing:)
			   name:NSControlTextDidEndEditingNotification
			 object:headersTable];
}


- (void)windowDidResize:(NSNotification *)aNotification;
{
	[headersTable sizeToFit];
}


- (void)insertHeaderAtIndex:(int)index;
{
	[requestHeaderOrder insertObject:Whitespace atIndex:index];
	[requestHeaders setObject:Whitespace forKey:Whitespace];
}


- (void)removeHeaderAtIndex:(int)index;
{
	NSString *name = [[self requestHeaderOrder] objectAtIndex:index];
	[requestHeaders removeObjectForKey:name];
	[requestHeaderOrder removeObjectAtIndex:index];
	
	if (0 == index && 0 == [requestHeaders count]) {
		[self insertHeaderAtIndex:0];
	}
	
}


- (NSDictionary *)constructRequestHeaders;
{
	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:[self requestHeaders]];
	
	NSEnumerator *e = [[self requestHeaders] keyEnumerator];
	NSString *key;
	while (key = [e nextObject]) {
		if ([key isEqualToString:Whitespace]) {
			[result removeObjectForKey:key];
		} else if ([[key lowercaseString] isEqualToString:@"user-agent"]) {
			NSString *val = [result objectForKey:key];
			NSUInteger index = [val rangeOfString:@" --- "].location;
			if (NSNotFound != index) {
				[result setObject:[val substringFromIndex:index+5] forKey:key];
			}
		}
	}
	return result;
}


- (BOOL)isNameRequiringTodaysDateString:(NSString *)name;
{
	return [name isEqualToString:@"if-modified-since"] 
		|| [name isEqualToString:@"if-unmodified-since"] 
		|| [name isEqualToString:@"if-range"];
}


- (NSString *)todaysDateString;
{
	NSCalendarDate *today = [NSCalendarDate date];
	// format: Sun, 06 Nov 1994 08:49:37 GMT
	[today setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	return [today descriptionWithCalendarFormat:@"%a, %d %b %Y %H:%M:%S GMT"];
}


- (void)log:(NSString *)msg;
{
	//NSLog(@"%@", msg);
}


- (void)consumeJsCommand:(id)jsCmd;
{
	id jsParams = [jsCmd valueForKey:@"parameters"];
	id jsOrder  = [jsCmd valueForKey:@"order"];
	id jsTypes  = [jsCmd valueForKey:@"types"];	
	int paramCount = [[jsOrder valueForKey:@"length"] intValue];
	NSMutableArray *order = [NSMutableArray arrayWithCapacity:paramCount];
	NSMutableArray *paramTypes = [NSMutableArray arrayWithCapacity:paramCount];
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:paramCount];
	int i;
	NSString *intKey;
	NSString *valKey;
	id value;
	for (i = 0; i < paramCount; i++) {
		intKey = [NSString stringWithFormat:@"%i", i];
		valKey = [jsOrder valueForKey:intKey];
		[order addObject:valKey];
		[paramTypes addObject:[jsTypes webScriptValueAtIndex:i]];
		
		value = [jsParams valueForKey:valKey];
		value = [self processJsValue:value];

		[params setObject:value forKey:valKey];
	}	
	
	SOAPCommand *cmd = [[SOAPCommand alloc] init];
	[cmd setHeaderXMLString:[headerXMLTextView string]];
	[cmd setEndpointURI:[jsCmd valueForKey:@"endpointURI"]];
	[cmd setBindingStyle:[jsCmd valueForKey:@"bindingStyle"]];
	[cmd setMethod:[jsCmd valueForKey:@"method"]];
	[cmd setMethodId:[jsCmd valueForKey:@"methodId"]];
	[cmd setNamespace:[jsCmd valueForKey:@"namespace"]];
	[cmd setSOAPAction:[jsCmd valueForKey:@"SOAPAction"]];
	[cmd setParamOrder:order];
	[cmd setParams:params];
	[cmd setParamTypes:paramTypes];
	
	[cmd setRequestHeaders:requestHeaders];
	[cmd setRequestHeaderOrder:requestHeaderOrder];
	[self setCommand:cmd];
}


- (id)processJsValue:(id)value;
{
	if ([value isKindOfClass:[WebScriptObject class]]) {
		NSString *jsClass = [value callWebScriptMethod:@"getType" withArguments:nil];
		NSString *str = [value callWebScriptMethod:@"toString" withArguments:nil];
		if ([jsClass isEqualToString:@"MyBoolean"]) {
			BOOL boolValue = ([[str lowercaseString] isEqualToString:@"true"]) ? YES : NO;
			value = [[[MyBoolean alloc] init] autorelease];
			[value setBoolValue:boolValue];
		} else if ([jsClass isEqualToString:@"SimpleType"]) {
			SimpleType *simpleType = [[[SimpleType alloc] init] autorelease];
			[simpleType setValue:str];
			[simpleType setTypeUri:[value valueForKey:@"__typeUri"]];
			[simpleType setTypeName:[value valueForKey:@"__typeName"]];
			[simpleType setLocalName:[value valueForKey:@"__localName"]];
			value = [NSArray arrayWithObject:simpleType];
		} else if ([jsClass isEqualToString:@"ComplexType"]) {
			ComplexType *customObj = [[[ComplexType alloc] init] autorelease];
			[customObj setTypeName:[value valueForKey:@"__typeName"]];
			[customObj setPrefix:[value valueForKey:@"__prefix"]];
			[customObj setLocalName:[value valueForKey:@"__localName"]];
			[customObj setNamespaceURI:[value valueForKey:@"__namespaceUri"]];
			NSArray *keys = [[value valueForKey:@"__keys"] componentsSeparatedByString:@","];
			[customObj setPropOrder:keys];
			NSEnumerator *e = [keys objectEnumerator];
			id __key, __val;
			while (__key = [e nextObject]) {
				__val = [value valueForKey:__key];
				__val = [self processJsValue:__val];
				[customObj setValue:__val forKey:__key];
			}
			value = [NSArray arrayWithObject:customObj];
		}
	}
	return value;
}

- (void)doParseWSDL;
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSData *WSDLData = [self fetchWSDLData];
	
	if (![WSDLData length]) {
		//NSBeep();
		[self setCanExecute:NO];
		[self setParsing:NO];
	} else {
		[parsingService parseWSDL:WSDLData];
		[self setWSDLString:[[[NSString alloc] initWithData:WSDLData encoding:NSUTF8StringEncoding] autorelease]];
	}
	
	[pool release];
}


- (void)doViewWSDLSource;
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (![WSDLString length]) {
		NSBeep();
	} else {
		
		WSDLViewController *c = [[[WSDLViewController alloc] init] autorelease];
		[[self document] addWindowController:c];
		[c setWSDLString:WSDLString];
		[c setTitle:WSDLURLString];
		[c performSelectorOnMainThread:@selector(showWindow:)
							withObject:self
						 waitUntilDone:NO];
	}
	
	[pool release];
}


- (NSData *)fetchWSDLData;
{
	NSData *result = nil;
	
	if ([WSDLURLString hasPrefix:@"www."]) {
		[self setWSDLURLString:[NSString stringWithFormat:@"http://%@", WSDLURLString]];
	}
	
	NSError *err = nil;
	
	if ([WSDLURLString hasPrefix:@"http://"] || [WSDLURLString hasPrefix:@"https://"]) {
		NSString *finalURLString = nil;
		result = [self fetchResourceAtURL:WSDLURLString finalURL:&finalURLString];
		if (finalURLString) {
			[self setWSDLURLString:finalURLString];
		}
	} else {
		result = [NSData dataWithContentsOfFile:WSDLURLString
										options:0
										  error:&err];
		
	}
	
	if (err) {
		return nil;
	}

	return result;
}


- (void)doExecute;
{
	[self setCanExecute:NO];
	[soapService executeCommand:command];
}


- (void)wasEdited;
{
	[[self document] updateChangeCount:NSChangeDone];
}


- (void)doPrettyPrinting:(NSDictionary *)info;
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *prettyRequest  = [prettyPrinter prettyStringForXMLString:[info objectForKey:kSOAPRequestBodyKey]];
	NSString *prettyResponse = [prettyPrinter prettyStringForXMLString:[info objectForKey:kSOAPResponseBodyKey]];

	NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
		prettyRequest, @"req", prettyResponse, @"res",
		[info valueForKey:@"isFault"], @"isFault", nil];
	
	[self performSelectorOnMainThread:@selector(finish:)
						   withObject:result
						waitUntilDone:NO];
	[pool release];
}


- (void)finish:(NSDictionary *)info;
{
	NSString *reqHTMLString = [info objectForKey:@"req"];
	NSString *resHTMLString = [info objectForKey:@"res"];
	if ([reqHTMLString length]) {
		[[requestWebView  mainFrame] loadHTMLString:reqHTMLString  baseURL:nil];
	}
	if ([resHTMLString length]) {
		[[responseWebView mainFrame] loadHTMLString:resHTMLString baseURL:nil];
	}
	
	BOOL isFault = [[info valueForKey:@"isFault"] boolValue];
	NSString *soundName = (isFault) ? @"Bottle" : @"Hero";
		
	[self setExecuting:NO];
	[self setCanExecute:YES];
	[[NSSound soundNamed:soundName] play];
}


- (NSString *)valueForKey:(NSString *)key fromHeaders:(NSDictionary *)headers;
{
	NSString *result = nil;
	key = [key lowercaseString];
	NSEnumerator *e = [headers keyEnumerator];
	NSString *currKey;
	while (currKey = [e nextObject]) {
		if ([[currKey lowercaseString] isEqualToString:key]) {
			result = [[headers objectForKey:currKey] lowercaseString];
			break;
		}
	}
	return result;
}


#pragma mark -
#pragma mark HTTP support

- (NSData *)fetchResourceAtURL:(NSString *)sourceURLString 
					  finalURL:(NSString **)finalURLString;
{
	NSData *result = nil;
	
	// create request
	NSString *method = @"GET";
	NSURL *url = [NSURL URLWithString:sourceURLString];
	CFHTTPMessageRef req = CFHTTPMessageCreateRequest(kCFAllocatorDefault, (CFStringRef)method, (CFURLRef)url, kCFHTTPVersion1_1);
	CFHTTPMessageRef res = NULL;
		
	NSDictionary *reqHeaders = [(NSDictionary *)CFHTTPMessageCopyAllHeaderFields(req) autorelease];
	//NSLog(@"reqHeaders: %@", reqHeaders);
	
	// create stream
	CFReadStreamRef stream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, req);
	if (!stream) {
		goto leave;
	}
	
	// read from stream
	result = [self dataForStream:stream];
	if (!result) {
		goto leave;
	}
	
	// get response headers
	res = (CFHTTPMessageRef)CFReadStreamCopyProperty(stream, kCFStreamPropertyHTTPResponseHeader);
	if (!res) {
		goto leave;
	}
	
	// get final url before auth
	NSURL *finalURL = (NSURL *)CFReadStreamCopyProperty(stream, kCFStreamPropertyHTTPFinalURL);
	(*finalURLString) = [finalURL absoluteString];
	[finalURL autorelease];
	
	// check for auth denied
	UInt32 resStatusCode = CFHTTPMessageGetResponseStatusCode(res);
	int count = 0;
	
	// while auth denied, try adding auth creds
	while (401 == resStatusCode || 407 == resStatusCode) {

		// add auth creds
		req = [self addAuthToRequest:req forAuthDeniedResponse:res isRetry:count];
		
		// check to see if user cancelled dialog
		if (!req) {
			(*finalURLString) = nil;
			return nil;
		}

		reqHeaders = [(NSDictionary *)CFHTTPMessageCopyAllHeaderFields(req) autorelease];
		//NSLog(@"reqHeaders: %@", reqHeaders);

		// create new stream
		if (stream) {
			CFReadStreamClose(stream);
			CFRelease(stream);
			stream = NULL;
		}
		stream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, req);

		// read from stream
		result = [self dataForStream:stream];
		if (!result) {
			goto leave;
		}
		
		// get response headers
		if (res) {
			CFRelease(res);
			res = NULL;
		}
		res = (CFHTTPMessageRef)CFReadStreamCopyProperty(stream, kCFStreamPropertyHTTPResponseHeader);
		if (!res) {
			goto leave;
		}
		
		resStatusCode = CFHTTPMessageGetResponseStatusCode(res);
		count++;
	}

	// get final url again in case it changed during auth
	finalURL = (NSURL *)CFReadStreamCopyProperty(stream, kCFStreamPropertyHTTPFinalURL);
	(*finalURLString) = [finalURL absoluteString];
	[finalURL autorelease];
	
leave:
	//close stream
	if (stream && CFReadStreamGetStatus(stream) == kCFStreamStatusOpen) {
		CFReadStreamClose(stream);
	}
	
	// clean up
	if (stream)
		CFRelease(stream);	
	if (req) 
		CFRelease(req);
	if (res) 
		CFRelease(res);
	
	if (!result) {
		[self performSelectorOnMainThread:@selector(doWSDLError:)
							   withObject:@"Could not fetch WSDL file."
							waitUntilDone:NO];
		result = nil;
	}
	
	return result;
}


- (NSData *)dataForStream:(CFReadStreamRef)stream;
{
	// configure to autoredirect
	if (CFReadStreamSetProperty(stream, kCFStreamPropertyHTTPShouldAutoredirect, kCFBooleanTrue) == false) {
		return nil;
	}

	// open stream
	if (!CFReadStreamOpen(stream)) {
		return nil;
	}

	NSMutableData *result = [NSMutableData data];

	CFIndex numBytesRead;
	do {
		UInt8 buf[1024];
		numBytesRead = CFReadStreamRead(stream, buf, sizeof(buf));
		if (numBytesRead > 0) {
			[result appendBytes:buf length:numBytesRead];
		} else if (numBytesRead < 0) {
			return nil;
		}
	} while (numBytesRead > 0);
	return result;
}


- (CFHTTPMessageRef)addAuthToRequest:(CFHTTPMessageRef)req forAuthDeniedResponse:(CFHTTPMessageRef)res isRetry:(BOOL)isRetry;
{
	static int count = 0;
	if (isRetry) {
		count++;
	} else {
		count = 1;
	}
	
	UInt32 resStatusCode = CFHTTPMessageGetResponseStatusCode(res);
	BOOL forProxy = (resStatusCode == 407);
	NSURL *url = (NSURL *)CFHTTPMessageCopyRequestURL(req);

	
	//NSDictionary *headers = [(NSDictionary *)CFHTTPMessageCopyAllHeaderFields(res) autorelease];
	//NSLog(@"res headers: %@", headers);

	CFHTTPAuthenticationRef auth = CFHTTPAuthenticationCreateFromResponse(kCFAllocatorDefault, res);
	//NSString *scheme = [(NSString *)CFHTTPAuthenticationCopyMethod(auth) autorelease];
	NSString *realm  = [(NSString *)CFHTTPAuthenticationCopyRealm(auth)  autorelease];
	NSArray *domains = [(NSArray *)CFHTTPAuthenticationCopyDomains(auth) autorelease];
	NSURL *domain = ([domains count]) ? [domains objectAtIndex:0] : nil;

	//NSLog(@"scheme: %@", scheme);
	//NSLog(@"realm: %@", realm);
	//NSLog(@"domains: %@", domains);
	
	//NSString *authHeaderVal = [self valueForKey:@"www-authenticate" fromHeaders:headers];
	
	//if ([[scheme lowercaseString] isEqualToString:@"ntlm"] && count > 1) {
	//	return req;
	//} else {

		// check keychain for auth creds first. use those if they exist
		NSString *passwordString = nil;
		SecKeychainItemRef keychainItem = [self keychainItemForURL:url getPasswordString:&passwordString];
		if (keychainItem && !isRetry) {
			NSString *accountString = [self accountNameFromKeychainItem:keychainItem];
			[self setUsername:accountString];
			[self setPassword:passwordString];
		} else {
			// ok, no auth was found in the keychain, show auth sheet
			
			NSString *fmt = (isRetry) ? 
			@"The name or password entered for area \"%@\" on %@ was incorrect. Please try again." : 
			@"To view this page, you must log in to \"%@\" on %@.";
			
			NSString *msg = [NSString stringWithFormat:fmt, realm, [domain host]];
			[self setAuthMessage:msg];
			
			[self setRememberPassword:NO];
			[self setPassword:nil];
			if (!isRetry) {
				[self setUsername:nil];
			} else {
				[passwordTextField selectText:self];
			}
			
			[NSApp beginSheet:authWindow
			   modalForWindow:[self window]
				modalDelegate:self
			   didEndSelector:nil
				  contextInfo:NULL];
			
			[authWindow makeFirstResponder:usernameTextField];
			BOOL cancelled = [NSApp runModalForWindow:authWindow];
			
			[NSApp endSheet:authWindow];
			[authWindow orderOut:nil];
			
			if (cancelled) {
				return nil;
			}
			
			// add auth creds to keychain if requested
			if (rememberPassword) {
				[self addAuthToKeychainItem:keychainItem forURL:url realm:realm forProxy:forProxy];
			}
		}
		
	//}
		
	// finally, add auth creds to request
	NSString *uname = (username) ? username : EmptyString;
	NSString *pword = (password) ? password : EmptyString;
	
	NSMutableDictionary *creds = [NSMutableDictionary dictionaryWithObjectsAndKeys:
		uname,  kCFHTTPAuthenticationUsername,
		pword,  kCFHTTPAuthenticationPassword,
		nil];
	
	if (domain && CFHTTPAuthenticationRequiresAccountDomain(auth)) {
		[creds setObject:[domain absoluteString] forKey:(NSString *)kCFHTTPAuthenticationAccountDomain];
	}
	
	//if (false == CFHTTPMessageAddAuthentication(req, res, (CFStringRef)uname, (CFStringRef)pword, NULL, forProxy)) {
	if (false == CFHTTPMessageApplyCredentialDictionary(req, auth, (CFDictionaryRef)creds, NULL)) {
		NSLog(@"failed to add auth");
	}
	return req;
}


- (SecKeychainItemRef)keychainItemForURL:(NSURL *)url getPasswordString:(NSString **)passwordString;
{
	SecKeychainItemRef result = NULL;
	
	NSString *host = [url host];
	UInt16 port = [[url port] intValue];
	void *passwordData;
	UInt32 len;
	OSStatus status = SecKeychainFindInternetPassword(NULL,
													  [host length],
													  [host UTF8String],
													  0,//[realm length],
													  NULL,//[realm UTF8String],
													  0,//[acctName length],
													  NULL,//[acctName UTF8String],
													  0,//[path length],
													  NULL,//[path UTF8String],
													  port,
													  kSecProtocolTypeHTTP,
													  kSecAuthenticationTypeDefault,
													  &len,
													  &passwordData,
													  &result);
	if (errSecItemNotFound == status) {
		//NSLog(@"could not find in keychain");
	} else if (status) {
		NSLog(@"error while trying to find in keychain");
	} else {
		NSData *data = [NSData dataWithBytes:passwordData length:len];
		(*passwordString) = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	}
	return result;
}


- (NSString *)accountNameFromKeychainItem:(SecKeychainItemRef)item;
{
    
    NSString *result = nil;
    
	OSStatus err = 0;
	UInt32 infoTag = kSecAccountItemAttr;
	UInt32 infoFmt = 0; // string
    SecKeychainAttributeInfo info;
	SecKeychainAttributeList *authAttrList = NULL;
	void *data;
	UInt32 dataLen;
	//char accountName[1024];
	
    info.count = 1;
	info.tag = &infoTag;
	info.format = &infoFmt;
	
	err = SecKeychainItemCopyAttributesAndData(item, &info, NULL, &authAttrList, &dataLen, &data);
	if (err) { 
		goto leave; 
	}
	
	if (!authAttrList->count || authAttrList->attr->tag != kSecAccountItemAttr) { 
		goto leave; 
	}
	if (authAttrList->attr->length > 1024) { 
		goto leave; 
	}
	result = [NSString stringWithUTF8String:authAttrList->attr->data];
	
leave:
	if (authAttrList) 
		SecKeychainItemFreeContent(authAttrList, data);
	
	return result;
}


- (void)addAuthToKeychainItem:(SecKeychainItemRef)keychainItemRef forURL:(NSURL *)url realm:(NSString *)realm forProxy:(BOOL)forProxy;
{
	OSStatus status = 0;
	NSString *scheme = [url scheme];
	NSString *host = [url host];
	int port = [[url port] intValue];
	NSString *label = [NSString stringWithFormat:@"%@ (%@)", host, username];
	NSString *comment = @"created by SOAP Client";

	NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
	
	if (!keychainItemRef) {				
		OSType protocol;
		BOOL isHTTPS = [scheme hasPrefix:@"https://"];
		if (forProxy) {
			protocol = (isHTTPS) ? kSecProtocolTypeHTTPSProxy : kSecProtocolTypeHTTPProxy;
		} else {
			protocol = (isHTTPS) ? kSecProtocolTypeHTTPS : kSecProtocolTypeHTTP;
		}
		OSType authType = kSecAuthenticationTypeDefault;
		
		// set up attribute vector (each attribute consists of {tag, length, pointer})
		SecKeychainAttribute attrs[] = {
			{ kSecLabelItemAttr, [label length], (char *)[label UTF8String] },
			{ kSecProtocolItemAttr, 4, &protocol },
			{ kSecServerItemAttr, [host length], (char *)[host UTF8String] },
			{ kSecAccountItemAttr, [username length], (char *)[username UTF8String] },
			{ kSecPortItemAttr, sizeof(SInt16), &port },
			{ kSecPathItemAttr, 0, (char *)EmptyString },
			{ kSecCommentItemAttr, [comment length], (char *)[comment UTF8String] },
			{ kSecAuthenticationTypeItemAttr, 4, &authType },
			{ kSecSecurityDomainItemAttr, [realm length], (char *)[realm UTF8String] },
		};
		SecKeychainAttributeList attributes = { sizeof(attrs) / sizeof(attrs[0]), attrs };

		status = SecKeychainItemCreateFromContent(kSecInternetPasswordItemClass,
												  &attributes,
												  [passwordData length],
												  (void *)[passwordData bytes],
												  NULL,
												  (SecAccessRef)NULL,//access,
												  &keychainItemRef);
		NSLog((status) ? @"creation failed" : @"creation succeeded");

	} else {

		SecKeychainAttribute attrs[] = {
			{ kSecAccountItemAttr, [username length], (char *)[username UTF8String] }
		};
		const SecKeychainAttributeList attributes = { sizeof(attrs) / sizeof(attrs[0]), attrs };

		status = SecKeychainItemModifyAttributesAndData(keychainItemRef,
														&attributes,	
														[passwordData length],
														(void *)[passwordData bytes]);
		if (status) {
			NSLog(@"Failed to change password in keychain.");
		}		
	}
}


- (void)doWSDLError:(NSString *)msg;
{
	NSMutableString *str = [NSMutableString stringWithString:msg];
	[str replaceOccurrencesOfString:@"<"
						 withString:@"&lt;"
							options:0
							  range:NSMakeRange(0, [msg length])];
	
	[[WSDLWebView mainFrame] loadHTMLString:[NSString stringWithFormat:PreFormat, str]
									baseURL:nil];
	[[NSSound soundNamed:@"Basso"] play];
	[self setCanExecute:NO];
	[self setParsing:NO];	
}


#pragma mark -
#pragma mark WSDLParsingServiceDelegate

- (void)WSDLParsingService:(id <WSDLParsingService>)service didFinish:(NSString *)HTMLString;
{
	[[WSDLWebView mainFrame] loadHTMLString:HTMLString baseURL:nil];
	[[NSSound soundNamed:@"Tink"] play];
	[self setCanExecute:YES];
	[self setParsing:NO];
}


- (void)WSDLParsingService:(id <WSDLParsingService>)service didError:(NSString *)msg;
{
	[self doWSDLError:msg];
}


#pragma mark -
#pragma mark SOAPServiceDelegate

- (void)SOAPService:(id <SOAPService>)service didFinish:(NSDictionary *)info;
{
	// TODO move this
	CFHTTPMessageRef res = (CFHTTPMessageRef)[info valueForKey:(id)kWSHTTPResponseMessage];
	if (!res) {
		[self doError:@"Could not connect to SOAP Endpoint"];
		return;
	}
	NSString *resStatusLine		= [(NSString *)CFHTTPMessageCopyResponseStatusLine(res) autorelease];

	NSDictionary *reqHeaders	= [info valueForKey:kSOAPRequestHeadersKey];
	NSDictionary *resHeaders	= [info valueForKey:kSOAPResponseHeadersKey];
	NSString *requestBody		= [info valueForKey:kSOAPRequestBodyKey];
	NSString *responseBody		= [info valueForKey:kSOAPResponseBodyKey];
	
	NSString *requestString  = [NSString stringWithFormat:@"%@\n\n%@",
		[reqHeaders serializedHTTPHeaders], requestBody];
	NSString *responseString = [NSString stringWithFormat:@"%@\n%@\n\n%@",
		resStatusLine, [resHeaders serializedHTTPHeaders], responseBody];

	[requestTextView  setString:requestString];
	[responseTextView setString:responseString];
	
	[NSThread detachNewThreadSelector:@selector(doPrettyPrinting:)
							 toTarget:self
						   withObject:info];
}


- (void)SOAPService:(id <SOAPService>)service didError:(NSString *)msg;
{
	[self doError:msg];
}

- (void)doError:(NSString *)msg;
{
	[[NSSound soundNamed:@"Basso"] play];
	[self setStatusString:msg];
	[self setCanExecute:YES];
	[self setExecuting:NO];	
}


- (CFHTTPMessageRef)SOAPService:(id <SOAPService>)service needsAuthForRequest:(CFHTTPMessageRef)req forAuthDeniedResponse:(CFHTTPMessageRef)res isRetry:(BOOL)isRetry;
{
	return [self addAuthToRequest:req forAuthDeniedResponse:res isRetry:isRetry];
}

#pragma mark -
#pragma mark WebFrameLoadDelegate

- (void)webView:(WebView *)sender windowScriptObjectAvailable:(WebScriptObject *)wso;
{
	[self setWindowScriptObject:wso];
	[windowScriptObject setValue:self forKey:@"App"];
	[windowScriptObject setValue:command forKey:@"Command"];
}


#pragma mark -
#pragma mark WebUIDelegate

- (NSUInteger)webView:(WebView *)sender dragDestinationActionMaskForDraggingInfo:(id <NSDraggingInfo>)draggingInfo;
{
	return WebDragDestinationActionLoad;
}


- (void)webView:(WebView *)sender willPerformDragDestinationAction:(WebDragDestinationAction)action forDraggingInfo:(id <NSDraggingInfo>)draggingInfo;
{
	NSPasteboard *pboard = [draggingInfo draggingPasteboard];
	NSString *filename = nil;
	
	if (NSNotFound != [[pboard types] indexOfObject:NSFilenamesPboardType]) {
		filename = [[pboard propertyListForType:NSFilenamesPboardType] objectAtIndex:0];
	} else if (NSNotFound != [[pboard types] indexOfObject:NSURLPboardType]) {
		filename = [[pboard propertyListForType:NSURLPboardType] objectAtIndex:0];
	}
	
	[self clear:self];
	[self setWSDLURLString:filename];
	[self parseWSDL:self];	
}


- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems;
{
	if (!WSDLURLString) {
		return nil;
	}
	NSMenuItem *item = [[[NSMenuItem alloc] init] autorelease];
	[item setTarget:self];
	[item setAction:@selector(parseWSDL:)];
	[item setTitle:@"Re-Parse WSDL"];
	return [NSArray arrayWithObject:item];
}


#pragma mark -
#pragma mark NSTableDataSource

- (int)numberOfRowsInTableView:(NSTableView *)aTableView;
{
	return [[self requestHeaders] count];
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
{
	NSString *identifier = [aTableColumn identifier];
	NSString *name = [[self requestHeaderOrder] objectAtIndex:rowIndex];
	
	if ([identifier isEqualToString:@"name"]) {
		return name;
	} else if ([identifier isEqualToString:@"value"]) {
		return [[self requestHeaders] objectForKey:name];
	} else if ([identifier isEqualToString:@"buttons"]) {
		return [NSNumber numberWithInt:1];
	}
	return nil;
}


#pragma mark -
#pragma mark NSComboBoxDataSource

- (id)comboBoxCell:(NSComboBoxCell *)aComboBoxCell objectValueForItemAtIndex:(NSInteger)index;
{
	BOOL isValueCell = [aComboBoxCell tag];
	if (isValueCell) {
		NSString *name = [[[self requestHeaderOrder] objectAtIndex:[headersTable selectedRow]] lowercaseString];
		
		if ([self isNameRequiringTodaysDateString:name]) {
			return [self todaysDateString];
		} else {
			return [[requestHeaderValues objectForKey:name] objectAtIndex:index];
		}
	} else {
		return [requestHeaderNames objectAtIndex:index];
	}
}


- (NSInteger)numberOfItemsInComboBoxCell:(NSComboBoxCell *)aComboBoxCell;
{
	BOOL isValueCell = [aComboBoxCell tag];
	if (isValueCell) {
		NSString *name = [[[self requestHeaderOrder] objectAtIndex:[headersTable selectedRow]] lowercaseString];
		if ([self isNameRequiringTodaysDateString:name]) {
			return 1;
		} else {
            NSArray *vals = [requestHeaderValues objectForKey:name];
			return [vals count];
		}
	} else {
		return [requestHeaderNames count];
	}
}


#pragma mark -
#pragma mark NSControlTextChangedNotification

- (void)controlTextDidChange:(NSNotification *)aNotification;
{
	id obj = [aNotification object];
	if (obj == headersTable) {
		[self handleComboBoxTextChanged:[aNotification object]];
		[self wasEdited];
	}
}


#pragma mark -
#pragma mark NSControlTextChangedNotification

- (void)controlTextDidEndEditing:(NSNotification *)aNotification;
{
	if (0 == lastClickedCol) {
		lastClickedCol++;
	}
}


#pragma mark -
#pragma mark SplitViewDelegate

- (float)splitView:(NSSplitView *)sender constrainMaxCoordinate:(float)proposedMax ofSubviewAt:(int)offset;
{
	if (offset == 0) {
		NSRect r = [[self window] frame];
		id innerHeight = [[WSDLWebView windowScriptObject] evaluateWebScript:InnerHeightScript];
		if (!innerHeight || [innerHeight isKindOfClass:[WebUndefined class]]) {
			return r.size.height - 130;
		} else {
			return [innerHeight intValue] + 75;
		}
	}
	return proposedMax;
}


- (float)splitView:(NSSplitView *)sender constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)offset;
{
	if (offset == 0) {
		return 80;
	}
	return proposedMin;
}


#pragma mark -
#pragma mark Accessors

- (BOOL)canExecute;
{
	return canExecute;
}


- (void)setCanExecute:(BOOL)yn;
{
	canExecute = yn;
}


- (SOAPCommand *)command;
{
	return command;
}


- (void)setCommand:(SOAPCommand *)cmd;
{
	if (command != cmd) {
		[command autorelease];
		command = [cmd retain];
		[windowScriptObject setValue:command forKey:@"Command"];
	}
}


- (id)windowScriptObject;
{
	return windowScriptObject;
}


- (void)setWindowScriptObject:(id)newObj;
{	
	if (windowScriptObject != newObj) {
		[windowScriptObject autorelease];
		windowScriptObject = [newObj retain];
	}
}

- (BOOL)isParsing;
{
	return parsing;
}


- (void)setParsing:(BOOL)yn;
{
	parsing = yn;
}


- (BOOL)isExecuting;
{
	return executing;
}


- (void)setExecuting:(BOOL)yn;
{
	executing = yn;
}


- (NSString *)WSDLURLString;
{
	return WSDLURLString;
}


- (void)setWSDLURLString:(NSString *)newStr;
{
	if (newStr != WSDLURLString) {
		[WSDLURLString autorelease];
		WSDLURLString = [newStr retain];
	}
}


- (NSString *)WSDLString;
{
	return WSDLString;
}


- (void)setWSDLString:(NSString *)newStr;
{
	if (WSDLString != newStr) {
		[WSDLString autorelease];
		WSDLString = [newStr retain];
	}
}


- (NSString *)statusString;
{
	return statusString;
}


- (void)setStatusString:(NSString *)newStr;
{
	if (newStr != statusString) {
		[statusString autorelease];
		statusString = [newStr retain];
	}
}


- (NSString *)username;
{
	return username;
}


- (void)setUsername:(NSString *)newStr;
{
	if (newStr != username) {
		[username autorelease];
		username = [newStr retain];
	}
}


- (NSString *)password;
{
	return password;
}


- (void)setPassword:(NSString *)newStr;
{
	if (newStr != password) {
		[password autorelease];
		password = [newStr retain];
	}
}


- (NSString *)authMessage;
{
	return authMessage;
}


- (void)setAuthMessage:(NSString *)newStr;
{
	if (newStr != authMessage) {
		[authMessage autorelease];
		authMessage = [newStr retain];
	}
}


- (BOOL)rememberPassword;
{
	return rememberPassword;
}


- (void)setRememberPassword:(BOOL)yn;
{
	rememberPassword = yn;
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
