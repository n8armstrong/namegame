//
//  LearnViewController.m
//  NameGame
//
//  Created by Nate Armstrong on 8/14/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

@import NameGameKit;

#import "LearnViewController.h"
#import "QuizViewController.h"
#import "MemberView.h"
#import "NGMembersQuiz.h"

@interface LearnViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NGPreferences *prefs;

@end

@implementation LearnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.membersStackView.dataSource = self;
	self.membersStackView.delegate = self;
	[self.membersStackView setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (NGPreferences *)prefs
{
	if (!_prefs) _prefs = [[NGPreferences alloc] init];
	return _prefs;
}

- (void)setContext:(NSManagedObjectContext *)context
{
	_context = context;
	if (context == nil) return;

	NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[NGMember entityName]];
	request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
															  ascending:YES
															   selector:@selector(localizedCaseInsensitiveCompare:)]];
	request.predicate = [NSPredicate predicateWithFormat:@"memorized == NO"];
	self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
																		managedObjectContext:context
																		  sectionNameKeyPath:nil
																				   cacheName:nil];

	if (![self.prefs hasDownloadedMembers])
	{
		self.downloadingLabel.hidden = NO;
    	NSOperationQueue *queue = [NSOperationQueue new];
    	NGGetMembersOperation *membersOperation = [[NGGetMembersOperation alloc] initWithContext:context completionHandler:^{
			dispatch_async(dispatch_get_main_queue(), ^{
				self.downloadingLabel.hidden = YES;
				[self updateUI];
			});
    	}];
    	[queue addOperation:membersOperation];
	}
	else
	{
    	[self updateUI];
	}
}

- (void)updateUI
{
	NSError *fetchError = nil;
	[self.fetchedResultsController performFetch:&fetchError];
	if (fetchError == nil)
	{
		if ([self.fetchedResultsController fetchedObjects].count < 1)
		{
            self.resetButton.hidden = NO;
		}
		else
		{
        	[self.membersStackView reload];
		}
	}
}

- (IBAction)againButtonTapped:(id)sender
{
	self.againButton.hidden = YES;
	[self updateUI];
}

- (IBAction)unwindFromQuiz:(UIStoryboardSegue *)segue
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)resetButtonTapped:(id)sender
{
	self.fetchedResultsController.fetchRequest.predicate = nil;
	NSError *fetchError = nil;
	[self.fetchedResultsController performFetch:&fetchError];
	if (fetchError == nil)
	{
    	[[self.fetchedResultsController fetchedObjects] enumerateObjectsUsingBlock:^(NGMember *member, NSUInteger idx, BOOL *stop) {
			member.memorized = NO;
		}];
    	self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"memorized == NO"];
		self.resetButton.hidden = YES;
		[self updateUI];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"setQuiz:"])
	{
		QuizViewController *quizVC = (QuizViewController *)segue.destinationViewController;
		NGMembersQuiz *quiz = [[NGMembersQuiz alloc] initWithContext:self.context];
		quizVC.quiz = quiz;
	}
}

#pragma mark - SwipeStackViewDataSource

- (NSUInteger)numberOfViewsInStack
{
	return [self.fetchedResultsController fetchedObjects].count;
}

- (UIView *)swipeStackView:(SwipeStackView *)swipeStackView viewForIndexPath:(NSIndexPath *)indexPath
{
	NGMember *member = [self.fetchedResultsController objectAtIndexPath:indexPath];
	MemberView *view = [[MemberView alloc] initWithMember:member];
	[view hideMemorizedIndicators];
	return view;
}

#pragma - SwipeStackViewDelegate

- (void)swipeStackView:(SwipeStackView *)swipeStackView willSwipeView:(UIView *)view withVelocity:(CGPoint)velocity
{
	MemberView *memberView = (MemberView *)view;
	memberView.member.memorized = velocity.x > 0;
}

- (void)swipeStackView:(SwipeStackView *)swipeStackView didCancelSwipingView:(UIView *)view
{
	MemberView *memberView = (MemberView *)view;
	[memberView hideMemorizedIndicators];
}

- (void)swipeStackViewDidFinish:(SwipeStackView *)swipStackView
{
	self.againButton.hidden = NO;
}

@end
