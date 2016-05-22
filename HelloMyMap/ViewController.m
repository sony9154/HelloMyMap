//
//  ViewController.m
//  HelloMyMap
//
//  Created by Peter Yo on 3月/4/16.
//  Copyright © 2016年 Peter Hsu. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    BOOL isfirstLocationReceived; //隱含是false
}

@property (weak, nonatomic) IBOutlet MKMapView *mainMapView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //創造並初始化location manager
    locationManager = [CLLocationManager new];
    //告知蘋果使用地圖的時機  永遠開啟  或 使用時開啟  使用後者
    [locationManager requestWhenInUseAuthorization];
    
    //設定定位的準確度等級 一般來說有六種等級 Best為次佳等級 最高為BestForNavigation(導航軟體專用)
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //設定此app的活動種類(情境) 交通工具 運動 或是都不是(選擇other)
    locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    //將delegate指定給自身的viewController
    locationManager.delegate = self;
    //方法  開始回報位置
    [locationManager startUpdatingLocation];
    
    // 指定地圖資訊的delegate給本身的viewController
    _mainMapView.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//讓地圖用Segment按鈕去切換地圖類型的方法
- (IBAction)mapTypeChange:(id)sender {
    //讓切換按鈕去抓到目前選到的選項 使用selectedSegmentIndex這個方法
    NSInteger targetIndex = [sender selectedSegmentIndex];
    //使用swithch去切換地圖的種類 maptype
    switch (targetIndex) {
        case 0:
            _mainMapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            _mainMapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            _mainMapView.mapType = MKMapTypeHybrid;
            break;
            
        default:
            break;
    }
    
}
//設置地圖使用者模式 （會跟蹤使用者的移動軌跡Follew  跟蹤使用者的移動軌跡並且秀出使用者面對方向
//FollowWithHeading)
- (IBAction)userTrackingChange:(id)sender {
    
    NSInteger targetIndex = [sender selectedSegmentIndex];
    
    switch (targetIndex) {
        case 0:
            _mainMapView.userTrackingMode = MKUserTrackingModeNone;
            break;
        case 1:
            _mainMapView.userTrackingMode = MKUserTrackingModeFollow;
            break;
        case 2:
            _mainMapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
            break;
            
        default:
            break;
    }
    
    
    
}

#pragma mark - CLLocationManagerDelegate Methods
//將CLLocation儲存在loactions這個array的方法
//<CLLocation*> 將NSArray指定成只能輸入locations裡面的東西
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    //取得locations裡面最新的位置（相當於最後的Object)
    CLLocation * currentLocation = locations.lastObject;
    NSLog(@"Lat,Lon: %f,%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude);
    
    //讓布林值方法只執行第一次 用if的方法 執行過就會等於true
    if(isfirstLocationReceived == false)
    {
        //定義這個地圖呈現的位置  center代表中心點 讓自身位置＝中心點
        MKCoordinateRegion region = _mainMapView.region;
        region.center = currentLocation.coordinate;
        //定義地圖縮放的大小 經緯度各0.01 雖同時0.01不可能完成 但蘋果會自行調整
        //數值越大會縮放越小
        region.span.latitudeDelta = 0.01;
        region.span.longitudeDelta = 0.01;
        //讓地圖用動畫的方式移動到指定縮放的範圍及大小
        [_mainMapView setRegion:region animated:true];
        
        //讓值變成true就不會再度執行自動移動縮放的方法
        isfirstLocationReceived = true;
        
        //加上大頭針
        CLLocationCoordinate2D storeCoordinate = currentLocation.coordinate;
        //設定大頭針的虛擬位置 0.0005只是隨便加的  （假位置）
        storeCoordinate.latitude += 0.0005;
        storeCoordinate.longitude += 0.0005;
        //創造並初始化MKPointAnnotaion  Keep住大頭針詳細資訊
        //任何物件都可以進來 但必須支援這個protocal 一定要有coordinate 標題及副標題則非必需
        MKPointAnnotation * annotation = [MKPointAnnotation new];
        annotation.coordinate = storeCoordinate;
        //設置標題
        annotation.title = @"肯得基";
        //設置副標題
        annotation.subtitle = @"dilicious";
        
        //將大頭針的虛擬位置及詳細資訊加到地圖上
        [_mainMapView addAnnotation:annotation];
    }
    
}

//viewForAnnotation 讓我們決定如何顯示圖標
-(MKAnnotationView*) mapView:(MKMapView*)mapView viewForAnnotation:(nonnull id<MKAnnotation>)annotation
{
    
    if (annotation == mapView.userLocation) {
        return nil;
    }
    //為圖標取名
    NSString * identifier = @"KFC";
    //秀圖標前 詢問是否有重複的圖標 類同Cell回收可再利用的機制 如果有就重複使用 如果沒有變置換成我們自己的annotaion去取代他
    // MKPinAnnotationView 重新宣告並初始化一個大頭針在地圖
    //    MKPinAnnotationView * result = (MKPinAnnotationView*) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    //準備自定義大頭針的樣式
    MKAnnotationView * result = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (result == nil) {
        //        result = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:identifier];
        //針對自定義大頭針圖標修改的宣告及初始化
        result = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:identifier];
    }else{
        result.annotation = annotation;
    }
    
    //改變annotation的行為
    //打開預設行為 改為true
    result.canShowCallout = true;
    //改變大頭針的顏色
    //pinColor為ios9以前的寫法 已被蘋果淘汰 只有三種顏色 紅 綠 紫
    //result.pinColor = MKPinAnnotationColorRed;
    //ios9以後的寫法 可隨意指定顏色
    //    result.pinTintColor= [UIColor greenColor];
    //    //大頭針下降的動畫
    //    result.animatesDrop = true;
    
    
    
    //準備大頭針圖標的左邊小圖
    UIImage *image = [UIImage imageNamed:@"pointRed.png"];
    result.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:image];
    
    //準備大頭針圖標的右邊小圖 並去執行self裡面buttonPressed這個方法
    UIButton * button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    result.rightCalloutAccessoryView = button;
    
    //顯示自定義大頭針圖標
    result.image = image;
    
    return result;
}
-(void) buttonPressed:(id)sender{
    
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:@"ButtonPressed" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction * ok =[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:true completion:nil];
}

@end
