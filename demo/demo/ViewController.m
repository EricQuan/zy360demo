//
//  ViewController.m
//  demo
//
//  Created by xdtc on 15/7/29.
//  Copyright (c) 2015年 xdtc. All rights reserved.
//

#import "ViewController.h"
#import "PNChart.h"
#import "PNCircleChart.h"
#import "Sickness.h"
#import "Symptom.h"
#import "QXCoreDataTools.h"

@interface ViewController ()
@property (strong,nonatomic)NSArray *symptomBtnArray;

@end

@implementation ViewController
- (NSArray *)setSymptomBtnArray{
    if (_symptomBtnArray == nil) {
        _symptomBtnArray = [[NSArray alloc]init ];
    }
    return _symptomBtnArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self writeData];
    
    // 1.导航条的文字
    UILabel *topLabel = [[UILabel alloc]init];
    topLabel.text =  [NSString stringWithFormat:@"疾病可能性"];
    topLabel.frame = CGRectMake(140, 20, 100, 44);
    [self.view addSubview: topLabel];
  
    // 2.提示选择的label
    UILabel *showLabel = [[UILabel alloc]init];
    showLabel.text =  [NSString stringWithFormat:@"请选择以下对应出现的症状"];
    showLabel.frame = CGRectMake(15, 64, 250, 35);
    [self.view addSubview: showLabel];
    // 灰色线条
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 99, self.view.frame.size.width, 1)];
    lineView.backgroundColor = [UIColor grayColor];
    [self.view  addSubview:lineView];

    // 3.symptomBtn症状按钮
    // 假设每行的症状按钮个数
    int columns = 4;
    // 获取控制器所管理的view的宽度
    CGFloat viewWidth = self.view.frame.size.width;
    // 每个症状按钮的宽高及间距
    CGFloat marginX = 10;
    CGFloat marginY = 9;
    // 左边的间距，上边的间距
    CGFloat marginLeft = 15;
    CGFloat marginTop = 115;
    // 症状按钮的宽高
    CGFloat symptomW = (viewWidth - marginLeft * 2 - (columns - 1)*marginX )/columns;
    CGFloat symptomH = 22;
    
    NSMutableArray *tempArr = [[NSMutableArray alloc]init];
    for (int i = 0; i < 17; i++) {
        // 3.1 设置按钮的frame属性
        // 计算每个单元格所在的列的索引
        int colIdx = i % columns;
        // 计算每个单元格的行索引
        int rowIdx = i / columns;
        CGFloat symptomX = marginLeft + colIdx * (symptomW + marginX);
        CGFloat symptomY = marginTop + rowIdx * (symptomH + marginY);
        
        UIButton *symptomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        symptomBtn.frame = CGRectMake(symptomX, symptomY, symptomW, symptomH);
        [self setAtributesWithButton:symptomBtn];
        [symptomBtn addTarget:self action:@selector(clickSymptomBtnWithButton:) forControlEvents:UIControlEventTouchUpInside];
        // 3.2 将按钮加到btnArray数组和self.view
        [tempArr  addObject:symptomBtn];
        [self.view addSubview:symptomBtn];
    }
    self.symptomBtnArray = tempArr;

    // 4.确定按钮
    UIButton *confirmBtn = [self createConfirmBtn];
    [self.view addSubview:confirmBtn];
    
    // 5.相关疾病
    // 5.1 创建一个大的scrollview 用来存放所有的相关疾病view
    UIScrollView *scrollView = [self createScrollViewWithCurrentMaxY:CGRectGetMaxY(confirmBtn.frame)];
    [self.view addSubview:scrollView];
    
    // 5.2 创建每个展示疾病相似度的sickView
    // 假设疾病有5种
    int sickCount = 8;
    for (int i = 0; i < sickCount; i++){
        //  创建sickView用来存放进度条和label
        UIView *sickView = [[UIView alloc]init];
        
        //  设置sickView 的frame
        // 计算每个sickView所在的列的索引
        int columns = 3;
        int colIdx = i % columns;
        // 计算每个sickView的行索引
        int rowIdx = i / columns;
        CGFloat marginLeft = 15;
        CGFloat marginTop = 10;
        CGFloat sickViewW = 93;
        CGFloat sickViewH = 140;
        CGFloat marginX = (self.view.frame.size.width - marginLeft * 2 - (sickViewW * columns)) / (columns - 1);
        CGFloat sickViewX = marginLeft + colIdx * (sickViewW + marginX);
        CGFloat sickViewY = marginTop + rowIdx * (sickViewH + marginTop);
        sickView.frame = CGRectMake(sickViewX, sickViewY,sickViewW,sickViewH);
        sickView.backgroundColor = [UIColor whiteColor];
        
        //  创建进度条
        PNCircleChart *circleChart = [[PNCircleChart alloc]initWithFrame:CGRectMake(0, 0, 93.0, 100.0) total:[NSNumber numberWithInt:100] current:[NSNumber numberWithInt:80] clockwise:YES shadow:(YES) shadowColor:[UIColor lightGrayColor]];
        [circleChart setStrokeColor:PNRed];
        [circleChart strokeChart];
        
        //  创建疾病名称sicklabel
        UILabel *sickLabel = [self createSickLabelWithCurrentMaxY:CGRectGetMaxY(circleChart.frame)];
        
        // 将进度条和疾病名称添加到sickView
        [sickView addSubview:circleChart];
        [sickView addSubview:sickLabel];
        
        [scrollView addSubview:sickView];
    }
}

