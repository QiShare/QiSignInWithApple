//
//  ViewController.m
//  SignInWithApple
//
//  Created by wangyongwang on 2019/6/25.
//  Copyright © 2019 QiShare. All rights reserved.
//

#import "ViewController.h"
#import <AuthenticationServices/AuthenticationServices.h>

//! 当前帐号标识
NSString* const QiShareCurrentIdentifier = @"QiShareCurrentIdentifier";

// An interface for providing information about the outcome of an authorization request.
// 提供关于授权请求结果信息的接口
// An interface the controller uses to ask a delegate for a presentation context.
// 控制器的代理找一个展示授权控制器的上下文的接口
@interface ViewController () <ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding>

//! 用于展示appleID授权信息
@property (nonatomic, strong) UITextView *appleIDInfoTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 13.0, *)) {
        [self observeAppleSignInState];
        [self setupUI];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self perfomExistingAccountSetupFlows];
}

//! 添加苹果登录的状态通知
- (void)observeAppleSignInState {
    if (@available(iOS 13.0, *)) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(handleSignInWithAppleStateChanged:) name:ASAuthorizationAppleIDProviderCredentialRevokedNotification object:nil];
    }
}

//! 观察SignInWithApple状态改变
- (void)handleSignInWithAppleStateChanged:(id)noti {
    
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"%@", noti);
}

//! Prompts the user if an existing iCloud Keychain credential or Apple ID credential is found.
//! 如果存在iCloud Keychain 凭证或者AppleID 凭证提示用户
- (void)perfomExistingAccountSetupFlows {
    if (@available(iOS 13.0, *)) {
        // A mechanism for generating requests to authenticate users based on their Apple ID.
        // 基于用户的Apple ID授权用户，生成用户授权请求的一种机制
        ASAuthorizationAppleIDProvider *appleIDProvider = [ASAuthorizationAppleIDProvider new];
        // An OpenID authorization request that relies on the user’s Apple ID.
        // 授权请求依赖于用于的AppleID
        ASAuthorizationAppleIDRequest *authAppleIDRequest = [appleIDProvider createRequest];
        // A mechanism for generating requests to perform keychain credential sharing.
        // 为了执行钥匙串凭证分享生成请求的一种机制
        ASAuthorizationPasswordRequest *passwordRequest = [[ASAuthorizationPasswordProvider new] createRequest];
        
        NSMutableArray <ASAuthorizationRequest *>* mArr = [NSMutableArray arrayWithCapacity:2];
        if (authAppleIDRequest) {
            [mArr addObject:authAppleIDRequest];
        }
        if (passwordRequest) {
            [mArr addObject:passwordRequest];
        }
        // ASAuthorizationRequest：A base class for different kinds of authorization requests.
        // ASAuthorizationRequest：对于不同种类授权请求的基类
        NSArray <ASAuthorizationRequest *>* requests = [mArr copy];
        
        // A controller that manages authorization requests created by a provider.
        // 由ASAuthorizationAppleIDProvider创建的授权请求 管理授权请求的控制器
        // Creates a controller from a collection of authorization requests.
        // 从一系列授权请求中创建授权控制器
        ASAuthorizationController *authorizationController = [[ASAuthorizationController alloc] initWithAuthorizationRequests:requests];
        // A delegate that the authorization controller informs about the success or failure of an authorization attempt.
        // 设置授权控制器通知授权请求的成功与失败的代理
        authorizationController.delegate = self;
        // A delegate that provides a display context in which the system can present an authorization interface to the user.
        // 设置提供 展示上下文的代理，在这个上下文中 系统可以展示授权界面给用户
        authorizationController.presentationContextProvider = self;
        // starts the authorization flows named during controller initialization.
        // 在控制器初始化期间启动授权流
        [authorizationController performRequests];
    }
}

