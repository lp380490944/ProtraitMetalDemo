
//
//  MainDefineHeader.h
//  PMRhythm
//
//  Created by k on 2020/7/28.
//  Copyright © 2020 kd. All rights reserved.
//

#ifndef MainDefineHeader_h
#define MainDefineHeader_h

#ifdef DEBUG
#define NSLog(format, ...) printf("[%s] %s [第%d行] %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define NSLog(format, ...)
#endif

#pragma mark
#pragma mark 加密配置信息
#define WIFIURL [UIDevice currentDevice].systemVersion.doubleValue>=10?@"QXBwLVByZWZzJTNBcm9vdCUzRFdJRkk=":@"cHJlZnMlM0Fyb290JTNEV0lGSQ=="
#define LocationURL [UIDevice currentDevice].systemVersion.doubleValue>=10?@"QXBwLVByZWZzJTNBcm9vdCUzRExPQ0FUSU9OX1NFUlZJQ0VT":@"cHJlZnMlM0Fyb290JTNETE9DQVRJT05fU0VSVklDRVM="

#pragma mark
#pragma mark 第三方配置信息

#define TuYaAppKey @"sk4cr9cwqfnxv7c9qxe7"
#define TuYaAppSecret @"5karyhjm3xy4yfhpy8krdaejtqrckt4w"

#pragma mark
#pragma mark 屏幕尺寸相关
// 设备
#define iPhone12 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1170, 2532), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhoneXR ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhoneXS_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
// tabbar高度
//#define TabBarHeight (iPhoneX||iPhoneXS_Max||iPhoneXR||iPhone12 ? (49+34) : 49)
// 屏幕宽高
#define KScreenW  [UIScreen mainScreen].bounds.size.width
#define KScreenH  [UIScreen mainScreen].bounds.size.height
#define KScreenScale [UIScreen mainScreen].scale
//等比宽
#define DEBI_width(CGFloat) (double)CGFloat/(double)375*KScreenW
//等比高
#define DEBI_height(CGFloat) (double)CGFloat/(double)667*KScreenH
//状态栏高度
#define kStatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
//导航栏高度
//#define NavHeight ((iPhoneX || iPhoneXS_Max || iPhoneXR) ? 88 : 64)
//这里直接借用QMUI里面的宏
#define NavHeight NavigationContentTop

#pragma mark
#pragma mark 边距等其他公用UI数据相关
//自定义弹框的确认按钮tag
#define alertViewTag 101
// 界面边距
#define indexMargin 16
#define topMargin 12
#define btnMargin 75//按钮左右边距
// btn 圆角
#define MaincornerRadius 8.0
// btn 高度
#define MainBtnHeight 50

//pickerView 高度
#define PickerViewHeight 211
//有背景图的背景图的高度
#define backImageViewHeight 417/2

#define kMenuMaxY 233//首页几个控制器距离顶部的距离

#define kAutomationTopHeaderHeight 88 //自动化首页 导航条的高度

//白色view 距离顶部的高度
#define contentDisTopHeight 160

#define diskViewWidth (KScreenW - indexMargin*2 - 20*2) //色盘宽高

//Masonry  宏定义  可以简化 masEqual = equal  mas_width = width
#define MAS_SHORTHAND_GLOBALS
#define MAS_SHORTHAND

//判断是不是全面屏
#define is_iPhoneXSerious UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom > 0.0

#pragma mark
#pragma mark 图片和字符串相关
#define PlaceHolderImage [UIImage imageNamed:@"暂无数据"] //公用缺省图片
#define HeaderPlaceHolderImage [UIImage imageNamed:@"默认头像"] //头像缺省图片
#define AddAuthoPlaceHolderImage [UIImage imageNamed:@"add"] //添加图片缺省图
#define setMyImage(_imageStr_) [UIImage imageNamed:_imageStr_]
//空字符串
#define NULLString(string) ((![string isKindOfClass:[NSString class]])||[string isEqualToString:@""] || (string == nil) || [string isEqualToString:@""] || [string isKindOfClass:[NSNull class]]||[[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0)

#pragma mark
#pragma mark 保存本地相关

#define LastHomeId @"homeId"
#define HomeUserRole @"HomeUserRole"
#define kTYHomeId @"tyHomeId"
#define UserId [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"] //用户id
#define kcurrentBrightnessValueKey @"currentBrightnessValue"
#define kCurrentBrightnessValue [[NSUserDefaults standardUserDefaults] objectForKey:kcurrentBrightnessValueKey]
#define UserEmail [[NSUserDefaults standardUserDefaults] objectForKey:@"email"]
#define SelectHomeIndex @"actionSelectIndex" //首页选择家庭的index

