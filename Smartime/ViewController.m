//
//  ViewController.m
//  Smartime
//
//  Created by Ricardo Pereira on 07/04/14.
//  Copyright (c) 2014 Ricardo Pereira. All rights reserved.
//

#import "ViewController.h"

#import "CDZQRScanningViewController.h"

// Core Data
#import "NSManagedObject+InnerBand.h"
#import "ConfigData.h"
#import "ViewCodeController.h"
// Connection
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SBJson4.h"
#import "TSMessage.h"
#import "TSMessageView.h"

#import "MBProgressHUD.h"

#import <POP/POP.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [TSMessage setDefaultViewController:self];
}

- (void)viewDidAppear:(BOOL)animated {
    // Verificar código lidos
    NSArray *readedCodes = [ConfigData all];
    if (readedCodes.count > 0) {
        // Verificar se esta confirmado
        if ([(ConfigData*)[readedCodes objectAtIndex:0] ticketCurrent].intValue == -1) return;
        // Carrega os dados
        [self performSegueWithIdentifier:@"showCode" sender:self];
        //[self.storyboard instantiateViewControllerWithIdentifier:@"CodeView"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchQRCode:(id)sender {

    // Desaparecer
    POPBasicAnimation *opacityAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    opacityAnimation.fromValue = @(1);
    opacityAnimation.toValue = @(0);
    //[_btQRCode.layer pop_addAnimation:opacityAnimation forKey:@"opacityAnimation"];

    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.fromValue  = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
    scaleAnimation.toValue  = [NSValue valueWithCGSize:CGSizeMake(1.05f, 1.05f)];
    scaleAnimation.springBounciness = 50.0f;
    scaleAnimation.springSpeed = 20.0f;
    //scaleAnimation.dynamicsTension = 25;
    //scaleAnimation.dynamicsFriction = 5.0f;
    [_btQRCode.layer pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];



    CAKeyframeAnimation * anim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    anim.values = @[ [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-5.0f, 0.0f, 0.0f)],
                     [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(5.0f, 0.0f, 0.0f)] ];
    anim.autoreverses = YES;
    anim.repeatCount = 2.0f;
    anim.duration = 0.07f;

    //[_btQRCode.layer addAnimation:anim forKey:nil];

    return;

    // create the scanning view controller and a navigation controller in which to present it:
    CDZQRScanningViewController *scanningVC = [CDZQRScanningViewController new];
    UINavigationController *scanningNavVC = [[UINavigationController alloc] initWithRootViewController:scanningVC];

    // Configurar o QRCode reader
    scanningVC.resultBlock = ^(NSString *result) {

        // Sair do QRCode reader
        [scanningNavVC dismissViewControllerAnimated:YES completion:nil];

        // Validar a string do QRCode
        if (!result)
            return;

        // Parse da string
        NSArray* qrCodeData = [result componentsSeparatedByString: @"&"];

        if (qrCodeData.count < 6)
            return;

        //http://env-9374575.jelastic.lunacloud.com/smartime/regdevice.php&TerminalID=1&StoreID=1&ServiceID=1&DeskID=2&TicketNumber=23&Info='sdkjfhalsdkjfhajksdf'

        NSString* serverAddress = [qrCodeData objectAtIndex: 0];
        NSString* idTerminal = [qrCodeData objectAtIndex: 1];
        NSString* idStore = [qrCodeData objectAtIndex: 2];
        NSString* idService = [qrCodeData objectAtIndex: 3];
        NSString* idDesk = [qrCodeData objectAtIndex: 4];
        NSString* ticketNumber = [qrCodeData objectAtIndex: 5];

        // Limpa os dados antigos
        [IBCoreDataStore clearAllData];

        // Gravar os dados lidos
        ConfigData *data = [ConfigData create];

        data.serverAddress = serverAddress;

        data.idTerminal = [NSNumber numberWithInt:[idTerminal intValue]];
        data.idStore = [NSNumber numberWithInt:[idStore intValue]];
        data.idService = [NSNumber numberWithInt:[idService intValue]];
        data.idDesk = [NSNumber numberWithInt:[idDesk intValue]];
        data.ticketNumber = [NSNumber numberWithInt:[ticketNumber intValue]];
        // Sem confirmacao
        data.ticketCurrent = [NSNumber numberWithInt:-1];
        data.ticketLast = [NSNumber numberWithInt:-1];

        // Registar no servidor
        [self registerTicket:data];

        // Wait
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Validating...";

        // Mostrar informacao que leu do QRCode
        //UIAlertView *dialog = [[UIAlertView alloc] initWithTitle:@"QR-Code" message:serverAddress delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];

        //[dialog show];
    };
    scanningVC.cancelBlock = ^() {
        [scanningNavVC dismissViewControllerAnimated:YES completion:nil];
    };
    scanningVC.errorBlock = ^(NSError *error) {
        // todo: show a UIAlertView orNSLog the error
        [scanningNavVC dismissViewControllerAnimated:YES completion:nil];
    };

    // present the view controller full-screen on iPhone; in a form sheet on iPad:
    scanningNavVC.modalPresentationStyle = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? UIModalPresentationFullScreen : UIModalPresentationFormSheet;
    [self presentViewController:scanningNavVC animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    ViewCodeController *destVC = (ViewCodeController *)[segue destinationViewController];
    if (!destVC) return;

    ConfigData *savedCode = [ConfigData first];
    destVC.code = savedCode;
}

- (void)refreshData {

}

- (void)registerDeviceOnServer:(NSString*)token
{
    NSURL *url = [NSURL URLWithString:@"http://env-9374575.jelastic.lunacloud.com/ws/registerDeviceID"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:token forKey:@"regid"];
    [request setPostValue:@"2" forKey:@"platform"];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)registerTicket:(ConfigData*)readedData
{
    NSURL *url = [NSURL URLWithString:@"http://env-9374575.jelastic.lunacloud.com/ws/registerTicket"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];

    [request setPostValue:readedData.idTerminal forKey:@"terminalID"];
    [request setPostValue:readedData.idStore forKey:@"storeID"];
    [request setPostValue:readedData.idService forKey:@"serviceID"];
    [request setPostValue:readedData.idDesk forKey:@"deskID"];
    [request setPostValue:@"" forKey:@"date"];
    [request setPostValue:@"" forKey:@"hora"];
    [request setPostValue:self.deviceUDID forKey:@"deviceID"];
    [request setPostValue:readedData.ticketNumber forKey:@"ticketNumber"];

    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest*)request
{
    // Fechar o progesso
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    if (request.responseStatusCode == 400) {
        // 400
        [TSMessage showNotificationWithTitle:NSLocalizedString(@"Request to server: failed", nil)
                                    subtitle:NSLocalizedString(@"400 Error", nil)
                                        type:TSMessageNotificationTypeError];
    }
    else if (request.responseStatusCode == 403) {
        // 403
        [TSMessage showNotificationWithTitle:NSLocalizedString(@"Request to server: failed", nil)
                                    subtitle:NSLocalizedString(@"403 Error", nil)
                                        type:TSMessageNotificationTypeError];
    }
    else if (request.responseStatusCode == 200) {
        // OK
        NSData *responseData = [request responseData];

        // JSON
        NSError *jsonError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&jsonError];

        // Verificar resposta
        if (jsonObject == nil || [jsonObject count] == 0) {
            NSLog(@"%@: no answer",[request.originalURL absoluteString]);

            [TSMessage showNotificationWithTitle:NSLocalizedString(@"Request to server: failed", nil)
                                        subtitle:NSLocalizedString(@"JSON: no answer", nil)
                                            type:TSMessageNotificationTypeError];

            return;
        }

        //NSArray *result = [jsonObject objectForKey:@"result"];

        if ([[jsonObject valueForKey:@"result"] intValue] != -1) {
            // Store data
            [[IBCoreDataStore mainStore] save];

            ConfigData* tempData = [ConfigData first];
            tempData.ticketCurrent = [NSNumber numberWithInt:0];
            tempData.ticketLast = [NSNumber numberWithInt:0];
            [[IBCoreDataStore mainStore] save];

            //request.originalURL

            [TSMessage showNotificationWithTitle:NSLocalizedString(@"Senha", nil)
                                        subtitle:NSLocalizedString(@"Registada com sucesso", nil)
                                            type:TSMessageNotificationTypeSuccess];

            [self viewDidAppear:NO];
        }
        else
        {
            [IBCoreDataStore clearAllData];

            [TSMessage showNotificationWithTitle:NSLocalizedString(@"Senha", nil)
                                        subtitle:NSLocalizedString(@"Não é válida", nil)
                                            type:TSMessageNotificationTypeError];
        }
    }
    else {
        // Unexpected
        [TSMessage showNotificationWithTitle:NSLocalizedString(@"Request to server: failed", nil)
                                    subtitle:NSLocalizedString(@"Unexpected error", nil)
                                        type:TSMessageNotificationTypeError];
    }
}

- (void)requestFailed:(ASIHTTPRequest*)request
{
    NSError *error = [request error];
    // Connection problem
    [TSMessage showNotificationWithTitle:NSLocalizedString(@"Connection", nil)
                                subtitle:NSLocalizedString(error.description, nil)
                                    type:TSMessageNotificationTypeError];
}

@end
