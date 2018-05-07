//
//  CMSVideoPlayer.m
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/17.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "CMSVideoPlayer.h"
#import <AVFoundation/AVFoundation.h>

static NSString *StatusKeyPath = @"status";
static NSString *LoadedTimeRangesKeyPath = @"loadedTimeRanges";

@interface CMSVideoPlayer ()
{
@private
    __weak id   _timeObserver;
    BOOL        _finished;
    BOOL        _isRemovePlayerItemObserver;
}

@end

@implementation CMSVideoPlayer

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)dealloc
{
    [self cleanup];
}

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (void)setUrl:(NSURL *)url
{
    _url = url;
    
    [self pause];
    [self cleanup];
    
    if (_url)
    {
        //先从父级视图中移除视频,避免在加载视频后无法刷新视图
        UIView *parentView = self.superview;
        NSInteger index = [parentView.subviews indexOfObject:self];
        [self removeFromSuperview];
        
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:_url];
        AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
        [((AVPlayerLayer *)self.layer) setPlayer:player];
        
        //获取时长
        CMTime totalTime = playerItem.duration;
        _duration = (CGFloat)totalTime.value/totalTime.timescale;
        
        //监听状态
        [player.currentItem addObserver:self
                             forKeyPath:StatusKeyPath
                                options:NSKeyValueObservingOptionNew
                                context:nil];
        [player.currentItem  addObserver:self
                              forKeyPath:LoadedTimeRangesKeyPath
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
        _isRemovePlayerItemObserver = NO;
        
        //监听播放完成事件
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playDidEndHandler:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:player.currentItem];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playbackStalledHandler:)
                                                     name:AVPlayerItemPlaybackStalledNotification
                                                   object:player.currentItem];
        
        //监听播放时间回调
        __weak CMSVideoPlayer *thePlayer = self;
        _timeObserver = [player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
            
            if (thePlayer.state == CMSVideoPlayerStatePlay)
            {
                //在播放情况下回调播放进度变更
                if ([thePlayer.delegate conformsToProtocol:@protocol(CMSVideoPlayerDelegate)] &&
                    [thePlayer.delegate respondsToSelector:@selector(videoPlayerTimeUpdate:)])
                {
                    [thePlayer.delegate videoPlayerTimeUpdate:thePlayer];
                }
            }
            
        }];
        
        //再次添加到父级视图中
        [parentView insertSubview:self atIndex:index];
    }
}

- (void)setVolume:(float)volume
{
    _volume = volume;
    
    AVPlayer *player = [(AVPlayerLayer *)self.layer player];
    NSArray *audioTracks = [player.currentItem.asset tracksWithMediaType:AVMediaTypeAudio];
    
    NSMutableArray *audioMixParams = [NSMutableArray array];
    for (int i = 0; i < audioTracks.count; i++)
    {
        AVAssetTrack *track = audioTracks [i];
        
        //设置音轨音量
        AVMutableAudioMixInputParameters *trackMix = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
        [trackMix setVolume:volume atTime:kCMTimeZero];
        [audioMixParams addObject:trackMix];
    }
    
    //设置混音
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = [NSArray arrayWithArray:audioMixParams];
    player.currentItem.audioMix = audioMix;
}

- (NSTimeInterval)currentTime
{
    CMTime time = [(AVPlayerLayer *)self.layer player].currentItem.currentTime;
    return (CGFloat)time.value / time.timescale;
}

- (NSString *)gravity
{
    return [(AVPlayerLayer *)self.layer videoGravity];
}

- (void)setGravity:(NSString *)aGravity
{
    [(AVPlayerLayer *)self.layer setVideoGravity:aGravity];
}

- (void)play
{
    _state = CMSVideoPlayerStatePlay;
    if (_finished)
    {
        //跳转到最开始重新播放
        __weak typeof(self) thePlayer = self;
        [self seek:0 completion:^(BOOL finished) {
            
            [[(AVPlayerLayer *)thePlayer.layer player] play];
            
        }];
        
        _finished = NO;
    }
    else
    {
        [[(AVPlayerLayer *)self.layer player] play];
    }
    
    //派发状态变更通知
    if ([self.delegate conformsToProtocol:@protocol(CMSVideoPlayerDelegate)] &&
        [self.delegate respondsToSelector:@selector(videoPlayerPlaybackStateChange:)])
    {
        [self.delegate videoPlayerPlaybackStateChange:self];
    }
}

- (void)pause
{
    _state = CMSVideoPlayerStatePause;
    [[(AVPlayerLayer *)self.layer player] pause];
    
    //派发状态变更通知
    if ([self.delegate conformsToProtocol:@protocol(CMSVideoPlayerDelegate)] &&
        [self.delegate respondsToSelector:@selector(videoPlayerPlaybackStateChange:)])
    {
        [self.delegate videoPlayerPlaybackStateChange:self];
    }
}

