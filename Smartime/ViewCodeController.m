//
//  ViewCodeController.m
//  Smartime
//
//  Created by Ricardo Pereira on 11/04/14.
//  Copyright (c) 2014 Ricardo Pereira. All rights reserved.
//

#import "ViewCodeController.h"

#import "NSManagedObject+InnerBand.h"

@interface ViewCodeController ()

@end

@implementation ViewCodeController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if (self.code) {
            self.lblUserTicket.text = self.code.ticketNumber.stringValue;
            self.lblTicketNow.text = self.code.ticketCurrent.stringValue;
            self.lblTicketLast.text = self.code.ticketLast.stringValue;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.code) {
        self.lblUserTicket.text = self.code.ticketNumber.stringValue;
        self.lblTicketNow.text = self.code.ticketCurrent.stringValue;
        self.lblTicketLast.text = self.code.ticketLast.stringValue;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.code) {
        self.lblUserTicket.text = self.code.ticketNumber.stringValue;
        self.lblTicketNow.text = self.code.ticketCurrent.stringValue;
        self.lblTicketLast.text = self.code.ticketLast.stringValue;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTouchCancel:(id)sender {
    // Remover o codigo atual
    [IBCoreDataStore clearAllData];
    // Voltar ao inicio
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