- (void)setupUI {
    
    // 用于展示Sign In With Apple 登录过程的信息
    _appleIDInfoTextView = [[UITextView alloc] initWithFrame:CGRectMake(.0, 40.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) * 0.4) textContainer:nil];
    _appleIDInfoTextView.font = [UIFont systemFontOfSize:32.0];
    [self.view addSubview:_appleIDInfoTextView];
    
    // 移除键盘Button
    UIButton *removeKeyboardBtn = [[UIButton alloc] init];
    removeKeyboardBtn.backgroundColor = [UIColor grayColor];
    [removeKeyboardBtn setTitle:@"移除键盘" forState:UIControlStateNormal];
    removeKeyboardBtn.frame = CGRectMake(CGRectGetMidX(_appleIDInfoTextView.frame) - 50.0, CGRectGetMaxY(_appleIDInfoTextView.frame), 100.0, 40.0);
    [removeKeyboardBtn addTarget:self action:@selector(removeFirstResponder:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:removeKeyboardBtn];

    if (@available(iOS 13.0, *)) {
    // Sign In With Apple Button
    ASAuthorizationAppleIDButton *appleIDButton = [ASAuthorizationAppleIDButton new];
        
    appleIDButton.frame =  CGRectMake(.0, .0, CGRectGetWidth(self.view.frame) - 40.0, 100.0);
    CGPoint origin = CGPointMake(20.0, CGRectGetMidY(self.view.frame));
    CGRect frame = appleIDButton.frame;
    frame.origin = origin;
    appleIDButton.frame = frame;
    appleIDButton.cornerRadius = CGRectGetHeight(appleIDButton.frame) * 0.25;
    [self.view addSubview:appleIDButton];
    [appleIDButton addTarget:self action:@selector(handleAuthrization:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    NSMutableString *mStr = [NSMutableString string];
    [mStr appendString:@"显示Sign In With Apple 登录信息\n"];
    _appleIDInfoTextView.text = [mStr copy];
}


#pragma mark - Actions

//! 处理授权
- (void)handleAuthrization:(UIButton *)sender {
    if (@available(iOS 13.0, *)) {
        // A mechanism for generating requests to authenticate users based on their Apple ID.
        // 基于用户的Apple ID授权用户，生成用户授权请求的一种机制
        ASAuthorizationAppleIDProvider *appleIDProvider = [ASAuthorizationAppleIDProvider new];
        // Creates a new Apple ID authorization request.
        // 创建新的AppleID 授权请求
        ASAuthorizationAppleIDRequest *request = appleIDProvider.createRequest;
        // The contact information to be requested from the user during authentication.
        // 在用户授权期间请求的联系信息
        request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
        // A controller that manages authorization requests created by a provider.
        // 由ASAuthorizationAppleIDProvider创建的授权请求 管理授权请求的控制器
        ASAuthorizationController *controller = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
        // A delegate that the authorization controller informs about the success or failure of an authorization attempt.
        // 设置授权控制器通知授权请求的成功与失败的代理
        controller.delegate = self;
        // A delegate that provides a display context in which the system can present an authorization interface to the user.
        // 设置提供 展示上下文的代理，在这个上下文中 系统可以展示授权界面给用户
        controller.presentationContextProvider = self;
        // starts the authorization flows named during controller initialization.
        // 在控制器初始化期间启动授权流
        [controller performRequests];
    }
}

#pragma mark - Delegate

//! 授权成功地回调
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization  API_AVAILABLE(ios(13.0)){
    
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"%@", controller);
    NSLog(@"%@", authorization);
    
    NSLog(@"authorization.credential：%@", authorization.credential);
    
    NSMutableString *mStr = [NSMutableString string];
    mStr = [_appleIDInfoTextView.text mutableCopy];
    
    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
        // 用户登录使用ASAuthorizationAppleIDCredential
        ASAuthorizationAppleIDCredential *appleIDCredential = authorization.credential;
        NSString *user = appleIDCredential.user;
        //  需要使用钥匙串的方式保存用户的唯一信息 这里暂且处于测试阶段 是否的NSUserDefaults
        [[NSUserDefaults standardUserDefaults] setValue:user forKey:QiShareCurrentIdentifier];
        [mStr appendString:user?:@""];
        NSString *familyName = appleIDCredential.fullName.familyName;
        [mStr appendString:familyName?:@""];
        NSString *givenName = appleIDCredential.fullName.givenName;
        [mStr appendString:givenName?:@""];
        NSString *email = appleIDCredential.email;
        [mStr appendString:email?:@""];
        NSLog(@"mStr：%@", mStr);
        [mStr appendString:@"\n"];
        _appleIDInfoTextView.text = mStr;
        
    } else if ([authorization.credential isKindOfClass:[ASPasswordCredential class]]) {
        // 用户登录使用现有的密码凭证
        ASPasswordCredential *passwordCredential = authorization.credential;
        // 密码凭证对象的用户标识 用户的唯一标识
        NSString *user = passwordCredential.user;
        // 密码凭证对象的密码
        NSString *password = passwordCredential.password;
        [mStr appendString:user?:@""];
        [mStr appendString:password?:@""];
        [mStr appendString:@"\n"];
        NSLog(@"mStr：%@", mStr);
        _appleIDInfoTextView.text = mStr;
    } else {
        NSLog(@"授权信息均不符");
        mStr = [@"授权信息均不符" mutableCopy];
        _appleIDInfoTextView.text = mStr;
    }
}

//! 授权失败的回调
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error  API_AVAILABLE(ios(13.0)){
    
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"错误信息：%@", error);
    NSString *errorMsg = nil;
    switch (error.code) {
        case ASAuthorizationErrorCanceled:
            errorMsg = @"用户取消了授权请求";
            break;
        case ASAuthorizationErrorFailed:
            errorMsg = @"授权请求失败";
            break;
        case ASAuthorizationErrorInvalidResponse:
            errorMsg = @"授权请求响应无效";
            break;
        case ASAuthorizationErrorNotHandled:
            errorMsg = @"未能处理授权请求";
            break;
        case ASAuthorizationErrorUnknown:
            errorMsg = @"授权请求失败未知原因";
            break;
    }
    
    NSMutableString *mStr = [_appleIDInfoTextView.text mutableCopy];
    [mStr appendString:errorMsg];
    [mStr appendString:@"\n"];
    _appleIDInfoTextView.text = [mStr copy];
    
    if (errorMsg) {
        return;
    }
    
    if (error.localizedDescription) {
        NSMutableString *mStr = [_appleIDInfoTextView.text mutableCopy];
        [mStr appendString:error.localizedDescription];
        [mStr appendString:@"\n"];
        _appleIDInfoTextView.text = [mStr copy];
    }
    NSLog(@"controller requests：%@", controller.authorizationRequests);
    /* // 取消授权的时候也会调用这里
     ((ASAuthorizationAppleIDRequest *)(controller.authorizationRequests[0])).requestedScopes
     <__NSArrayI 0x2821e2520>(
     full_name,
     email
     )
     */
}


//! Tells the delegate from which window it should present content to the user.
//! 告诉代理应该在哪个window 展示内容给用户
- (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller  API_AVAILABLE(ios(13.0)){
    
    NSLog(@"调用展示window方法：%s", __FUNCTION__);
    // 返回window
    return self.view.window;
}

//! 移除键盘
- (void)removeFirstResponder:(id)gesture {
    
    [self.view endEditing:YES];
}

- (void)dealloc {
    
    if (@available(iOS 13.0, *)) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ASAuthorizationAppleIDProviderCredentialRevokedNotification object:nil];
    }
}

@end
