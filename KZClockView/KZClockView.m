//
//  KZClockView.m
//
//  Created by KingZ on 16/4/16.
//  Copyright © 2016年 kingz. All rights reserved.
//

#import "KZClockView.h"
#import "KZClockNum.h"

#define kMatrixW (self.bounds.size.width-kMatrixSpace*7-KMatrixXY*2)/8
#define kMatrixH kMatrixW/kMatrixHorNum(1,1)*kMatrixVerNum(1,1)

#define kPointW kMatrixW/kMatrixHorNum(1,1)
#define kRadius (kPointW)/2

#define kMatrixSpace 2
#define KMatrixXY 10

typedef struct{
    float x;
    float y;
    float g;
    float vx;
    float vy;
    CGColorRef color;
}ball;



@interface KZClockView (){
    CADisplayLink* _displayLink;
    
    ushort _hours;
    ushort _minutes;
    ushort _seconds;
    
    NSMutableArray* _balls;
    NSArray* _ballColors;
    
//    dispatch_queue_t _updataQueue;
//    dispatch_queue_t _renderQueue;
}

@end

@implementation KZClockView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setUpSelf];
        
    }
    return self;
}
- (void)setUpSelf{
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.layer.borderWidth = 1;
    
    _hours = [[[self class]getTradeNO:@"HH"]intValue];
    _minutes = [[[self class]getTradeNO:@"mm"]intValue];
    _seconds = [[[self class]getTradeNO:@"ss"]intValue];
    
    _balls = [[NSMutableArray alloc]init];
    
    _ballColors = @[[UIColor redColor],
                    [UIColor orangeColor],
                    [UIColor yellowColor],
                    [UIColor greenColor],
                    [UIColor purpleColor],
                    [UIColor cyanColor],
                    [UIColor greenColor],
                    [UIColor cyanColor],
                    ];
    
//    _updataQueue = dispatch_queue_create("updataQueue", DISPATCH_QUEUE_SERIAL);
//    _renderQueue = dispatch_queue_create("renderQueue", DISPATCH_QUEUE_SERIAL);
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self displayLink];
}
- (void)displayLink{
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updata)];

        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
}
- (void)updata{
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    [self render];
}
-(void)render{
    
    int hh = [[[self class]getTradeNO:@"HH"]intValue];
    int mm =[[[self class]getTradeNO:@"mm"]intValue];
    int ss = [[[self class]getTradeNO:@"ss"]intValue];
    
    
    [self renderWithNum:_hours/10 X:kMatrixSpace Y:KMatrixXY];
    [self renderWithNum:_hours%10 X:kMatrixSpace*2+kMatrixW Y:KMatrixXY];
    [self renderWithNum:10 X:kMatrixSpace*3+kMatrixW*2 Y:KMatrixXY];
    [self renderWithNum:_minutes/10 X:kMatrixSpace*4+kMatrixW*3 Y:KMatrixXY];
    [self renderWithNum:_minutes%10 X:kMatrixSpace*5+kMatrixW*4 Y:KMatrixXY];
    [self renderWithNum:10 X:kMatrixSpace*6+kMatrixW*5 Y:KMatrixXY];
    [self renderWithNum:_seconds/10 X:kMatrixSpace*7+kMatrixW*6 Y:KMatrixXY];
    [self renderWithNum:_seconds%10 X:kMatrixSpace*8+kMatrixW*7 Y:KMatrixXY];
    
    if (_seconds!=ss) {
        if (_seconds/10!=ss/10) {
            [self doAnmationWithNum:_seconds/10 X:kMatrixSpace*7+kMatrixW*6 Y:KMatrixXY];
        }
        if (_seconds%10!=ss%10) {
            [self doAnmationWithNum:_seconds%10 X:kMatrixSpace*8+kMatrixW*7 Y:KMatrixXY];
        }
        _seconds =ss;
    }else{
        [self updateBall];
    }
    if (_minutes!=mm) {
        if (_minutes/10!=mm/10) {
            [self doAnmationWithNum:_minutes/10 X:kMatrixSpace*4+kMatrixW*3 Y:KMatrixXY];
        }
        if (_minutes%10!=mm%10) {
            [self doAnmationWithNum:_minutes%10 X:kMatrixSpace*5+kMatrixW*4 Y:KMatrixXY];
        }
        _minutes =mm;
    }
    if (_hours !=hh) {
        if (_hours/10!=hh/10) {
            [self doAnmationWithNum:_hours/10 X:kMatrixSpace Y:KMatrixXY];
        }
        if (_hours%10!=hh%10) {
            [self doAnmationWithNum:_hours%10 X:kMatrixSpace*2+kMatrixW Y:KMatrixXY];
        }
        _hours =hh;
    }
    

}
- (void)renderWithNum:(ushort)num X:(float)x Y:(float)y{
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        //    CGContextRotateCTM(context, M_PI_2);
        CGContextSetFillColorWithColor(context, [UIColor orangeColor].CGColor);
        for (int i=0;i<kMatrixVerNum(num,i); i++) {
            for (int j=0; j<kMatrixHorNum(num,i); j++) {
                if (CLOCKNUMS[num][i][j] ==1) {
                    
                    CGContextAddArc(context, x+j*kPointW+kRadius, y+i*kPointW+kRadius, kRadius, 0, 2*M_PI, 0);
                    CGContextClosePath(context);
                    CGContextFillPath(context);
                    
                }
            }
        }

    
}
- (void)doAnmationWithNum:(ushort)num X:(float)x Y:(float)y{

    for (int i=0;i<kMatrixVerNum(num,i); i++) {
        for (int j=0; j<kMatrixHorNum(num,i); j++) {
            if (CLOCKNUMS[num][i][j] ==1) {
                @autoreleasepool {
                    ball bal={};
                    bal.x = x+j*kPointW+kRadius;
                    bal.y = y+i*kPointW+kRadius;
                    bal.g =1+(arc4random()%10)/10;
                    bal.vx = pow(-1, arc4random()%10)*kRadius*0.15;
                    bal.vy =- kRadius*0.2;
                    bal.color =[_ballColors[arc4random()%_ballColors.count] CGColor];
                    
                    [_balls addObject:[NSValue valueWithBytes:&bal objCType:@encode(typeof(ball))]];
                }
            }
        }
    }
//    [self updateBall];
}
- (void)updateBall{
    
        CGContextRef context = UIGraphicsGetCurrentContext();
        //    CGContextRotateCTM(context, M_PI_2);
        
        for (int index=0;index<_balls.count;index++) {
            @autoreleasepool {
                ball bal = {};
                [_balls[index] getValue:&bal];
                
                if (bal.x<=0) {
                    [_balls removeObject:[NSValue valueWithBytes:&bal objCType:@encode(typeof(ball))]];
                    
                    continue;
                }
                CGContextSetFillColorWithColor(context,bal.color);
                CGContextAddArc(context, bal.x, bal.y, kRadius, 0, 2*M_PI, 0);
                CGContextClosePath(context);
                CGContextFillPath(context);
                
                bal.x+=bal.vx;
                bal.y+=bal.vy;
                bal.vy+=bal.g;
                
                if (bal.y>=self.bounds.size.height-kRadius) {
                    bal.vy = -bal.vy*0.75;
                }
                if(bal.x>=self.bounds.size.width-kRadius){
                    
                    bal.vx = -0.4;
                }
                
                
                [_balls replaceObjectAtIndex:index withObject:[NSValue valueWithBytes:&bal objCType:@encode(typeof(ball))]];
            }
        }
    
}

+(NSString*)getTradeNO:(NSString*)formats{
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:formats];
    
    
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString* dateStr = [formatter stringFromDate:date];
    
    return dateStr;
    
}


@end
