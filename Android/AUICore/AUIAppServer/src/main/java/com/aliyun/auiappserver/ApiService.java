package com.aliyun.auiappserver;

import com.aliyun.auiappserver.model.AppServerToken;
import com.aliyun.auiappserver.model.CreateLiveRequest;
import com.aliyun.auiappserver.model.GetLiveRequest;
import com.aliyun.auiappserver.model.GetMeetingInfoRequest;
import com.aliyun.auiappserver.model.ListLiveRequest;
import com.aliyun.auiappserver.model.LiveModel;
import com.aliyun.auiappserver.model.LoginRequest;
import com.aliyun.auiappserver.model.MeetingInfo;
import com.aliyun.auiappserver.model.StartLiveRequest;
import com.aliyun.auiappserver.model.StopLiveRequest;
import com.aliyun.auiappserver.model.Token;
import com.aliyun.auiappserver.model.TokenRequest;
import com.aliyun.auiappserver.model.UpdateLiveRequest;
import com.aliyun.auiappserver.model.UpdateMeetingInfoRequest;

import java.util.List;

import retrofit2.http.Body;
import retrofit2.http.POST;

public interface ApiService {

    @POST("live/login")
    //登录
    ApiInvoker<AppServerToken> login(@Body LoginRequest request);
    //获取token校验合法性
    @POST("live/token")
    ApiInvoker<Token> getToken(@Body TokenRequest request);
    //创建直播间
    @POST("live/create")
    ApiInvoker<LiveModel> createLive(@Body CreateLiveRequest request);
     //更新直播间信息，比如更新公告等
    @POST("live/update")
    ApiInvoker<LiveModel> updateLive(@Body UpdateLiveRequest request);
    //获取直播间信息，方便进入直播间信息展示
    @POST("live/get")
    ApiInvoker<LiveModel> getLive(@Body GetLiveRequest request);
    //推流成功后, 调用此服务通知服务端更新状态（开播状态）
    @POST("live/start")
    ApiInvoker<Void> startLive(@Body StartLiveRequest request);
    //停止推流后, 调用此服务通知服务端更新状态（ti停播状态）
    @POST("live/stop")
    ApiInvoker<Void> stopLive(@Body StopLiveRequest request);
    //获取直播间列表
    @POST("live/list")
    ApiInvoker<List<LiveModel>> getLiveList(@Body ListLiveRequest request);
    //主播将最新的麦上成员列表更新到AppServer端，直播间连麦管理模块用
    @POST("live/updateMeetingInfo")
    ApiInvoker<MeetingInfo> updateMeetingInfo(@Body UpdateMeetingInfoRequest request);
    //获取连麦观众信息，直播间连麦管理模块用
    @POST("live/getMeetingInfo")
    ApiInvoker<MeetingInfo> getMeetingInfo(@Body GetMeetingInfoRequest request);
}
