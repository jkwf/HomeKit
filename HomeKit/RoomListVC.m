//
//  RoomListVC.m
//  HomeKit
//
//  Created by zving on 2017/12/27.
//  Copyright © 2017年 metal. All rights reserved.
//

#import "RoomListVC.h"
#import "AccessoryListVC.h"

@interface RoomListVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UIAlertViewDelegate>{
    
    __weak IBOutlet UICollectionView *_collectionView;
}

@end

@implementation RoomListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 20;
    CGFloat width = (kScreenWidth-60)/3;
    layout.itemSize = CGSizeMake(width, width*1.2);
    [_collectionView setCollectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
}
#pragma mark------- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.home.rooms.count+1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    UILabel *lab = [cell viewWithTag:101];
    if (indexPath.row == self.home.rooms.count) {
        lab.text = @"+";
    }else{
        NSString *name = self.home.rooms[indexPath.row].name;
        lab.text = name;
    }
    return cell;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.home.rooms.count) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加Room" message:@"请输入Room名称" preferredStyle:UIAlertControllerStyleAlert];
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
        HMRoom *room = self.home.rooms[indexPath.row];
        AccessoryListVC *listVC = myStoryboardId(@"AccessoryListVC");
        listVC.navigationItem.title = room.name;
        listVC.room = room;
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
    [self deleteHomeWithRoom:self.home.rooms[indexPath.row] indePath:indexPath];
}
#pragma mark------- 添加Room
- (void)addHomeWithName:(NSString *)name{
    __weak typeof(self) weakSelf = self;
    __weak typeof(UICollectionView *) weakCollectionView = _collectionView;
    [self.home addRoomWithName:name completionHandler:^(HMRoom * _Nullable room, NSError * _Nullable error) {
        if (!error) {
            [weakCollectionView reloadData];
        }else{
            [weakSelf showAlertWithError:error];
        }
    }];
}
#pragma mark------- 删除Room
- (void)deleteHomeWithRoom:(HMRoom *)room indePath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    __weak typeof(UICollectionView *) weakCollectionView = _collectionView;
    [self.home removeRoom:room completionHandler:^(NSError * _Nullable error) {
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
