//
//  ViewController.h
//  Smartime
//
//  Created by Ricardo Pereira on 07/04/14.
//  Copyright (c) 2014 Ricardo Pereira. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *btQRCode;

@property (strong, nonatomic) NSString *deviceUDID;

- (void)registerDeviceOnServer:(NSString*)token;
- (void)refreshData;

@end
