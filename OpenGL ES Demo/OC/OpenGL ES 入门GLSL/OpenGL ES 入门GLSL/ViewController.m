//
//  ViewController.m
//  OpenGL ES 入门GLSL
//
//  Created by 欧阳林 on 2019/6/23.
//  Copyright © 2019年 欧阳林. All rights reserved.
//

#import "ViewController.h"
#import "OMView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    OMView *aView = [[OMView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    [self.view addSubview:aView];
}


@end
