//
//  TextInputCell.m
//  Event Times
//
//  Created by David Lara on 7/20/20.
//  Copyright © 2020 David Lara. All rights reserved.
//

#import "TextInputCell.h"

#pragma mark -

@implementation TextInputCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.textView.delegate = self;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (!self.hasInput) {
        self.textView.text = @"";
        self.textView.textColor = UIColor.labelColor;;
    }
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.hasInput = ![self.textView.text isEqualToString:@""];
    
    if (!self.hasInput) {
        self.textView.text = self.placeholder;
        self.textView.textColor = UIColor.secondaryLabelColor;
    }
    
}

#pragma mark - Setters

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.textView.text = placeholder;
}

@end
