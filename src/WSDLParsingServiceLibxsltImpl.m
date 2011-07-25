//
//  WSDLParsingServiceLibxsltImpl.m
//  SOAP Client
//
//  Created by Todd Ditchendorf on 10/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "WSDLParsingServiceLibxsltImpl.h"
#import "AGRegex.h"
#import <libxml/xmlmemory.h>
#import <libxml/debugXML.h>
#import <libxml/HTMLtree.h>
#import <libxml/xmlIO.h>
#import <libxml/xinclude.h>
#import <libxml/catalog.h>
#import <libxslt/xslt.h>
#import <libxslt/xsltinternals.h>
#import <libxslt/transform.h>
#import <libxslt/xsltutils.h>
#import <libxslt/extensions.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>
#import <libexslt/exslt.h>

static xsltStylesheetPtr stylesheet = NULL;

@interface WSDLParsingServiceLibxsltImpl (Private)
+ (void)loadStylesheet;
+ (void)initializeLibxslt;
- (void)doParseWSDLAtURL:(NSString *)sourceURLString;
- (void)appendErrorMessage:(NSString *)msg;
- (void)setErrorMessage:(NSString *)newMsg;
- (void)error:(NSString *)msg;
- (void)doError:(NSString *)msg;
- (void)doneParsing:(NSString *)resultString;
- (NSString *)fetchResourceAtURL:(NSString *)sourceURLString finalURL:(NSString **)finalURLString;
@end

@implementation WSDLParsingServiceLibxsltImpl

static void myErrorHandler(id self, const char * msg, ...)
{
	va_list vargs;
	va_start(vargs, msg);
	
	NSString *msgStr = [[NSString alloc] initWithFormat:[NSString stringWithUTF8String:msg] arguments:vargs];
	
	[self appendErrorMessage:msgStr];
	
	[msgStr autorelease];
	va_end(vargs);
}


static int regexpModuleGetOptions(xmlChar *optStr)
{
	int opts = 0;
	NSString *flags = [NSString stringWithUTF8String:(char *)optStr];
	NSRange r = [flags rangeOfString:@"i"];
	if (NSNotFound != r.location)
		opts = (opts|AGRegexCaseInsensitive);
	r = [flags rangeOfString:@"s"];
	if (NSNotFound != r.location)
		opts = (opts|AGRegexDotAll);
	r = [flags rangeOfString:@"x"];
	if (NSNotFound != r.location)
		opts = (opts|AGRegexExtended);
	r = [flags rangeOfString:@"m"];
	if (NSNotFound != r.location)
		opts = (opts|AGRegexMultiline);	
	return opts;
}


static void regexpModuleFunctionReplace(xmlXPathParserContextPtr ctxt, int nargs)
{	
	int opts = 0;
	if (4 == nargs) {
		opts = regexpModuleGetOptions(xmlXPathPopString(ctxt));
	}
	
	const xmlChar *replacePattern = xmlXPathPopString(ctxt);
	const xmlChar *matchPattern = xmlXPathPopString(ctxt);
	const xmlChar *input = xmlXPathPopString(ctxt);
	
	AGRegex *regex = [AGRegex regexWithPattern:[NSString stringWithUTF8String:(const char*)matchPattern]
									   options:opts];
	
	NSString *result = [regex replaceWithString:[NSString stringWithUTF8String:(const char*)replacePattern]
									   inString:[NSString stringWithUTF8String:(const char*)input]];
	
	xmlXPathObjectPtr value = xmlXPathNewString((xmlChar *)[result UTF8String]);
	valuePush(ctxt, value);
}


static void regexpModuleFunctionTest(xmlXPathParserContextPtr ctxt, int nargs)
{	
	int opts = 0;
	if (3 == nargs) {
		opts = regexpModuleGetOptions(xmlXPathPopString(ctxt));
	}
	
	const xmlChar *matchPattern = xmlXPathPopString(ctxt);
	const xmlChar *input = xmlXPathPopString(ctxt);
	
	AGRegex *regex = [AGRegex regexWithPattern:[NSString stringWithUTF8String:(const char*)matchPattern]
									   options:opts];
	
	BOOL result = [[regex findInString:[NSString stringWithUTF8String:(const char*)input]] count];
	
	xmlXPathObjectPtr value = xmlXPathNewBoolean(result);
	valuePush(ctxt, value);
}


static void regexpModuleFunctionMatch(xmlXPathParserContextPtr ctxt, int nargs)
{	
	int opts = 0;
	if (3 == nargs) {
		opts = regexpModuleGetOptions(xmlXPathPopString(ctxt));
	}
	
	const xmlChar *matchPattern = xmlXPathPopString(ctxt);
	const xmlChar *input = xmlXPathPopString(ctxt);
	
	AGRegex *regex = [AGRegex regexWithPattern:[NSString stringWithUTF8String:(const char*)matchPattern]
									   options:opts];
	
	AGRegexMatch *match = [[regex findAllInString:[NSString stringWithUTF8String:(const char*)input]] objectAtIndex:0];
	
	int len = [match count];
	
	xmlNodePtr node = xmlNewNode(NULL, (const xmlChar *)"match");
	xmlNodeSetContent(node, (const xmlChar *)[[match groupAtIndex:0] UTF8String]);
	xmlNodeSetPtr nodeSet = xmlXPathNodeSetCreate(node);
	
	int i;
	NSString *item;
	for (i = 1; i < len; i++) {
		item = [match groupAtIndex:i];
		
		node = xmlNewNode(NULL, (const xmlChar *)"match");
		if (item) {
			xmlNodeSetContent(node, (const xmlChar *)[[match groupAtIndex:i] UTF8String]);
		} else {
			xmlNodeSetContent(node, (const xmlChar *)"");
		}
		xmlXPathNodeSetAdd(nodeSet, node);
	}
	
	xmlXPathObjectPtr value = xmlXPathWrapNodeSet(nodeSet);
	valuePush(ctxt, value);
}


