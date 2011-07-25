#import "AppDelegate.h"
#import "SCController.h"
#import "PreferenceController.h"
#import <libxml/parser.h>

@interface AppDelegate (Private)
- (SCController *)currentController;
@end

@implementation AppDelegate

+ (void)initialize;
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionaryWithCapacity:1];
	
	[defaultValues setObject:[NSNumber numberWithInt:0] forKey:SCWrapTextViewTextKey];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults registerDefaults:defaultValues];
    
    xmlInitParser();
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    xmlCleanupParser();
}

- (void)dealloc
{
    [prefsWindowController release];
    [super dealloc];
}

#pragma mark -
#pragma mark Actions

- (IBAction)showPreferences:(id)sender;
{
    if (!prefsWindowController) {
        prefsWindowController = [[PreferenceController alloc] init];
    }
	[prefsWindowController showWindow:self];
}


#pragma mark -

- (BOOL)canExecute;
{
	return [[self currentController] canExecute];
}


- (BOOL)isParsing;
{
	return [[self currentController] isParsing];
}


- (SCController *)currentController;
{
	NSDocumentController *docCont = [NSDocumentController sharedDocumentController];
	NSWindowController *c = [[[docCont currentDocument] windowControllers] objectAtIndex:0];
	if ([c isKindOfClass:[SCController class]]) {
		return (SCController *)c;
	} else {
		return nil;
	}
}

@end
