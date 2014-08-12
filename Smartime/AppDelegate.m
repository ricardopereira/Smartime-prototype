//
//  AppDelegate.m
//  Smartime
//
//  Created by Ricardo Pereira on 07/04/14.
//  Copyright (c) 2014 Ricardo Pereira. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"

// Core Data
#import "NSManagedObject+InnerBand.h"
#import "ConfigData.h"
// Connection
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SBJson4.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Let the device know we want to receive push notifications
    
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];

    [self customizeUI];

    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];

    return YES;
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

    UIViewController *defaultView = (UIViewController *)self.window.rootViewController;
    if (defaultView.presentedViewController) {
        NSLog(@"Become active: %@",defaultView.presentedViewController);
        [defaultView.presentedViewController viewDidAppear:NO];
    } else {
        [defaultView viewDidAppear:NO];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);

    //UIPasteboard * pasteboard=[UIPasteboard generalPasteboard];
    //[pasteboard setString:[NSString stringWithFormat:@"%@",deviceToken]];

    // Guardar DeviceUDID
    UIViewController *defaultView = (UIViewController *)self.window.rootViewController;

    // Remover espacos
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];

    self.deviceUDID = token;

    // Registar na view principal
    if (defaultView && [defaultView isKindOfClass:[ViewController class]]) {
        ((ViewController *)defaultView).deviceUDID = token;

        // Teste
        //[(ViewController *)defaultView registerDeviceOnServer:token];
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // Handle notification when app is active
    NSLog(@"Received notification");

    NSString *message = nil;

    id alert = [userInfo objectForKey:@"aps"];

    if ([alert isKindOfClass:[NSString class]]) {
        message = alert;
    } else if ([alert isKindOfClass:[NSDictionary class]]) {
        message = [alert objectForKey:@"alert"];
    }

    if (alert) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alerta"
                                                            message:message  delegate:self
                                                  cancelButtonTitle:@"ok"
                                                  otherButtonTitles:nil, nil];

        [alertView show];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

    NSLog(@"Received background notification");

    //if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {

    // Verificar se tem mensagem
    NSString *message = nil;

    id aps = [userInfo objectForKey:@"aps"];

    if (aps && [aps isKindOfClass:[NSDictionary class]]) {
        message = [aps objectForKey:@"alert"];
    }

    if (message) {
        // Mostra a mensagem
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alerta"
                                                            message:message  delegate:self
                                                  cancelButtonTitle:@"ok"
                                                  otherButtonTitles:nil, nil];

        [alertView show];
    }
    else {
        // Refresca os dados
        //NSURL *url = [NSURL URLWithString:@"http://env-9374575.jelastic.lunacloud.com/ws/getStatusUpdate"];
        //NSURL *url = [NSURL URLWithString:@"http://m.google.com"];

        //ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        //[request setPostValue:self.deviceUDID forKey:@"UDID"];
        //[request setDelegate:self];
        //[request startAsynchronous];

        id pushData = [aps objectForKey:@"pushdata"];

        // Verificar resposta
        if (pushData == nil || ![pushData isKindOfClass:[NSString class]]) {
            NSLog(@"Push inválido");
            return;
        }

        // Parse da string
        NSArray* data = [(NSString*)pushData componentsSeparatedByString: @"&"];

        if (data.count < 2)
            return;

        NSString* callTicket = [data objectAtIndex: 0];
        NSString* lastTicket = [data objectAtIndex: 1];

        // Store data
        ConfigData* tempData = [ConfigData first];
        if (tempData == nil) {
            completionHandler(UIBackgroundFetchResultNoData);
            // Se não tem dados, não atualiza
            return;
        }

        tempData.ticketCurrent =  [NSNumber numberWithInt:[callTicket intValue]];
        tempData.ticketLast =  [NSNumber numberWithInt:[lastTicket intValue]];

        NSLog(@"Current %@, Last %@",tempData.ticketCurrent, tempData.ticketLast);

        [[IBCoreDataStore mainStore] save];

        NSLog(@"Push gravado com sucesso");

        self.eventAfterFetchData = ^(NSObject* sender)
        {
            completionHandler(UIBackgroundFetchResultNoData);
        };
    }

    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)requestFinished:(ASIHTTPRequest*)request
{
    if (request.responseStatusCode == 400) {
        // 400
        NSLog(@"Request failed: 400");
    }
    else if (request.responseStatusCode == 403) {
        // 403
        NSLog(@"Request failed: 403");
    }
    else if (request.responseStatusCode == 200) {
        // OK
        NSLog(@"Request: 200");
        NSData *responseData = [request responseData];

        // JSON
        NSError *jsonError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&jsonError];

        // Verificar resposta
        if (jsonObject == nil || [jsonObject count] == 0) {
            NSLog(@"%@: no answer",[request.originalURL absoluteString]);
            return;
        }

        //NSArray *result = [jsonObject firstObject];

        if ([[jsonObject valueForKey:@"current"] intValue] != -1) {
            NSString* str = nil;
            // Store data
            ConfigData* tempData = [ConfigData first];
            if (tempData == nil)
                tempData = [ConfigData create];

            str = [jsonObject objectForKey:@"current"];
            tempData.ticketCurrent =  [NSNumber numberWithInt:[str intValue]];

            str = [jsonObject objectForKey:@"last"];
            tempData.ticketLast =  [NSNumber numberWithInt:[str intValue]];

            NSLog(@"Current %@, Last %@",tempData.ticketCurrent, tempData.ticketLast);

            [[IBCoreDataStore mainStore] save];

            NSLog(@"Request success: %@",[request.originalURL absoluteString]);
        }
        else
        {
            [IBCoreDataStore clearAllData];

            NSLog(@"Request failed: 500");
        }
    }
    else {
        // Unexpected
        NSLog(@"Unexpected error");
    }

    // Fetched data
    if (self.eventAfterFetchData)
        self.eventAfterFetchData(self.window.rootViewController);
}

- (void)requestFailed:(ASIHTTPRequest*)request
{
    NSLog(@"Request failed");
}

# pragma mark Helper

- (void)customizeUI {
    // Customize status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

@end
