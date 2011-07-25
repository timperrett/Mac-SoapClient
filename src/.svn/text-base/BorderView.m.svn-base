#import "BorderView.h"

@implementation BorderView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		topColor = [NSColor grayColor];
	}
	return self;
}

- (void) dealloc {
	[topColor release];
	[super dealloc];
}


- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	[topColor set];
	[NSBezierPath strokeRect:rect];

}

@end
