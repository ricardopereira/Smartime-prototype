//
//  ViewCodeController.h
//  Smartime
//
//  Created by Ricardo Pereira on 11/04/14.
//  Copyright (c) 2014 Ricardo Pereira. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ConfigData.h"

@interface ViewCodeController : UIViewController

@property (strong, nonatomic) ConfigData *code;
@property (strong, nonatomic) IBOutlet UILabel *lblTicketNow;
@property (strong, nonatomic) IBOutlet UILabel *lblTicketLast;
@property (strong, nonatomic) IBOutlet UILabel *lblUserTicket;

@end