#pragma mark
#pragma mark alert相关

#define alertTitle @"提示"

#pragma mark
#pragma mark 网络请求相关p

//#define DevelopEnvironment //测试环境
//#define Test //临时环境
#define Formal //正式环境

#define kDefaultControlKey @"11223344"

#ifdef  DevelopEnvironment
#define BaseUrl @"https://testapi-us.easyhome.store/" // 测试地址
#define NONCE @"rhythm"
#define sercetKey  @"LGCSBnMznC8IO5L1"
//#define YsSDKUrl @"https://test15open.ys7.com"
#define YsSDKUrl 	 @"https://openapicn.eziot.com"
#define WebSocketUrl @"ws://81.69.16.244:10900"
#define kFAQUrl @"https://faqus.plusminuspro.com/"
#endif

#ifdef Formal
#define BaseUrl @"https://apius.plusminuspro.com/"
#define YsSDKUrl  @"https://openapius.eziot.com"//正式环境
#define NONCE @"rhythm"
#define sercetKey  @"2VDr4Uz2wpiKfb7C"
#define WebSocketUrl @"wss://apius.plusminuspro.com"
#define kFAQUrl @"https://faqus.plusminuspro.com"
#endif

#ifdef Test
//192.168.99.113 本地环境
#define BaseUrl  @"http://175.24.125.189:9140/"
#define YsSDKUrl @"https://openapicn.eziot.com"
#define NONCE @"rhythm"
#define sercetKey  @"2VDr4Uz2wpiKfb7C"
#define WebSocketUrl @"wss://81.69.16.244:10900"
#define kFAQUrl @"https://faqus.plusminuspro.com"
#endif



#define QiNiu_Scope     @"plusminus-pro"
#define QiNiu_AppKey    @"xEEarhz8L52FqUpWzEFZplL-v7lgHL-2YySgiTLT"
#define QiNiu_AppScret  @"4uorg-22gjfI-6su_vo3NsDopMIDDWX5Hu7lIUiH"

#define HttpCode @"code"
#define HttpCodeValue @"SUCCESS"
#define HttpMessage @"msg"

#define client_id @"AoHe497KcpBMro1K"
#define client_secret @"X1eVDzOeyjwY42kboG09M7J3qfcQ9qmM"



#define isSuccessed [responseObj[HttpCode] isEqualToString:HttpCodeValue]
#define TOKEN @"access_token"

#pragma mark
#pragma mark APP信息相关
// 系统版本
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
//版本号
#define APPVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
//APP名字
#define APPName [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]

#define myAppID @"1524969608"
// 下载地址
#define APPStoreUrl [NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/id%@",myAppID ]

#pragma mark
#pragma mark 颜色
//需要转换的颜色
#define PM_color(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
// 颜色
#define LCColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]

#define ThemeColor PM_color(0x1279FF) // 主题色
#define ContentColor PM_color(0xFFFFFF) // 主题内容色
#define BackGroundColor PM_color(0xF5F5F5) // 主题背景颜色
#define PMShadowColor   [UIColor colorWithHexString:@"666666"] // 阴影色
#define LCColor_B1   [UIColor colorWithHexString:@"000000"]
#define LCColor_B2   [UIColor colorWithHexString:@"333333"]
#define LCColor_B3   [UIColor colorWithHexString:@"666666"]
#define LCColor_B4   [UIColor colorWithHexString:@"999999"]
#define LCColor_B5   [UIColor colorWithHexString:@"CCCCCC"]
#define LCColor_B6   [UIColor colorWithHexString:@"EDEDED"]
#define LCLineColor   [UIColor colorWithHexString:@"DDDDDD"]
//随机色
#define random(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]
#define LCRandomColor random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

//辅助色
#define LCColor_RedColor   [UIColor colorWithHexString:@"EF476F"]

#define RGB(r,g,b) [UIColor colorWithRed:r green:g blue:b alpha:1.0f]
#define LCClearColor [UIColor clearColor]
#define LCWhiteColor [UIColor whiteColor]
#define LCTinitColor [UIColor colorWithHexString:@"1279FF"]
#define LCCommonBGColor   [UIColor colorWithHexString:@"F5F5F5"]

#pragma mark
#pragma mark 字体

