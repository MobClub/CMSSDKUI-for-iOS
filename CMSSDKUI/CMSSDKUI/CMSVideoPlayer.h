//
//  CMSVideoPlayer.h
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/17.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "CMSVideoPlayer_NameDef.h"

typedef enum
{
    CMSVideoPlayerStateUnknown = 0,
    CMSVideoPlayerStatePlay = 1,
    CMSVideoPlayerStatePause = 2,
    CMSVideoPlayerStateStalled = 3
}
CMSVideoPlayerState;

@class CMSVideoPlayer;

/**
 *  视频播放器委托协议
 */
@protocol CMSVideoPlayerDelegate <NSObject>


@optional
/**
 *  视频加载完成时触发
 *
 *  @param  videoPlayer 视频播放器
 */
- (void)videoPlayerReadyToPlay:(CMSVideoPlayer *)videoPlayer;

/**
 *  视频加载失败时触发
 *
 *  @param videoPlayer 视频播放器
 *  @param error       错误信息
 */
- (void)videoPlayer:(CMSVideoPlayer *)videoPlayer loadedFailWithError:(NSError *)error;

/**
 *  加载时长变更时触发
 *
 *  @param videoPlayer 视频播放器
 */
- (void)videoPlayerLoadedDurationChange:(CMSVideoPlayer *)videoPlayer;

/**
 *  播放结束时触发
 *
 *  @param videoPlayer 视频播放器
 */
- (void)videoPlayerFinishedPlay:(CMSVideoPlayer *)videoPlayer;

/**
 *  播放过程中触发，触发频率每秒一次
 *
 *  @param videoPlayer 视频播放器
 */
- (void)videoPlayerTimeUpdate:(CMSVideoPlayer *)videoPlayer;

/**
 *  播放状态变更时触发
 *
 *  @param videoPlayer 视频播放器
 */
- (void)videoPlayerPlaybackStateChange:(CMSVideoPlayer *)videoPlayer;

@end

/**
 *  视频播放器
 */
@interface CMSVideoPlayer : UIView

/**
 *  视频URL
 */
@property (nonatomic, retain) NSURL *url;

/**
 *  视频内容显示
 */
@property (nonatomic, copy) NSString *gravity;

/**
 *  播放状态
 */
@property (nonatomic, readonly) CMSVideoPlayerState state;

/**
 *  视频时长
 */
@property (nonatomic, readonly) NSTimeInterval duration;

/**
 *  已加载的视频时长
 */
@property (nonatomic, readonly) NSTimeInterval loadedDuration;

/**
 *  当前播放时间
 */
@property (nonatomic, readonly) NSTimeInterval currentTime;

/**
 *  委托对象
 */
@property (nonatomic, weak) id<CMSVideoPlayerDelegate> delegate;

/**
 *  音量
 */
@property (nonatomic) float volume;

/**
 *  播放
 */
- (void)play;

/**
 *  暂停
 */
- (void)pause;

/**
 *  设置播放起点
 *
 *  @param  time    播放起点时间
 *  @param  block   完成事件处理
 */
- (void)seek:(NSTimeInterval)time completion:(void(^)(BOOL finished))block;

/**
 *  销毁播放器
 */
- (void)dispose;

@end
