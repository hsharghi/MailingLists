//
//  SelectionCell.m
//  MailingLists
//
//  Created by Hadi Sharghi on ۹۲/۱۰/۲۷ .
//  Copyright (c) ۱۳۹۲ ه‍.ش. eSoftWorks. All rights reserved.
//

#import "SelectionCell.h"

@implementation SelectionCell

@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.separatorInset = UIEdgeInsetsMake(0, 65, 0, 0);
        _contactPictureID = [[UIImageView alloc] initWithFrame:(CGRectMake(10, 10, 50, 50))];
        _contactPictureID.tag = 300;
        
        _contactName = [[UILabel alloc] initWithFrame:(CGRectMake(68, 10, 200, 30))];
        _contactName.font = [_contactName.font fontWithSize:20.0];
        _contactName.textAlignment = NSTextAlignmentLeft;
        _contactName.textColor = [UIColor colorWithRed:41/255.0 green:149/255.0 blue:192/255.0 alpha:1.0];
        _contactName.tag = 301;
        
        _emailAddress = [[UILabel alloc] initWithFrame:(CGRectMake(68, 37, 200, 20))];
        _emailAddress.font = [UIFont systemFontOfSize:16];
        _emailAddress.textAlignment = NSTextAlignmentLeft;
        _emailAddress.textColor = [UIColor darkGrayColor];
        _emailAddress.tag = 302;
        
        _selectedEmailState = [[UIButton alloc] initWithFrame:(CGRectMake(270, 14, 40, 40))];
        _selectedEmailState.tag = 303;
        [_selectedEmailState setImage:[UIImage imageNamed:@"Selected_None.png"] forState:UIControlStateNormal];
        [_selectedEmailState setImage:[UIImage imageNamed:@"Selected_All_Highlighted"] forState:UIControlStateHighlighted];
        [_selectedEmailState addTarget:self action:@selector(selectionSwitchTapped:) forControlEvents:UIControlEventTouchUpInside];
        _grayed = NO;
        _selectedEmailState.adjustsImageWhenHighlighted = NO;
        
        _cellBG = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,70)];
        _cellBG.tag = 304;
        _cellBG.image = [UIImage imageNamed:@"SelectContactCellBG.png"];
        
        
        [self.contentView addSubview:_contactPictureID];
        [self.contentView addSubview:_cellBG];
        [self.contentView addSubview:_contactName];
        [self.contentView addSubview:_emailAddress];
        [self.contentView addSubview:_selectedEmailState];
    }
    return self;
}