#define setMyColor(_colorStr_) [UIColor colorWithHexString:_colorStr_]
#define setMyFont(_font_) [UIFont systemFontOfSize:_font_]
#define setBoldMyFont(_font_) [UIFont boldSystemFontOfSize:_font_]
#define setMyStr(_value_) [NSString stringWithFormat:@"%ld",_value_]
#define UIImageMake(_imageName_) [UIImage imageNamed:_imageName_]

#pragma weakself

#define LPWeakSelf __weak typeof(self) weakSelf = self;

//存储相关
#define PATH_OF_DOCUMENTS    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0]
#define PATH_OF_DEVICES_INFO [PATH_OF_DOCUMENTS stringByAppendingPathComponent:@"DevicesInfo.data"]
#define PATH_OF_CURRENT_CITY [PATH_OF_DOCUMENTS stringByAppendingPathComponent:@"CityEntity.data"]
#define PATH_OF_CURRENT_PID  [PATH_OF_DOCUMENTS stringByAppendingPathComponent:@"Pid.data"]
#define PATH_OF_BLE_DEVICES  [PATH_OF_DOCUMENTS stringByAppendingPathComponent:@"BleDevices.data"]
#define PATH_OF_BLE_ROOMS [PATH_OF_DOCUMENTS stringByAppendingPathComponent:@"Rooms.data"]
#define PATH_OF_TANGRAM_SHAPE [PATH_OF_DOCUMENTS  stringByAppendingPathComponent:@"TangramShpe.data"]



//音乐律动相关
#define YSRhythmPort 8484

//配网页面距离顶端的距离
#define kTopDistance 40


//七巧板相关宏定义
#define kTMShapeFactor 1

//画布的宽高
#define kCanvasWidth 800
#define kCanvasHeight 1000

//配网界面底部的边距

typedef NS_ENUM(NSInteger,ProductionType) { //产品类型 也就是产品的系列 比如 涂鸦的系列 萤石的系列等等
	TuYaType = 0,
	YingShiType,
	AliType,
    BoLianType
};
//global enum
typedef NS_ENUM(NSUInteger, LinkVCType) {
    LinkVCTypeGoogle,
    LinkVCTypeAlexa,
};
typedef NS_ENUM(NSUInteger, ScheduleType) {
    ScheduleTypeWakeUp = 1,
    ScheduleTypeGoSleep,
    ScheduleTypeSwitchOn,
    ScheduleTypeSwitchOff,
    ScheduleTypeDaskToDawn,
};
typedef NS_ENUM(NSUInteger,ControlVCType) {
    ControlVCTypeDevice,
    ControlVCTyGroup,
};
typedef NS_ENUM(NSUInteger, SencesType) {
    SencesTypePreset = 1,
    SencesTypeGradual,
    SencesTypeJump,
    SencesTypeStatic,
};
typedef NS_ENUM(NSUInteger, SceneColorType) {
	SceneColorTypeColor,//色彩
	SceneColorTypeTemperature,//色温
};
typedef NS_ENUM(NSUInteger, PMCommonVCEditType) {
	PMCommonVCEditTypeUnknow,//默认未知状态
	PMCommonVCEditTypeAdd,//添加
	PMCommonVCEditTypeEdit,//编辑
};
typedef NS_ENUM(NSUInteger, LogicType) {
	LogicTypeAnyConditionMet = 1,
	LogicTypeAllConditionMet,
};

typedef NS_ENUM(NSUInteger, PMTempType) {
	PMTempTypeCelsius = 1,//摄氏度
	PMTempTypeFahrenheit, //华氏度
};

typedef NS_ENUM(NSUInteger, ShareSourceVCType) {
	ShareSourceVCTypeHomeManage,//分享账号相关的页面一共有两个部分 一个是家庭管理页面 另一个是设备的info页面 这里由于分享的设备列表的hoemId 不一样所以需要做区分
	ShareSourceVCTypeDeviceInfo,
};

typedef NS_ENUM(NSInteger,PMBulbType) { //灯泡类型
    PMBulbTypeCW = 1, //白色有暖色类型
    PMBulbTypeC, //白色无暖色类型
    PMBulbTypeRGBCW, //彩色和暖色类型
    PMBulbTypeRGB//彩色无暖色
};

//当前三角板绘制的模式
typedef NS_ENUM(NSUInteger, PMDrawingMode) {
    PMDrawingModeTriangle,
    PMDrawingModeLed,
    PMDrawingModeTriangleEraser,
    PMDrawingModePenEraser,
    PMDrawingModeEffect,
};

#endif /* MainDefineHeader_h */
