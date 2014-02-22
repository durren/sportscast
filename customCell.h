//
//  customCell.h
//  sunny
//
//  Created by Durren Shen on 10/20/12.
//  Copyright (c) 2012 dshen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface customCell : UITableViewCell {
        
    IBOutlet UILabel *customTextLabel;
    IBOutlet UILabel *customDetailTextLabel;
    IBOutlet UIImageView *customImageView;
    IBOutlet UISlider *slider;
    IBOutlet UILabel *sliderLabel;
    IBOutlet UIView *cellview;
    IBOutlet UILabel *betLabel;
}

@property (retain, nonatomic) IBOutlet UIImageView *customImageView;
@property (retain, nonatomic) IBOutlet UILabel *customTextLabel;
@property (retain, nonatomic) IBOutlet UILabel *customDetailTextLabel;
@property (retain, nonatomic) IBOutlet UISlider *slider;
@property (retain, nonatomic) IBOutlet UILabel *sliderLabel;
@property (retain, nonatomic) IBOutlet UILabel *betLabel;

@property (retain, nonatomic) IBOutlet UIView *cellview;
- (IBAction)sliderAction:(UISlider*)slider;

@end
