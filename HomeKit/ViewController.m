//
//  ViewController.m
//  HomeKit
//
//  Created by zving on 2017/12/27.
//  Copyright © 2017年 metal. All rights reserved.
//

#import "ViewController.h"
#import "RoomListVC.h"

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,HMHomeManagerDelegate,UIAlertViewDelegate,HMAccessoryBrowserDelegate>{
    
    __weak IBOutlet UICollectionView *_collectionView;
}
@property (nonatomic, retain) HMAccessoryBrowser *browser;
@property (nonatomic, retain) HMHomeManager *mananger;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 20;
    CGFloat width = (kScreenWidth-60)/3;
    layout.itemSize = CGSizeMake(width, width*1.2);
    [_collectionView setCollectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    self.mananger = [[HMHomeManager alloc]init];
    self.mananger.delegate = self;
    
    self.browser = [[HMAccessoryBrowser alloc]init];
    self.browser.delegate = self;
    
    
    NSLog(@"homes----------%@=====%lu",self.mananger.homes,(unsigned long)self.mananger.homes.count);
    
    
}
#pragma mark------- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.mananger.homes.count+1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    UILabel *lab = [cell viewWithTag:101];
    if (indexPath.row == self.mananger.homes.count) {
        lab.text = @"+";
    }else{
        NSString *name = self.mananger.homes[indexPath.row].name;
        lab.text = name;
    }
    return cell;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.mananger.homes.count) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加Home" message:@"请输入Home名称" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
        }];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self addHomeWithName:alert.textFields[0].text];
        }];
        [alert addAction:cancle];
        [alert addAction:confirm];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        HMHome *home = self.mananger.homes[indexPath.row];
        RoomListVC *listVC = myStoryboardId(@"RoomListVC");
        listVC.navigationItem.title = home.name;
        listVC.home = home;
        [self.navigationController pushViewController:listVC animated:YES];
    }
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(cut:)){
        return YES;   //此处以cut作为删除按钮使用
    }
    return NO;
}
- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    [self deleteHomeWithHome:self.mananger.homes[indexPath.row] indePath:indexPath];
}
- (IBAction)change:(UIBarButtonItem *)sender {
    [self.browser startSearchingForNewAccessories];
}
- (IBAction)edit:(UIBarButtonItem *)sender {
}
- (void)homeManagerDidUpdateHomes:(HMHomeManager *)manager{
    [_collectionView reloadData];
}
- (void)homeManager:(HMHomeManager *)manager didAddHome:(HMHome *)home{
    [_collectionView reloadData];
}
- (void)accessoryBrowser:(HMAccessoryBrowser *)browser didFindNewAccessory:(HMAccessory *)accessory{
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"发现了一个新设备" delegate:self cancelButtonTitle:@"知道了" destructiveButtonTitle:nil otherButtonTitles:accessory.name, nil];
    [sheet showInView:self.view];
}
#pragma mark------- 添加home
- (void)addHomeWithName:(NSString *)name{
    __weak typeof(self) weakSelf = self;
    __weak typeof(UICollectionView *) weakCollectionView = _collectionView;
    [self.mananger addHomeWithName:name completionHandler:^(HMHome * _Nullable home, NSError * _Nullable error) {
        if (!error) {
            [weakCollectionView reloadData];
        }else{
            [weakSelf showAlertWithError:error];
        }
        NSLog(@"name======%@,error======%@",home.name,error);
    }];
}
#pragma mark------- 删除home
- (void)deleteHomeWithHome:(HMHome *)home indePath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    __weak typeof(UICollectionView *) weakCollectionView = _collectionView;
    [self.mananger removeHome:home completionHandler:^(NSError * _Nullable error) {
        if (!error) {
            [weakCollectionView deleteItemsAtIndexPaths:@[indexPath]];
        }else{
            [weakSelf showAlertWithError:error];
        }
    }];
}
- (void)showAlertWithError:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:error.userInfo[@"NSLocalizedDescription"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.browser stopSearchingForNewAccessories];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
