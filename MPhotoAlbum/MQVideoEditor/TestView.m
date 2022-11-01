//
//  TestView.m
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/6/9.
//

#import "TestView.h"

@implementation TestView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.subtestView = [[UIView alloc] initWithFrame:CGRectMake(0, 220, 220, 222)];
    [self.father addSubview:self.subtestView];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)removeAllSubView
{
    [self.subtestView removeFromSuperview];
    self.subtestView = nil;
}

@end