- (void)seek:(NSTimeInterval)time completion:(void (^)(BOOL finished))block
{
    _finished = NO;
    
    AVPlayer *player = [(AVPlayerLayer *)self.layer player];
    [player seekToTime:CMTimeMake(time * player.currentItem.duration.timescale, player.currentItem.duration.timescale)
     completionHandler:block];
}

- (void)dispose
{
    //主要销毁监听，使其自动释放
    if (_timeObserver)
    {
        AVPlayer *player = [(AVPlayerLayer *)self.layer player];
        [player removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
}

#pragma mark - Private

/**
 *  清除播放信息，并释放播放资源。
 */
- (void)cleanup
{
    _loadedDuration = 0.0;
    _duration = 0.0;
    _state = CMSVideoPlayerStateUnknown;
    _finished = NO;
    
    AVPlayer *player = [(AVPlayerLayer *)self.layer player];
    AVPlayerItem *playerItem = [[(AVPlayerLayer *)self.layer player] currentItem];
    
    if (!_isRemovePlayerItemObserver)
    {
        _isRemovePlayerItemObserver = YES;
        [playerItem removeObserver:self forKeyPath:StatusKeyPath];
        [playerItem removeObserver:self forKeyPath:LoadedTimeRangesKeyPath];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //移除时间监听
    if (_timeObserver)
    {
        [player removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
}

#pragma mark - Notification

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == [(AVPlayerLayer *)self.layer player].currentItem)
    {
        AVPlayerItem *playerItem = (AVPlayerItem*)object;
        
        if ([keyPath isEqualToString:StatusKeyPath])
        {
            switch (playerItem.status)
            {
                case AVPlayerItemStatusReadyToPlay:
                {
                    //视频加载完成
                    CMTime totalTime = playerItem.duration;
                    _duration = (CGFloat)totalTime.value/totalTime.timescale;
                    
                    if ([self.delegate conformsToProtocol:@protocol(CMSVideoPlayerDelegate)] &&
                        [self.delegate respondsToSelector:@selector(videoPlayerReadyToPlay:)])
                    {
                        [self.delegate videoPlayerReadyToPlay:self];
                    }
                    break;
                }
                case AVPlayerItemStatusFailed:
                {
                    //视频加载失败
                    [self cleanup];
                    
                    if ([self.delegate conformsToProtocol:@protocol(CMSVideoPlayerDelegate)] &&
                        [self.delegate respondsToSelector:@selector(videoPlayer:loadedFailWithError:)])
                    {
                        [self.delegate videoPlayer:self loadedFailWithError:playerItem.error];
                    }
                    break;
                }
                default:
                    break;
            }
        }
        else if ([keyPath isEqualToString:LoadedTimeRangesKeyPath])
        {
            NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
            
            if ([loadedTimeRanges count] > 0)
            {
                CMTimeRange timeRange = [[loadedTimeRanges firstObject] CMTimeRangeValue];
                float startSeconds = CMTimeGetSeconds(timeRange.start);
                float durationSeconds = CMTimeGetSeconds(timeRange.duration);
                
                _loadedDuration = startSeconds + durationSeconds;
            }
            else
            {
                _loadedDuration =  0.0f;
            }
            
            if (_state == CMSVideoPlayerStateStalled)
            {
                [self play];
            }
            
            //派发通知
            if ([self.delegate conformsToProtocol:@protocol(CMSVideoPlayerDelegate)] &&
                [self.delegate respondsToSelector:@selector(videoPlayerLoadedDurationChange:)])
            {
                [self.delegate videoPlayerLoadedDurationChange:self];
            }
        }
    }
}

- (void)playDidEndHandler:(NSNotification *)notif
{
    _state = CMSVideoPlayerStateUnknown;
    _finished = YES;
    
    //派发通知
    if ([self.delegate conformsToProtocol:@protocol(CMSVideoPlayerDelegate)])
    {
        if ([self.delegate respondsToSelector:@selector(videoPlayerFinishedPlay:)])
        {
            [self.delegate videoPlayerFinishedPlay:self];
        }
        
        if ([self.delegate respondsToSelector:@selector(videoPlayerPlaybackStateChange:)])
        {
            [self.delegate videoPlayerPlaybackStateChange:self];
        }
    }
}

- (void)playbackStalledHandler:(NSNotification *)notif
{
    _state = CMSVideoPlayerStateStalled;
    
    if ([self.delegate conformsToProtocol:@protocol(CMSVideoPlayerDelegate)] &&
        [self.delegate respondsToSelector:@selector(videoPlayerPlaybackStateChange:)])
    {
        [self.delegate videoPlayerPlaybackStateChange:self];
    }
}

@end
