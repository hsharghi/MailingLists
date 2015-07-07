//
//  SelectionCell.h
//  MailingLists
//
//  Created by Hadi Sharghi on ۹۲/۱۰/۲۷ .
//  Copyright (c) ۱۳۹۲ ه‍.ش. eSoftWorks. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef uint32_t MLSelectedEmailState;
enum {
    kMLSelectedEmailNone        = 0,
    kMLSelectedEmailSome        = 1,
    kMLSelectedEmailAll         = 2
};


@protocol SelectionCellDelegate <NSObject>
@optional
- (void)SwitchTapped:(id)cell;
- (void)expandedSwitchTapped:(id)cell indexOfSwitch:(NSUInteger)index;
@end

@interface SelectionCell : UITableViewCell{
    BOOL _grayed;
}

@property (nonatomic, weak) id <SelectionCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIImageView *contactPictureID;
@property (strong, nonatomic) IBOutlet UILabel *contactName;
@property (strong, nonatomic) IBOutlet UILabel *emailAddress;
@property (strong, nonatomic) IBOutlet UILabel *tagLabel;
@property (strong, nonatomic) IBOutlet UIButton *selectedEmailState;
@property (strong, nonatomic) IBOutlet UIImageView *cellBG;
@property (readonly, nonatomic) BOOL isSwitchOn;
@property (readwrite, nonatomic) MLSelectedEmailState switchState;

// MultiEmail methods
- (id)expandedCellWithArrayOfEmails:(NSArray *)emailsArray andLabels:(NSArray *)labelsArray;
- (BOOL)isSwitchOnForIndex:(NSUInteger)index;
- (void)setSwitchState:(MLSelectedEmailState)selectState forSwitchIndex:(NSUInteger)index;
- (MLSelectedEmailState) switchStateForIndex:(NSUInteger)index;


- (IBAction) selectionSwitchTapped:(id)sender;
- (IBAction) expandedCellSwitchTapped:(id)sender;
- (void) setSwitchState:(MLSelectedEmailState)selectState;

@end