- (void)clickSymptomBtnWithButton:(UIButton *)sickButton
{
    sickButton.selected = !sickButton.selected;
}

//创建疾病名称label
- (UILabel *)createSickLabelWithCurrentMaxY:(CGFloat)currentMaxY
{
    CGFloat sickLabelY = currentMaxY + 5;
    CGFloat sicklabelH = 26;
    CGFloat sicklabelW = 93;
    UILabel *sickLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, sickLabelY,sicklabelW, sicklabelH)];
    sickLabel.text = @"虚火旺盛";
    sickLabel.font = [UIFont systemFontOfSize:14];
    sickLabel.textAlignment = NSTextAlignmentCenter;
    [sickLabel.layer setCornerRadius:13.0];
    [sickLabel.layer setMasksToBounds:YES];
    [sickLabel.layer setBorderWidth:1.5];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 230.0/255, 230.0/255,230.0/255, 1 });
    [sickLabel.layer setBorderColor:colorref];
    return sickLabel;
}


//创建scrollView
- (UIScrollView *)createScrollViewWithCurrentMaxY:(CGFloat)maxY
{
    CGFloat scrollViewX = 0;
    CGFloat scrollViewY = maxY + 10;
    CGFloat scrollviewW = self.view.frame.size.width;
    CGFloat scrollviewH = self.view.frame.size.height - scrollViewY;
    UIScrollView * scrollView = [[UIScrollView alloc]init];
    scrollView.frame = CGRectMake(scrollViewX, scrollViewY, scrollviewW,scrollviewH);
    scrollView.backgroundColor = [UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1];
    scrollView.contentSize = self.view.frame.size;
    scrollView.scrollEnabled = YES;
    return scrollView;
}

//设置症状按钮的属性
- (void)setAtributesWithButton:(UIButton *)btn
{
    btn.backgroundColor = [UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1];
    btn.titleLabel.font = [UIFont systemFontOfSize: 11];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"symptom_btn_nomal.png"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"confirm_btn_disable.png"] forState:UIControlStateSelected];
    [btn setTitle:@"口中乏味" forState:UIControlStateNormal];
    [btn.layer setCornerRadius:11];
    [btn.layer setMasksToBounds:YES];
}

//创建确定按钮
- (UIButton *)createConfirmBtn
{
    CGFloat marginLeft = 15;
    CGFloat confirmBtnW = 60;
    CGFloat confirmBtnH = 25;
    CGFloat confirmBtnX = self.view.frame.size.width - marginLeft - confirmBtnW;
    UIButton *lastBtn = [self.symptomBtnArray lastObject];
    CGFloat confirmBtnY = CGRectGetMaxY(lastBtn.frame);
    UIButton *confirmBtn = [[UIButton alloc]initWithFrame:CGRectMake(confirmBtnX, confirmBtnY, confirmBtnW, confirmBtnH)];
    [confirmBtn setBackgroundImage:[UIImage imageNamed:@"confirm_btn_nomal.png"] forState:UIControlStateNormal];
    [confirmBtn setBackgroundImage:[UIImage imageNamed:@"confirm_btn_disable.png"] forState:UIControlStateDisabled];
    [confirmBtn setBackgroundImage:[UIImage imageNamed:@"confirm_btn_disable.png"] forState:UIControlStateSelected];
    [confirmBtn setTitle:[NSString stringWithFormat:@"确定"] forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [confirmBtn.layer setCornerRadius:3.0];
    [confirmBtn.layer setMasksToBounds:YES];
    return confirmBtn;
}

//插入数据
- (void)writeData
{
    
    //    Sickness *sickness3 = [NSEntityDescription insertNewObjectForEntityForName:@"Sickness" inManagedObjectContext:[QXCoreDataTools sharedCoreDataTools].managedObjectContext];
    //    sickness3.sicknessName = @"鼻渊";
    //    sickness3.sicknessID = @(1596);
    //
    //    Symptom *symptom1 = [NSEntityDescription insertNewObjectForEntityForName:@"Symptom" inManagedObjectContext:[QXCoreDataTools sharedCoreDataTools].managedObjectContext];
    //    symptom1.symptomName = @"鼻塞";
    //    symptom1.symptomID = @(11);
    //    symptom1.isMainSymptom = @(1);
    //    symptom1.sickness = sickness3;
    //
    //    [[QXCoreDataTools sharedCoreDataTools]saveContext];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
