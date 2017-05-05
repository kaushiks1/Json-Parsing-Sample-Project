//
//  ViewController.m
//  VendorList
//
//  Created by Saltmines-Mac2 on 18/12/15.
//  Copyright © 2015 Saltmines-Mac2. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btn1:(id)sender {
    
    
    VendorListParser *aListParser = [[VendorListParser alloc] init];
    
    [aListParser getVendorsList:^(NSMutableArray *vendorsList) {
        VendorListViewController *vndrlst=[[VendorListViewController alloc]initWithNibName:@"VendorListViewController" bundle:nil];
        vndrlst.vendorsList = vendorsList;
        [self.navigationController pushViewController:vndrlst animated:YES];
    } withFailureBlock:^(NSString *errorMessage) {
        UIAlertController *anAlertController = [UIAlertController alertControllerWithTitle:@"" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *anAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [anAlertController addAction:anAction];
        [self presentViewController:anAlertController animated:YES completion:^{
            
        }];
    }];
}




@end
