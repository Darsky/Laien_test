//
//  ClockInViewController.m
//  oc_teacher_phone
//
//  Created by Darsky on 2023/6/7.
//  Copyright © 2023 朱伟铭. All rights reserved.
//

#import "ClockInViewController.h"
#import "ClockRecordCell.h"
#import "ClockInRecordModel.h"
#import "OCFMDBHelper.h"

@interface ClockInViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSDate *currentDate;

@property (assign, nonatomic) BOOL isToday;

@property (strong, nonatomic) NSMutableArray<ClockInRecordModel*> *recordsArray;

@property (weak, nonatomic) IBOutlet UILabel *statisticsLabel;

@property (weak, nonatomic) IBOutlet UIButton *currentMonthButton;

@property (weak, nonatomic) IBOutlet UITableView *recordTableView;

@property (weak, nonatomic) IBOutlet UIButton *clockInButton;

@property (strong, nonatomic) UIView *datePiackerView;

@property (strong, nonatomic) UIDatePicker *datePicker;

@property (strong, nonatomic) UIButton *dateCancelButton;

@property (strong, nonatomic) UIButton *dateConfirmButton;

@property (assign, nonatomic) BOOL datePickerShow;

@property (strong, nonatomic) UIView *timePiackerView;

@property (strong, nonatomic) UIDatePicker *timePicker;

@property (strong, nonatomic) UIButton *timeCancelButton;

@property (strong, nonatomic) UIButton *timeConfirmButton;

@property (assign, nonatomic) BOOL timePickerShow;


@end

static NSString *ClockRecordCellReuseID = @"ClockRecordCell";

@implementation ClockInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.recordTableView registerNib:[UINib nibWithNibName:ClockRecordCellReuseID
                                           bundle:[NSBundle mainBundle]]
     forCellReuseIdentifier:ClockRecordCellReuseID];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.currentDate == nil) {
        self.currentDate = [NSDate date];
        self.isToday = YES;
        self.recordsArray = [OCFMDBHelper queryDateRecordsWithDate:self.currentDate];
        NSDictionary *statistics = [OCFMDBHelper clockInStatistics];
        NSString *statisticsString = [NSString stringWithFormat:@"总打卡次数 %ld 总打卡天数 %ld \n 当前连续打卡天数 %ld 历史最高连续打卡天数 %ld ",[statistics[@"totalCount"] integerValue], [statistics[@"totalDayCount"] integerValue], [statistics[@"continuousDay"] integerValue], [statistics[@"maxContinuousDay"] integerValue]];
        self.statisticsLabel.text = statisticsString;
        
        [self.currentMonthButton setTitle:[OCFMDBHelper dateStringFromDate:self.currentDate]
                                 forState:UIControlStateNormal];
        [self.recordTableView reloadData];
    }
}

- (void)setupDatePickerView {
    self.datePiackerView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_BOUNDS.size.height, SCREEN_BOUNDS.size.width, SCREEN_BOUNDS.size.height)];
    self.datePiackerView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
    
    self.dateCancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.dateCancelButton.frame = CGRectMake(0, SCREEN_BOUNDS.size.height/2.0 - 40, 100, 40);
    [self.dateCancelButton setTitle:@"取消"
                           forState:UIControlStateNormal];
    [self.dateCancelButton addTarget:self
                              action:@selector(didTouchOnDateCancelButton)
                    forControlEvents:UIControlEventTouchUpInside];
    [self.datePiackerView addSubview:self.dateCancelButton];
    
    self.dateConfirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.dateConfirmButton.frame = CGRectMake(SCREEN_BOUNDS.size.width - 100, SCREEN_BOUNDS.size.height/2.0 - 40, 100, 40);
    [self.dateConfirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [self.dateConfirmButton addTarget:self
                               action:@selector(didTouchOnDateConfirmButton)
                     forControlEvents:UIControlEventTouchUpInside];

    [self.datePiackerView addSubview:self.dateConfirmButton];
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, SCREEN_BOUNDS.size.height - 300, SCREEN_BOUNDS.size.width, 300)];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.maximumDate = [NSDate date];
    self.datePicker.maskView.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 13.4, *)) {
        self.datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }
    [self.datePiackerView addSubview:self.datePicker];
    [[UIApplication sharedApplication].keyWindow addSubview:self.datePiackerView];
}

