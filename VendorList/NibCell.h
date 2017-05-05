//
//  NibCell.h
//  VendorList
//
//  Created by Saltmines-Mac2 on 18/12/15.
//  Copyright © 2015 Saltmines-Mac2. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol CellDelegate <NSObject>
//
//- (void)didClickOnCellAtIndex:(NSInteger)cellIndex withData:(id)data;
//
//@end


@interface NibCell : UICollectionViewCell




@property (strong, nonatomic) IBOutlet UIImageView *callimgvw;


@property (strong, nonatomic) IBOutlet UIImageView *imgvw;

@property (strong, nonatomic) IBOutlet UILabel *lbl1;

@property (strong, nonatomic) IBOutlet UILabel *lbl2;

@property (strong, nonatomic) IBOutlet UILabel *lbl3;





//@property (weak, nonatomic) id<CellDelegate>delegate;
//@property (assign, nonatomic) NSInteger cellIndex;


- (IBAction)pressButton:(id)sender;


@end
