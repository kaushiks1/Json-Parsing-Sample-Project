//
//  VendorListViewController.m
//  VendorList
//
//  Created by Saltmines-Mac2 on 18/12/15.
//  Copyright © 2015 Saltmines-Mac2. All rights reserved.
//

#import "VendorListViewController.h"
#import "NibCell.h"

@interface VendorListViewController ()

@end

@implementation VendorListViewController
@synthesize collectionView1;



- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg image"]];

    collectionView1.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    
    self.navigationController.navigationBarHidden=YES;

//    NSMutableArray *firstSection = [[NSMutableArray alloc] init]; NSMutableArray *secondSection = [[NSMutableArray alloc] init];
//    for (int i=0; i<50; i++) {
//        [firstSection addObject:[NSString stringWithFormat:@"Cell %d", i]];
//        [secondSection addObject:[NSString stringWithFormat:@"item %d", i]];
//    }
//    self.dataArray = [[NSArray alloc] initWithObjects:firstSection, secondSection, nil];
//    
    
    UINib *cellNib = [UINib nibWithNibName:@"NibCell" bundle:nil];
    [self.collectionView1 registerNib:cellNib forCellWithReuseIdentifier:@"cvCell"];
    
    

    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(160, 270)];

    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    [self.collectionView1 setCollectionViewLayout:flowLayout];
  //  collectionView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg image"]];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
   // return [self.dataArray count];
    return 1;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  //  NSMutableArray *sectionArray = [self.dataArray objectAtIndex:section];
   // return [sectionArray count];

    return [self.vendorsList count];
}



-(NibCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSMutableArray *data = [self.dataArray objectAtIndex:indexPath.section];
    
//    NSString *cellData = [data objectAtIndex:0];
    
    static NSString *cellIdentifier = @"cvCell";
    
    NibCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    NSLog(@"%ld",(long)indexPath.row);

    cell.callimgvw.tag = (long)indexPath.item;
    Vendor *aVendor = [self.vendorsList objectAtIndex:indexPath.item];
    cell.lbl2.text = aVendor.vendorName;
    cell.lbl3.text = [self convertHTML:aVendor.vendorDesc];
    cell.lbl1.text = [NSString stringWithFormat:@"$%0.2f",aVendor.price];
    
    NSLog(@"%@",[self convertHTML:aVendor.vendorDesc]);
    
    if (aVendor.vendorLogo.length > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *aUrl = [NSURL URLWithString:aVendor.vendorLogo];
           UIImage *aImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:aUrl]];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.imgvw.image = aImage;
            });
        });
    }
    
    return cell;
    
}

#pragma mark collection view cell paddings
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 20, 10, 20); // top, left, bottom, right
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {

    return 0.5;
}



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld",(long)indexPath.row);
    
    
//    NibCell *cell = (NibCell*)[collectionView cellForItemAtIndexPath:indexPath];
//    NSArray *views = [cell.contentView subviews];
//    UIButton *label = [views objectAtIndex:0];
//    NSLog(@"Select %ld",(long)label.tag);

}











/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)clsbtnactn:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}



-(NSString *)convertHTML:(NSString *)html {
    
    NSScanner *myScanner;
    NSString *text = nil;
    myScanner = [NSScanner scannerWithString:html];
    
    while ([myScanner isAtEnd] == NO) {
        
        [myScanner scanUpToString:@"<" intoString:NULL] ;
        
        [myScanner scanUpToString:@">" intoString:&text] ;
        
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    //
    html = [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return html;
}



@end