- (void)setupTimePickerView {
    self.timePiackerView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_BOUNDS.size.height, SCREEN_BOUNDS.size.width, SCREEN_BOUNDS.size.height)];
    self.timePiackerView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
    
    self.timeCancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.timeCancelButton.frame = CGRectMake(0, SCREEN_BOUNDS.size.height/2.0 - 40, 100, 40);
    [self.timeCancelButton setTitle:@"取消"
                           forState:UIControlStateNormal];
    [self.timeCancelButton addTarget:self
                              action:@selector(didTouchOnTimeCancelButton)
                    forControlEvents:UIControlEventTouchUpInside];
    [self.timePiackerView addSubview:self.timeCancelButton];
    
    self.timeConfirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.timeConfirmButton.frame = CGRectMake(SCREEN_BOUNDS.size.width - 100, SCREEN_BOUNDS.size.height/2.0 - 40, 100, 40);
    [self.timeConfirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [self.timeConfirmButton addTarget:self
                               action:@selector(didTouchOnTimeConfirmButton)
                     forControlEvents:UIControlEventTouchUpInside];

    [self.timePiackerView addSubview:self.timeConfirmButton];
    
    self.timePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, SCREEN_BOUNDS.size.height - 300, SCREEN_BOUNDS.size.width, 300)];
    self.timePicker.datePickerMode = UIDatePickerModeTime;
    self.timePicker.maskView.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 13.4, *)) {
        self.timePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }
    [self.timePiackerView addSubview:self.timePicker];
    [[UIApplication sharedApplication].keyWindow addSubview:self.timePiackerView];
}



#pragma OpreationUI Method

- (IBAction)didTouchOnDateButton:(id)sender {
    if (self.datePiackerView == nil) {
        [self setupDatePickerView];
    }
    [self showOrHideDatePickerView];
}

- (IBAction)didTouchOnClockInButton:(id)sender {
    if (self.isToday) {
        self.currentDate = [NSDate date];
        [OCFMDBHelper addRecordToTableWithDate:self.currentDate andSuccessBlock:^(ClockInRecordModel * _Nonnull recordModel, NSInteger totalCount, NSInteger totatDayCount, NSInteger continuousDay, NSInteger maxContinuousDay) {
            NSString *statisticsString = [NSString stringWithFormat:@"总打卡次数 %ld 总打卡天数 %ld \n 当前连续打卡天数 %ld 历史最高连续打卡天数 %ld ",totalCount, totatDayCount, continuousDay, maxContinuousDay];
            self.statisticsLabel.text = statisticsString;
            [self.recordsArray insertObject:recordModel atIndex:0];
            [self.recordTableView reloadData];
        } andErrorBlock:^(NSString * _Nonnull errorString) {
            [Constants showAAlertMessage:errorString
                                   title:@"温馨提示"];
        }];
    } else {
        if (self.timePiackerView == nil) {
            [self setupTimePickerView];
        }
        self.timePicker.date = self.currentDate;
        [self showOrHideTimePickerView];
    }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource Method

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView
                 cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    ClockRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:ClockRecordCellReuseID
                                                            forIndexPath:indexPath];
    if (nil == cell)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:ClockRecordCellReuseID
                                             owner:nil
                                           options:nil][0];
    }
    cell.recordLabel.text = self.recordsArray[indexPath.row].timestampFormatterString ? : @"";
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.recordsArray != nil) {
        return  self.recordsArray.count;
    } else {
        return 0;
    }
}