-(id)expandedCellWithArrayOfEmails:(NSArray *)emailsArray andLabels:(NSArray *)labelsArray
{
    if (!self)
        return nil;
    
    if (emailsArray.count <= 1)
        return self;
    
    UIColor *blue = [UIColor colorWithRed:41/255.0 green:149/255.0 blue:192/255.0 alpha:1.0];
    

    float offset = 70.0f;
    CGFloat height = offset + ((emailsArray.count - 1) * 50.0);
    UIImageView *shadowImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y + offset, self.bounds.size.width, height)];
    shadowImage.backgroundColor = blue;
    shadowImage.image = [[UIImage imageNamed:@"SubCellDropShadow.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(17.0, 17.0, 10.0, 12.0)];
    
    shadowImage.tag = 1003;
    [self.contentView addSubview:shadowImage];
    

    for (int i = 0; i < emailsArray.count; i++)
    {
        UILabel *emailAddress   = [[UILabel alloc] initWithFrame:CGRectMake(20, offset + (13 + (i * 50)), 200, 30)];
        UILabel *emailLabel     = [[UILabel alloc] initWithFrame:CGRectMake(20, offset + (38 + (i * 50)), 200, 20)];
        UIButton *selectedEmailState     = [UIButton buttonWithType:UIButtonTypeCustom];
        selectedEmailState.frame = CGRectMake(268, offset + (20 + (i * 50)), 40, 40);
        [selectedEmailState setImage:[UIImage imageNamed:@"Selected_None_Subcell.png"] forState:UIControlStateNormal];
        [selectedEmailState setImage:[UIImage imageNamed:@"Selected_All.png"] forState:UIControlStateSelected];
        [selectedEmailState addTarget:self action:@selector(expandedCellSwitchTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        emailAddress.tag =          (i+1)*1000+0;
        emailLabel.tag =            (i+1)*1000+1;
        selectedEmailState.tag =    (i+1)*1000+2;
        
        emailAddress.font = [UIFont systemFontOfSize:16];
        emailAddress.adjustsFontSizeToFitWidth = YES;
        emailLabel.font   = [UIFont systemFontOfSize:12];
        emailLabel.textColor = [UIColor darkGrayColor];
        emailAddress.text = emailsArray[i];
        emailLabel.text = labelsArray[i];
        
        selectedEmailState.userInteractionEnabled = YES;
        
        [self.contentView addSubview:emailAddress];
        [self.contentView addSubview:emailLabel];
        [self.contentView addSubview:selectedEmailState];
    }
    
    return self;
}


-(void)prepareForReuse
{
    [super prepareForReuse];
    
    for (UIView* subview in self.contentView.subviews){
        if (subview.tag >= 1000)
            [subview removeFromSuperview];
    }
    
}

-(UIButton *)getButtonForIndex:(NSUInteger)index
{
    UIButton *switchButton;
    NSUInteger tagOfSwitch = (index + 1) * 1000 + 2;
    for (UIView *view in self.contentView.subviews)
        if (view.tag == tagOfSwitch)
            switchButton = (UIButton *)view;
    
    return switchButton;
}

-(MLSelectedEmailState)checkSelectedState
{
    UIButton *switchButton;
    NSMutableArray *buttonsArray = [NSMutableArray array];
    int i = 0;
    int numberOfSelectedSwitches = 0;
    do
    {
        switchButton = nil;
        NSUInteger tagOfSwitch = (i + 1) * 1000 + 2;
        for (UIView *view in self.contentView.subviews)
            if (view.tag == tagOfSwitch)
            {
                switchButton = (UIButton *)view;
                [buttonsArray addObject:switchButton];
                break;
            }
        i++;
    } while (switchButton);
    
    for (UIButton *button in buttonsArray)
        if (button.selected)
            numberOfSelectedSwitches++;
    
    if (numberOfSelectedSwitches == buttonsArray.count)
        return kMLSelectedEmailAll;
    else if (numberOfSelectedSwitches > 0)
        return kMLSelectedEmailSome;
    else
        return kMLSelectedEmailNone;
}


-(void)selectionSwitchTapped:(id)sender
{
//    if (self.isSwitchOn)
//        [self setSwitchState:kMLSelectedEmailNone];
//    else
//        [self setSwitchState:kMLSelectedEmailAll];
    
    [self.delegate SwitchTapped:self];
}

-(BOOL)isSwitchOn
{
    if ((_selectedEmailState.selected) && (_grayed == NO))
        return YES;
    else
        return NO;
        
}

- (void)setSwitchState:(MLSelectedEmailState)selectState
{
    switch (selectState) {
        case kMLSelectedEmailNone:
        {
            _selectedEmailState.selected = NO;
            _grayed = NO;
        }
        break;
            
        case kMLSelectedEmailAll:
        {
            [_selectedEmailState setImage:[UIImage imageNamed:@"Selected_All.png"] forState:UIControlStateSelected];
            _selectedEmailState.selected = YES;
            _grayed = NO;
        }
        break;
            
        case kMLSelectedEmailSome:
        {
            [_selectedEmailState setImage:[UIImage imageNamed:@"Selected_Some.png"] forState:UIControlStateSelected];
            _selectedEmailState.selected  = YES;
            _grayed = YES;
        }
        break;
    }
}

- (MLSelectedEmailState) switchState
{
    if ((_selectedEmailState.selected) && (_grayed == NO))
        return kMLSelectedEmailAll;
    else if ((_selectedEmailState.selected) && (_grayed == YES))
        return kMLSelectedEmailSome;
    else
        return kMLSelectedEmailNone;
}

-(void)expandedCellSwitchTapped:(id)sender
{
    UIButton *switchButton = (UIButton *)sender;
    NSUInteger index = (int)(switchButton.tag / 1000) - 1;
    if (switchButton.selected)
        switchButton.selected = NO;
    else
        switchButton.selected = YES;
    
    [self setSwitchState:[self checkSelectedState]];
    [self.delegate expandedSwitchTapped:self indexOfSwitch:index];
}

- (BOOL)isSwitchOnForIndex:(NSUInteger)index
{
    UIButton *switchButton = [self getButtonForIndex:index];
    return  switchButton.selected;
}

- (void)setSwitchState:(MLSelectedEmailState)selectState forSwitchIndex:(NSUInteger)index
{
    UIButton *switchButton = [self getButtonForIndex:index];
    switch (selectState) {
        case kMLSelectedEmailNone:
        {
            switchButton.selected = NO;
            _selectedEmailState.selected = NO;
        }
            break;
            
        case kMLSelectedEmailSome:
        case kMLSelectedEmailAll:
        {
            [switchButton setImage:[UIImage imageNamed:@"Selected_All.png"] forState:UIControlStateSelected];
            switchButton.selected = YES;
        }
            break;
    }
    [self setSwitchState:[self checkSelectedState]];
}

- (MLSelectedEmailState) switchStateForIndex:(NSUInteger)index
{
    UIButton *switchButton = [self getButtonForIndex:index];
    if (switchButton.selected)
        return kMLSelectedEmailAll;
    else
        return kMLSelectedEmailNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