static void *regexpModuleInit(xsltTransformContextPtr ctxt, const xmlChar *URI)
{	
	xsltRegisterExtFunction(ctxt, (const xmlChar *)"replace", URI,
							(xmlXPathFunction)regexpModuleFunctionReplace);
	xsltRegisterExtFunction(ctxt, (const xmlChar *)"test", URI,
							(xmlXPathFunction)regexpModuleFunctionTest);
	xsltRegisterExtFunction(ctxt, (const xmlChar *)"match", URI,
							(xmlXPathFunction)regexpModuleFunctionMatch);
	
	return NULL;
}


static void *regexpModuleShutdown(xsltTransformContextPtr ctxt,
								  const xmlChar *URI,
								  void *data)
{
	return NULL;
}


+ (void)initialize;
{
	[self initializeLibxslt];
	[self loadStylesheet];
}


+ (void)initializeLibxslt;
{
	xsltRegisterExtModule((const xmlChar *)"http://exslt.org/regular-expressions",
						  (xsltExtInitFunction)regexpModuleInit,
						  (xsltExtShutdownFunction)regexpModuleShutdown);
	
	xmlSubstituteEntitiesDefaultValue = 1;
	xmlLoadExtDtdDefaultValue = 1;
	exsltRegisterAll();
}


+ (void)loadStylesheet;
{
	NSString *xslPath = [[NSBundle mainBundle] pathForResource:@"wsdl2html" ofType:@"xsl"];
	NSString *cssPath = [[NSBundle mainBundle] pathForResource:@"wsdl2html" ofType:@"css"];
	NSString *jsPath  = [[NSBundle mainBundle] pathForResource:@"wsdl2html" ofType:@"js"];
	
	NSString *docStr = [NSString stringWithFormat:[NSString stringWithContentsOfFile:xslPath encoding:NSUTF8StringEncoding error:nil], 
		[cssPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
		[jsPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

	xmlDocPtr doc = xmlParseMemory([docStr UTF8String], [docStr length]);
	stylesheet = xsltParseStylesheetDoc(doc);
	
	if (!stylesheet) {
		NSLog(@"error parsing WSDL stylesheet");
	}
}


#pragma mark -

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
	[self setErrorMessage:nil];
	[super dealloc];
}


- (void)parseWSDLAtURL:(NSString *)URLString;
{
	[NSThread detachNewThreadSelector:@selector(doParseWSDLAtURL:)
							 toTarget:self
						   withObject:URLString];
}


- (void)parseWSDL:(NSData *)WSDLData;
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	xmlDocPtr source = NULL;
	xsltTransformContextPtr xformCtxt = NULL;
	xmlDocPtr res = NULL;
	xmlChar *resultStr = NULL;
	
	[self setErrorMessage:[NSMutableString string]];
	
	xmlSetGenericErrorFunc((void *)self, (xmlGenericErrorFunc)myErrorHandler);
	xsltSetGenericErrorFunc((void *)self, (xmlGenericErrorFunc)myErrorHandler);

	source = xmlParseMemory([WSDLData bytes], [WSDLData length]);
	
	if (!source || [errorMessage length]) {
		[self error:errorMessage];
		goto leave;
	}
		
	xformCtxt = xsltNewTransformContext(stylesheet, source);
	xsltSetTransformErrorFunc(xformCtxt, (void *)self, (xmlGenericErrorFunc)myErrorHandler);
	
	@try {
		res = xsltApplyStylesheet(stylesheet, source, NULL);
	}
	@catch (NSException *e) {
		[self error:[NSString stringWithFormat:@"Error while transforming WSDL: %@", [e reason]]];
		goto leave;
	}
	
	if (!res) {
		[self error:@"Error while transforming the WSDL using stylehseet."];
		goto leave;
	}
	
	int len;
	xsltSaveResultToString(&resultStr, &len, res, stylesheet);
	
	if (!resultStr) {
		[self error:@"The WSDL stylesheet experienced an error while saving the result to string."];
		goto leave;
	}
	
	NSString *rawResult = [NSString stringWithUTF8String:(const char *)resultStr];

	[self performSelectorOnMainThread:@selector(doneParsing:) 
						   withObject:rawResult
						waitUntilDone:NO];
	
leave: 
		// free memory
	if (res)
		xmlFreeDoc(res);
	if (source)
		xmlFreeDoc(source);
	if (xformCtxt)
		xsltFreeTransformContext(xformCtxt);
	if (resultStr)
		free(resultStr);
	
	[pool release];
}


- (void)appendErrorMessage:(NSString *)msg;
{
	[errorMessage appendString:msg];
}


- (void)setErrorMessage:(NSString *)newMsg;
{
	if (newMsg != errorMessage) {
		[errorMessage autorelease];
		errorMessage = [newMsg retain];
	}
}


- (void)error:(NSString *)msg;
{
	NSLog(@"error, msg: %@", msg);
	[self performSelectorOnMainThread:@selector(doError:)
						   withObject:msg
						waitUntilDone:NO];
}


- (void)doError:(NSString *)msg;
{
	[delegate WSDLParsingService:self didError:msg];
}


- (void)doneParsing:(NSString *)resultString;
{
	[delegate WSDLParsingService:self didFinish:resultString];
}

@end
