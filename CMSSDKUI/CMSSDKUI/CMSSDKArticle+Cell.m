//
//  CMSSDKArticle+Cell.m
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/9.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "CMSSDKArticle+Cell.h"

@implementation CMSSDKArticle (Cell)

- (NSString *)cellIdentifier
{
    NSString *cellID = @"CMSTextCell";
    switch (self.displayType)
    {
        case 1:
            cellID = @"CMSLeftImageCell";
            break;
        case 2:
            cellID = @"CMSRightImageCell";
            break;
        case 3:
            cellID = @"CMSBottomImageCell";
            break;
        case 4:
            cellID = @"CMSThreeImageCell";
            break;
        default:
            break;
    }
    
    return cellID;
}

//- (CGFloat)theCellHeight
//{
//    CGFloat cellHeight = TextCellH;
//    switch (self.displayType)
//    {
//        case 1:
//            cellHeight = LeftorRightImgCellH;
//            break;
//        case 2:
//            cellHeight = LeftorRightImgCellH;
//            break;
//        case 3:
//            cellHeight = BottomImgCellH;
//            break;
//        case 4:
//            cellHeight = ThreeImgCellH;
//            break;
//        default:
//            break;
//    }
//    
//    return cellHeight;
//}

@end
