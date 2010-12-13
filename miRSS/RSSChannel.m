//
//  RSSChannel.m
//  miRSS
//
//  Created by Alex Nichol on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RSSChannel.h"


@implementation RSSChannel

@synthesize channelDescription;
@synthesize channelTitle;
@synthesize channelLink;
@synthesize items;

- (int)getUniqueID {
	static int uid = 0;
	uid += 1;
	return uid;
}

- (int)uniqueID {
	NSLog(@"%p, Unique id: %d", self, uniqueID);
	return uniqueID;
}

- (void)setUniqueID:(int)uid {
	NSLog(@"%p, Set UID: %d", self, uid);
	uniqueID = uid;
}

- (id)initWithString:(NSString *)rssData {
	NSXMLDocument * document = [[NSXMLDocument alloc] initWithXMLString:rssData
																options:0
																  error:nil];
	if (!document) {
		return nil;
	}
	if (self = [self initWithXML:[document rootElement]]) {
		// we read it perfectly
		// uniqueID = [self getUniqueID];
	}
	return self;
}
- (id)initWithXML:(NSXMLNode *)rssDocument {
	if (self = [super init]) {
		// read the node
		uniqueID = [self getUniqueID];
		NSLog(@"%p, Got UID: %d", self, uniqueID);
		NSMutableArray * itemArray = [[NSMutableArray alloc] init];
		for (int i = 0; i < [rssDocument childCount]; i++) {
			NSXMLNode * subnode = [[rssDocument children] objectAtIndex:i];
			// read the node name
			if ([[subnode name] isEqual:@"title"]) {
				if ([subnode kind] == NSXMLElementKind)
					self.channelTitle = [subnode stringValue];
				else {
					NSLog(@"Invalid node type for 'title' node: %d", [subnode kind]);
					[super dealloc];
					return nil;
				}
			}
			if ([[subnode name] isEqual:@"link"]) {
				if ([subnode kind] == NSXMLElementKind)
					self.channelLink = [subnode stringValue];
				else {
					NSLog(@"Invalid node type for 'link' node.");
					[super dealloc];
					return nil;
				}
			}
			if ([[subnode name] isEqual:@"description"]) {
				if ([subnode kind] == NSXMLElementKind)
					self.channelDescription = [subnode stringValue];
				else {
					NSLog(@"Invalid node type for 'description' node.");
					[super dealloc];
					return nil;
				}
			}
			if ([[subnode name] isEqual:@"item"]) {
				if ([subnode kind] == NSXMLElementKind) {
					RSSItem * item = [[RSSItem alloc] initWithXML:subnode];
					[itemArray addObject:item];
					[item release];
				} else {
					NSLog(@"Invalid node type for 'item' node.");
					[super dealloc];
					return nil;
				}
			}
		}
		// don't make it global
		self.items = [NSArray arrayWithArray:itemArray];
		[itemArray release];
	}
	return self;
}

- (id)description {
	NSMutableString * humanReadable = [NSMutableString string];
	[humanReadable appendFormat:@"{ "];
	int i = 0;
	for (RSSItem * item in self.items) {
		[humanReadable appendFormat:@"Item #%d: %@,\n  ", ++i, item];
	}
	[humanReadable appendFormat:@" }"];
	return humanReadable;
}

- (void)dealloc {
	self.channelLink = nil;
	self.channelTitle = nil;
	self.channelDescription = nil;
	self.items = nil;
	[super dealloc];
}

@end