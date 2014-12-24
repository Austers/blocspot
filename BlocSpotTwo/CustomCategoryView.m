//
//  CustomCategoryView.m
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 24/12/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import "CustomCategoryView.h"
#import "CustomCategoryTVC.h"
#import "AppDelegate.h"

@implementation CustomCategoryView

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self setup];
    }
    return self;
}

-(void)setup
{
    [[NSBundle mainBundle]loadNibNamed:@"CustomCategoryView" owner:self options:nil];
   // [self addSubview:self.view];
}

@end
