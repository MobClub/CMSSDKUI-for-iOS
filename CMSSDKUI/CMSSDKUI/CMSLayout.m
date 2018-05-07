//
//  CMSLayout.m
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/2/28.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "CMSLayout.h"

@implementation CMSLayout

- (void)prepareLayout
{
    [super prepareLayout];
    
    self.minimumInteritemSpacing = 0;
    
    self.minimumLineSpacing = 0;
    
    if (self.collectionView.bounds.size.height)
    {
        self.itemSize = self.collectionView.bounds.size;
    }
    
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;

}

@end
