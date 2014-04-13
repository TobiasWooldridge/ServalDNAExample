//
//  SPAppDelegate.m
//  ServalDNAExample
//
//  Created by James Moore on 4/5/14.
//  Copyright (c) 2014 The Serval Project. All rights reserved.
//

#import "SPAppDelegate.h"
#import "serval.h"

@implementation SPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

	// Create the folders that Serval needs
	[self setupServal];

	// install configuration file.

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		server();
	});


	return YES;
}

- (void)setupServal
{
	NSError *error;
	NSFileManager *fm = [NSFileManager defaultManager];

	// This avoids a first-run bug where the sockets are created before the folder are in place
	NSArray *servalFolders = @[
														 [NSString stringWithFormat:@"%@/var/run/serval/proc", SERVAL_ROOT],
														 [NSString stringWithFormat:@"%@/etc/serval", SERVAL_ROOT]
														];

	for (NSString *path in servalFolders) {

		[fm createDirectoryAtPath:path
	withIntermediateDirectories:YES
									 attributes:nil
												error:&error];

		if (error) {
			NSLog(@"Error occured making %@: %@", path, error.localizedDescription);
		}

	}

	// copy the configuration file into place
	NSString *confPath = [[NSBundle mainBundle] pathForResource:@"serval" ofType:@"conf" inDirectory:nil];
	NSString *etcPath = [NSString stringWithFormat:@"%@/etc/serval/serval.conf", SERVAL_ROOT];

	if (![fm copyItemAtPath:confPath toPath:etcPath error:&error]) {
		NSLog(@"Error occured copying config file %@ to %@: %@", confPath, etcPath, error);
	}

}


- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
	assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);

	NSError *error = nil;
	BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
																forKey: NSURLIsExcludedFromBackupKey error: &error];
	if(!success){
		NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
	}
	return success;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