#pragma mark - UITableViewDelegate Method

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [Constants showAAlertMessage:@"确定删除该条打卡记录？"
                               title:@"温馨提示"
                         buttonTexts:@[@"取消",@"确定删除"]
                        buttonAction:^(int buttonIndex) {
            if (buttonIndex == 1) {
                if (indexPath.row < self.recordsArray.count) {
                    [OCFMDBHelper deleteRecordWithModel:self.recordsArray[indexPath.row] andSuccessBlock:^(NSInteger totalCount, NSInteger totatDayCount, NSInteger continuousDay, NSInteger maxContinuousDay) {
                        NSString *statisticsString = [NSString stringWithFormat:@"总打卡次数 %ld 总打卡天数 %ld \n 当前连续打卡天数 %ld 历史最高连续打卡天数 %ld ",totalCount, totatDayCount, continuousDay, maxContinuousDay];
                        self.statisticsLabel.text = statisticsString;
                        [self.recordsArray removeObjectAtIndex:indexPath.row];
                        [self.recordTableView reloadData];
                    } andErrorBlock:^(NSString * _Nonnull errorString) {
                        [Constants showAAlertMessage:errorString
                                               title:@"温馨提示"];
                    }];
                }

            }
        }];
    }
}

#pragma mark - OpreationPicker Method

- (void)showOrHideDatePickerView {
    self.view.userInteractionEnabled = NO;
    if (self.datePickerShow) {
        self.datePickerShow = NO;
        [UIView animateWithDuration:0.3
                         animations:^{
            self.datePiackerView.transform = CGAffineTransformIdentity;

        } completion:^(BOOL finished) {
            if (finished) {
                self.view.userInteractionEnabled = YES;
            }
        }];
    } else {
        self.datePickerShow = YES;
        [UIView animateWithDuration:0.3
                         animations:^{
            self.datePiackerView.transform = CGAffineTransformMakeTranslation(0, - self.datePiackerView.frame.size.height);
        } completion:^(BOOL finished) {
            if (finished) {
                self.view.userInteractionEnabled = YES;
            }
        }];
    }
}

- (void)didTouchOnDateCancelButton {
    [self showOrHideDatePickerView];
}

- (void)didTouchOnDateConfirmButton {
    [self showOrHideDatePickerView];
    self.currentDate = self.datePicker.date;
    
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self.currentDate];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    if([today day] == [otherDay day] && [today month] == [otherDay month] && [today year] == [otherDay year]) {
        self.isToday = YES;
    } else {
        self.isToday = NO;
    }
    [self.clockInButton setSelected:!self.isToday];
    [self.currentMonthButton setTitle:[OCFMDBHelper dateStringFromDate:self.currentDate]
                             forState:UIControlStateNormal];
    self.recordsArray = [OCFMDBHelper queryDateRecordsWithDate:self.currentDate];
    [self.recordTableView reloadData];
}

- (void)showOrHideTimePickerView {
    self.view.userInteractionEnabled = NO;
    if (self.timePickerShow) {
        self.timePickerShow = NO;
        [UIView animateWithDuration:0.3
                         animations:^{
            self.timePiackerView.transform = CGAffineTransformIdentity;

        } completion:^(BOOL finished) {
            if (finished) {
                self.view.userInteractionEnabled = YES;
            }
        }];
    } else {
        self.timePickerShow = YES;
        [UIView animateWithDuration:0.3
                         animations:^{
            self.timePiackerView.transform = CGAffineTransformMakeTranslation(0, - self.timePiackerView.frame.size.height);
        } completion:^(BOOL finished) {
            if (finished) {
                self.view.userInteractionEnabled = YES;
            }
        }];
    }
}

- (void)didTouchOnTimeCancelButton {
    [self showOrHideTimePickerView];
}

- (void)didTouchOnTimeConfirmButton {
    [self showOrHideTimePickerView];
    
    [OCFMDBHelper addRecordToTableWithDate:self.timePicker.date
                           andSuccessBlock:^(ClockInRecordModel * _Nonnull recordModel,
                                             NSInteger totalCount,
                                             NSInteger totatDayCount,
                                             NSInteger continuousDay,
                                             NSInteger maxContinuousDay) {
        NSString *statisticsString = [NSString stringWithFormat:@"总打卡次数 %ld 总打卡天数 %ld \n 当前连续打卡天数 %ld 历史最高连续打卡天数 %ld ",totalCount, totatDayCount, continuousDay, maxContinuousDay];
        self.statisticsLabel.text = statisticsString;
        [self.recordsArray insertObject:recordModel atIndex:0];
        [self.recordTableView reloadData];
    }
                             andErrorBlock:^(NSString * _Nonnull errorString) {
        [Constants showAAlertMessage:errorString
                               title:@"温馨提示"];
    }];
}

#pragma mark - OpreationData Method

@end
