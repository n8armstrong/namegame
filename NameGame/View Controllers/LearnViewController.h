//
//  LearnViewController.h
//  NameGame
//
//  Created by Nate Armstrong on 8/14/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

@import UIKit;
@import CoreData;

#import "SwipeStackView.h"

@interface LearnViewController : UIViewController <SwipeStackViewDataSource, SwipeStackViewDelegate>

@property (nonatomic, weak) IBOutlet SwipeStackView *membersStackView;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, weak) IBOutlet UIButton *againButton;
@property (nonatomic, weak) IBOutlet UIButton *resetButton;
@property (nonatomic, weak) IBOutlet UILabel *downloadingLabel;

- (IBAction)againButtonTapped:(id)sender;
- (IBAction)resetButtonTapped:(id)sender;

@end
