//
//  MusicControllerView.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MusicControllerView.h"


@implementation MusicControllerView

- (void)dealloc {

  [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {

  if ((self = [super initWithFrame:frame])) {
  }

  return self;
}

- (void)drawRect:(CGRect)rect {

  // CGContextを用意する
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  // CGGradientを生成する
  // 生成するためにCGColorSpaceと色データの配列が必要になるので
  // 適当に用意する
  CGGradientRef gradient;
  CGColorSpaceRef colorSpace;
  size_t num_locations = 2;
  CGFloat locations[2] = { 0.0, 1.0 };
  CGFloat components[8] = { 0.1, 0.1, 0.1, 1.0,  // Start color
			    0.3, 0.3, 0.3, 1.0 }; // End color
  colorSpace = CGColorSpaceCreateDeviceRGB();
  gradient = CGGradientCreateWithColorComponents(colorSpace, components,
						 locations, num_locations);
  
  // 生成したCGGradientを描画する
  // 始点と終点を指定してやると、その間に直線的なグラデーションが描画される。
  // （横幅は無限大）
  CGPoint startPoint = CGPointMake(self.frame.size.width/2, 0.0);
  CGPoint endPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height);
  CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
  
  // GradientとColorSpaceを開放する
  CGColorSpaceRelease(colorSpace);
  CGGradientRelease(gradient);
}

@end
