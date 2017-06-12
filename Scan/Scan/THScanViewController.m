//
//  ScanViewController.m
//  Scan
//
//  Created by WenQing on 2017/6/12.
//  Copyright © 2017年 com.rainbow. All rights reserved.
//

#import "THScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#define kScreenWidth     [UIScreen mainScreen].bounds.size.width
#define kScreenHeight    [UIScreen mainScreen].bounds.size.height

@interface THScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *session;//输入输出的中间桥梁

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIImageView *lineImgView;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) BOOL upOrdown;
@property (nonatomic, assign) NSInteger index;

@end


@implementation THScanViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(lineAnimated) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    
#if !TARGET_IPHONE_SIMULATOR
    [self setupAVCapture];
#endif
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
//    UIViewController *vc = [UIViewController new];
//    vc.view.backgroundColor = [UIColor whiteColor];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setupUI
{
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pick_bg"]];
    self.imageView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2.0, [UIScreen mainScreen].bounds.size.height/2.0);
    [self.view addSubview:self.imageView];
    
    self.lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, CGRectGetWidth(_imageView.frame)-30, 2.0f)];
    self.lineImgView.backgroundColor = [UIColor whiteColor];
    [self.imageView addSubview:self.lineImgView];
    
    
}

- (void)setupAVCapture
{
    //获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //创建输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //初始化链接对象
    _session = [[AVCaptureSession alloc] init];
    //高质量采集率
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [_session addInput:input];
    [_session addOutput:output];
    
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    output.rectOfInterest = CGRectMake(_imageView.frame.origin.y/kScreenHeight, _imageView.frame.origin.x/kScreenWidth, _imageView.frame.size.height/kScreenHeight, _imageView.frame.size.width/kScreenWidth);
    
    
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    
    //开始捕获
    [_session startRunning];
}

- (void)lineAnimated
{
    if (_upOrdown == NO){
        _index ++;
        CGRect frame = _lineImgView.frame;
        frame.origin.y = 15 + 2 *_index;
        _lineImgView.frame = frame;
        
        if (_lineImgView.frame.origin.y == _imageView.frame.size.height - 15) {
            _upOrdown = YES;
        }
    }else{
        _index--;
        CGRect frame = _lineImgView.frame;
        frame.origin.y = 15 + 2 *_index;
        _lineImgView.frame = frame;
        if (_index == 0) {
            _upOrdown = NO;
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        //输出扫描字符串
        NSLog(@"%@",metadataObject.stringValue);
    }
}

@end
