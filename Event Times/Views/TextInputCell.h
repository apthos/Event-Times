//
//  TextInputCell.h
//  Event Times
//
//  Created by David Lara on 7/20/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TextInputCell : UITableViewCell <UITextViewDelegate>

@property (strong, nonatomic) NSString *placeholder;
@property (assign) BOOL hasInput;

@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

NS_ASSUME_NONNULL_END
