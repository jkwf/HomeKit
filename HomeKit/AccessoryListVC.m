//
//  AccessoryListVC.m
//  HomeKit
//
//  Created by zving on 2017/12/27.
//  Copyright © 2017年 metal. All rights reserved.
//

#import "AccessoryListVC.h"

@interface AccessoryListVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UIAlertViewDelegate>{
    
    __weak IBOutlet UICollectionView *_collectionView;
}

@end

@implementation AccessoryListVC

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
    return self.room.accessories.count+1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    UILabel *lab = [cell viewWithTag:101];
    if (indexPath.row == self.room.accessories.count) {
        lab.text = @"+";
    }else{
        NSString *name = self.room.accessories[indexPath.row].name;
        lab.text = name;
    }
    return cell;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.room.accessories.count) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加Room" message:@"请输入Room名称" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
        }];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:cancle];
        [alert addAction:confirm];
        [self presentViewController:alert animated:YES completion:nil];
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
