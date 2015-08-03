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

@interface ViewController ()<NSFetchedResultsControllerDelegate>
//用于存放症状按钮
@property (strong,nonatomic)NSArray *symptomBtnArray;
//coreData的查询结果控制器
@property (strong,nonatomic)NSFetchedResultsController *fetchedResultsController;

@property (strong,nonatomic) Symptom *tempSymptom;

@property (strong,nonatomic) NSMutableArray *tempSick;
@property (strong,nonatomic) Sickness *sicknessObj;
@end

@implementation ViewController
- (NSArray *)setSymptomBtnArray{
    if (_symptomBtnArray == nil) {
        _symptomBtnArray = [[NSArray alloc]init ];
    }
    return _symptomBtnArray;
}

- (NSFetchedResultsController *)fetchedResultsController{
//    if (_fetchedResultsController == nil) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Symptom"];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"symptomID" ascending:YES];
        request.sortDescriptors = @[sort];
        _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:[QXCoreDataTools sharedCoreDataTools].managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController.delegate = self;
//    }
    
    return _fetchedResultsController;
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

    // 执行查询,过滤掉重复的症状
    // 这里用到两个临时数组和一个成员变量，将查询到的所有结果放在一个临时数组里面，遍历，如果有“头痛”就把这个对象赋值给成员变量，如果没有“头痛”就放到另一个临时数组里面，最后再把成员变量添加到第二个临时数组里面，方法比较复杂，抽时间看看有没有更好的过滤方法
    [self fetchedResultsController];
    [self.fetchedResultsController performFetch:NULL];
    NSMutableArray *tempArray1 = (NSMutableArray *)self.fetchedResultsController.fetchedObjects;
    NSMutableArray *tempArray2 = [NSMutableArray array];
    NSLog(@"%ld",tempArray1.count);
    for (int index = 0; index < tempArray1.count; index++) {
        Symptom *s = tempArray1[index];
        if ([s.symptomName isEqualToString:@"头痛"]) {
            self.tempSymptom = s;
        }else{
            [tempArray2 addObject:s];
        }
    }
    NSLog(@"------%@,%@",self.tempSymptom,tempArray2);
    [tempArray2 addObject:self.tempSymptom];
//    NSLog(@"----%@,%d",tempArray2,(int)tempArray2.count);
    
    NSInteger symptomsCount = tempArray2.count;
    for (int i = 0; i < symptomsCount; i++) {
        // 3.1 设置按钮的frame
        // 计算每个按钮所在的列的索引
        int colIdx = i % columns;
        // 计算每个按钮的行索引
        int rowIdx = i / columns;
        CGFloat symptomX = marginLeft + colIdx * (symptomW + marginX);
        CGFloat symptomY = marginTop + rowIdx * (symptomH + marginY);
        // 3.2 创建并设置按钮的属性
        UIButton *symptomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        symptomBtn.frame = CGRectMake(symptomX, symptomY, symptomW, symptomH);
        [symptomBtn addTarget:self action:@selector(clickSymptomBtnWithButton:) forControlEvents:UIControlEventTouchUpInside];
        Symptom *symptom = tempArray2[i];
        symptomBtn.tag = (int)symptom.symptomID;
        [self setAtributesWithButton:symptomBtn andBtnTitleName:symptom.symptomName];
        // 3.4 将按钮加到btnArray数组和self.view
        [tempArr  addObject:symptomBtn];
        [self.view addSubview:symptomBtn];
    }
    self.symptomBtnArray = tempArr;

    // 4.确定按钮
    UIButton *confirmBtn = [self createConfirmBtn];
    [confirmBtn addTarget:self action:@selector(confirmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmBtn];
    
    // 5.相关疾病
    // 5.1 创建一个大的scrollview 用来存放所有的相关疾病view
    UIScrollView *scrollView = [self createScrollViewWithCurrentMaxY:CGRectGetMaxY(confirmBtn.frame)];
    [self.view addSubview:scrollView];
    
    // 5.2 创建每个展示疾病相似度的sickView
    // 查询数据库中的疾病
    [self fetchResultWithEntityName:@"Sickness" sortDescriptorWithKey:@"sicknessID"];
    int sickCount = (int)self.fetchedResultsController.fetchedObjects.count;
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
        Sickness *sickness = self.fetchedResultsController.fetchedObjects[i];
        sickLabel.text = sickness.sicknessName;
        
        ////////////计算疾病的主症和兼症的占比
        sickness.mainSymPersent = @(18);
        sickness.secondarySymPersent = @(10);
        [self.tempSick addObject:sickness];
        
        
        
        // 将进度条和疾病名称添加到sickView
        [sickView addSubview:circleChart];
        [sickView addSubview:sickLabel];
        
        [scrollView addSubview:sickView];
    }
}

#pragma mark -----查询结果控制器的代理方法
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"查询结果变化了");
}

// 查询数据库
- (void)fetchResultWithEntityName:(NSString *)entity sortDescriptorWithKey:(NSString *)key
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entity];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:key ascending:YES];
    request.sortDescriptors = @[sort];
    _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:[QXCoreDataTools sharedCoreDataTools].managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [self.fetchedResultsController performFetch:NULL];
}

// 点击确定按钮
- (void)confirmBtnClick:(UIButton *)btn
{
    NSMutableArray *selectedBtns = [NSMutableArray array];
    // 1.获取所有状态为selected的按钮
    for (UIButton *btn in self.symptomBtnArray) {
        if (btn.selected == YES) {
            [selectedBtns addObject:btn];
        }
    }
    // 2.算出在一个疾病中每个症状占比是多少
        // 每个主症占比
        // 每个兼症占比
    // 3.将被选中的症状占比相加，得到总占比
    for (UIButton *btn in selectedBtns) {
        for (int i = 0; i < self.tempSick.count; i++) {
        
            if (btn.tag == [[self.tempSick[i] sicknessID]intValue]) {
                Sickness *sickness = self.tempSick[i];
                
            }
        }

    }
    // 4.将总占比传给进度条
    
    
}

// 点击症状按钮
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
    CGSize contentSize = self.view.frame.size;
    contentSize.height = contentSize.height * 0.5;
    scrollView.contentSize = contentSize ;
    scrollView.scrollEnabled = YES;
    return scrollView;
}

//设置症状按钮的属性
- (void)setAtributesWithButton:(UIButton *)btn andBtnTitleName:(NSString *)btnTitleName
{
    btn.backgroundColor = [UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1];
    btn.titleLabel.font = [UIFont systemFontOfSize: 11];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"symptom_btn_nomal.png"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"confirm_btn_disable.png"] forState:UIControlStateSelected];
    [btn setTitle:btnTitleName forState:UIControlStateNormal];
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
    //向Sickness实体中插入疾病数据
    //    Sickness *sickness3 = [NSEntityDescription insertNewObjectForEntityForName:@"Sickness" inManagedObjectContext:[QXCoreDataTools sharedCoreDataTools].managedObjectContext];
    //    sickness3.sicknessName = @"鼻渊";
    //    sickness3.sicknessID = @(1596);
    //向Symptom实体中插入症状数据
    //    Symptom *symptom1 = [NSEntityDescription insertNewObjectForEntityForName:@"Symptom" inManagedObjectContext:[QXCoreDataTools sharedCoreDataTools].managedObjectContext];
    //    symptom1.symptomName = @"鼻塞";
    //    symptom1.symptomID = @(11);
    //    symptom1.isMainSymptom = @(1);
    //    symptom1.sickness = sickness3;
    //保存上下文
    //    [[QXCoreDataTools sharedCoreDataTools]saveContext];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
