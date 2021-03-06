//
//  ANApplication.m
//  miRSS
//
//  Created by Alex Nichol on 12/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ANApplication.h"


@implementation NSApplication (anapplication)

- (NSScriptObjectSpecifier *)objectSpecifier {
	NSLog(@"returning nil for NSApp's objectSpecifier");
	return nil;
}

- (NSArray *)rssfeeds {
	// read it from the manager
	NSMutableArray * returnValue = [NSMutableArray array];
	ANRSSManager * manager = *[ANCommandCounter mainManagerPointer];
	int count = [manager channelCount];
	[manager lock];
	for (int i = 0; i < count; i++) {
		NSDictionary * information = [manager channelAtIndex:i];
		RSSChannel * channel = (RSSChannel *)[information objectForKey:ANRSSManagerChannelRSSChannelKey];
		ANRSSFeed * feed = [[ANRSSFeed alloc] init];
		
		[feed setIndexnumber:[channel uniqueID]];
		[feed setRsstitle:@"Untitled"];
		if ([channel channelTitle])
			[feed setRsstitle:[NSString stringWithString:[channel channelTitle]]];
		else if ([channel channelLink]) {
			[feed setRsstitle:[NSString stringWithString:[channel channelLink]]];
		}
		if ([channel channelLink]) {
			[feed setRssurl:[NSString stringWithString:[information objectForKey:ANRSSManagerChannelURLKey]]];
		}
		[feed setUnread:[NSNumber numberWithInt:[manager unreadInChannelIndex:i lock:NO]]];
		
		NSMutableArray * articles = [[NSMutableArray alloc] init];
		for (int i = 0; i < [[channel items] count]; i++) {
			// set the properties of the article
			RSSItem * item = [[channel items] objectAtIndex:i];
			ANRSSArticle * article = [[ANRSSArticle alloc] init];
			[article setTitle:[NSString stringWithString:[item postTitle]]];
			[article setContent:[NSString stringWithString:[item postContent]]];
			[article setDate:[NSString stringWithString:[[item postDate] description]]];
			[article setIndex:[NSNumber numberWithInt:i]];
			[article setParentObject:feed];
			// add the article
			[articles addObject:article];
			[article release];
		}
		[feed setArticles:[articles autorelease]];
		[returnValue addObject:[feed autorelease]];
	}
	[manager unlock];
	return returnValue;
}
- (void)insertInRssfeeds:(ANRSSFeed *)feed {
	// add the URL
	ANRSSManager * manager = *[ANCommandCounter mainManagerPointer];
	NSLog(@"Adding RSS URL: %@", [feed rssurl]);
	[manager addRSSURL:[feed rssurl]];
}
- (void)insertInRssfeeds:(ANRSSFeed *)feed atIndex:(unsigned)index {
	// ignore index for now
	[self insertInRssfeeds:feed];
}
- (void)removeFromRssfeedsAtIndex:(unsigned)index {
	// remove the object at a certain index.
	ANRSSManager * manager = *[ANCommandCounter mainManagerPointer];
	[manager removeAtIndex:index];
}

- (NSNumber *)feedcount {
	ANRSSManager * manager = *[ANCommandCounter mainManagerPointer];
	return [NSNumber numberWithInt:[manager channelCount]];
}

- (NSNumber *)unread {	
	return [[ANRemoteAccessManager sharedRemoteAccess] totalUnread];
}

@end
