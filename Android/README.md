# AUIEnterpriseLive组件

## 介绍
AUI Kits 企业直播场景集成工具是阿里云针对企业提供的跨平台直播服务，为业务方提供培训、会议、活动等场景的能力，借助视频直播稳定、流畅、灵活的产品能力，以低代码的方式助力业务方快速发布直播应用。

## 源码说明
### 下载地址
下载地址[请参见](https://github.com/MediaBox-AUIKits/AUIEnterpriseLive/tree/main/Android)

### 目录结构
```
├── android  // android平台的根目录
│   ├── app                                        // Demo代码
│   ├── AUICore                                    // AUI核心依赖库
│   ├── AUIUikit                                   // AUI组件Module
│   ├── AUIEnterpriseLive                          // AUI企业直播间

```

### 环境要求
- Android 5.0（SDK API Level 21）及以上版本。
- 建议使用Android Studio 4.0以及以上版本。
- Android 5.0或以上版本的真机，暂不支持模拟器调试。

### 前提条件
- 您已经搭建AppServer并获取了访问域名。搭建步骤,[请参见](https://help.aliyun.com/document_detail/462753.htm?spm=a2c4g.609765.0.0.5ebf4caeKGOMxe#task-2266772)
- 您已获取音视频终端SDK的直播推流和播放器的License授权和License Key。获取方法，[请参见](https://help.aliyun.com/document_detail/438207.htm?spm=a2c4g.609765.0.0.5ebf1a58AJSQmH#task-2227754)

## 跑通Demo（可选）
本节介绍如何编译运行Demo。
- 1.下载并解压Demo文件，目录说明如下。下载地址[请参见](https://github.com/aliyunvideo/AUIInteractionLive_android?spm=a2c4g.609765.0.0.5ebf5a80HLYDck)
- 2.配置工程文件:使用Android Studio，选择File > Open，选择上一步下载的Demo工程文件。
- 3.链接Android真机,连接成功,单击绿色运行按钮，构建工程文件。
- 4.安装到Android真机上，运行企业直播应用。

## 快速集成
本节介绍如何在您的App工程中集成AliEnterpriseLiveDemo-Android，快速实现企业直播功能。

### 导入源码
下载并导入AUI Kits相关组件
- 1.克隆AUI互动直播工程代码AliEnterpriseLiveDemo-Android。
- 2.拷贝工程下的AUICore、AUIEnterpriseLive、AUIUikit文件夹到您的工程中。
- 3.在setting.gradle中完成导入相关module。
- 4.在App的build.gradle文件中添加对应的module依赖。
```ruby
implementation project(':AUIEnterpriseLive')
implementation project(':AUIUikit:AUIBaseKit')
```

### 工程配置
配置权限、混淆及License文件
- 1.在AndroidManifest.xml中配置App的权限，SDK需要以下权限（6.0以上的 Android 系统需要动态申请相机、麦克风权限等）：
```ruby
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />


```
2.在proguard-rules.pro文件中，将SDK相关类加入不混淆名单
```ruby
-keep class com.alivc.** { *; }
-keep class com.aliyun.** { *; }
-keep class com.aliyun.rts.network.* { *; }
-keep class org.webrtc.** { *; }
-keep class com.alibaba.dingpaas.** { *; }
-keep class com.dingtalk.mars.** { *; }
-keep class com.dingtalk.bifrost.** { *; }
-keep class com.dingtalk.mobile.** { *; }
-keep class org.android.spdy.** { *; }
-keep class com.alibaba.dingpaas.interaction.** { *; }
-keep class com.cicada.**{*;}

```
3.配置License文件
申请试用License、开通直播推流、播放、美颜、IM等能力，获取License文件和License Key。详细操作，请参见Demo体验
把License文件放到assets目录下，并修改文件名为license.crt
注册License Key到AndroidManifest.xml文件中
```ruby
<meta-data
            android:name="com.aliyun.alivc_license.licensekey"
            tools:node="replace"
            android:value="xxx" />
<meta-data
            android:name="com.aliyun.alivc_license.licensefile"
            tools:node="replace"
            android:value="assets/cert/license.crt" />
```
4.在build.gradle文件中增加Maven配置
```ruby
maven { url 'https://maven.aliyun.com/nexus/content/repositories/releases'}

```
5.配置企业直播互动依赖
```ruby
api 'com.aliyun.sdk.android:aliinteraction-cxx:1.0.0'
api 'com.aliyun.sdk.android:aliinteraction-android:1.0.0'
api 'com.aliyun.aio:AliVCSDK_Premium:1.8.0'

```
6.在AUIInteractionLiveRoom工程下找到RetrofitManager文件，修改自己的server访问地址
```ruby
com.aliyun.aliinteraction.liveroom.network.RetrofitManager#SERVER_URL

```
7.配置local.properties文件，设置自己的SDK访问路径。
```ruby
sdk.dir=/Users/xx/Library/Android/sdk
ndk.dir=/Users/xx/Library/Android/ndk

```
### appserver API调用
```ruby
//登录
ApiInvoker<AppServerToken> login(@Body LoginRequest request);
//获取token校验合法性
ApiInvoker<Token> getToken(@Body TokenRequest request);
//创建直播间
ApiInvoker<LiveModel> createLive(@Body CreateLiveRequest request);
//更新直播间信息，比如更新公告等
ApiInvoker<LiveModel> updateLive(@Body UpdateLiveRequest request);
//获取直播间信息，方便进入直播间信息展示
ApiInvoker<LiveModel> getLive(@Body GetLiveRequest request);
//推流成功后, 调用此服务通知服务端更新状态（开播状态）
ApiInvoker<Void> startLive(@Body StartLiveRequest request);
//停止推流后, 调用此服务通知服务端更新状态（停播状态）
ApiInvoker<Void> stopLive(@Body StopLiveRequest request);
//获取直播间列表
ApiInvoker<List<LiveModel>> getLiveList(@Body ListLiveRequest request);
//主播将最新的麦上成员列表更新到AppServer端，直播间连麦管理模块用
ApiInvoker<MeetingInfo> updateMeetingInfo(@Body UpdateMeetingInfoRequest request);
//获取连麦观众信息，直播间连麦管理模块用
ApiInvoker<MeetingInfo> getMeetingInfo(@Body GetMeetingInfoRequest request);

```
## 常见问题
更多AUIKits问题咨询及使用说明，请搜索钉钉群（35685013712）加入AUI客户支持群联系我们,[android接入问题请参见](https://help.aliyun.com/document_detail/609775.html?spm=a2c4g.609774.0.0.13822b23zxoR7x)
