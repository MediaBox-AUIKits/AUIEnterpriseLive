package com.aliyun.interaction.app;

import static com.aliyun.aliinteraction.uikit.uibase.util.AppUtil.isNetworkInvalid;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.aliyun.aliinteraction.base.Error;
import com.aliyun.aliinteraction.common.base.callback.UICallback;
import com.aliyun.aliinteraction.common.base.error.Errors;
import com.aliyun.aliinteraction.common.base.exposable.Callback;
import com.aliyun.aliinteraction.common.base.log.Logger;
import com.aliyun.aliinteraction.common.roombase.Const;
import com.aliyun.aliinteraction.uikit.core.LiveConst;
import com.aliyun.aliinteraction.uikit.uibase.helper.IMLoginHelper;
import com.aliyun.auiappserver.AppServerApi;
import com.aliyun.auiappserver.model.CreateLiveRequest;
import com.aliyun.auiappserver.model.GetLiveRequest;
import com.aliyun.auiappserver.model.LiveModel;
import com.aliyun.auiappserver.model.UpdateLiveRequest;
import com.aliyun.auipusher.LiveParam;
import com.aliyun.auipusher.LiveRole;
import com.aliyun.auipusher.config.AliLiveMediaStreamOptions;
import com.aliyun.enterprise.EnterpriseLiveActivity;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.Serializable;


public class LivePrototype implements Serializable {

    private static final String TAG = LivePrototype.class.getSimpleName();
    private static final byte[] sInstanceLock = new byte[0];

    private static LivePrototype sInstance;

    public static LivePrototype getInstance() {
        if (sInstance == null) {
            synchronized (sInstanceLock) {
                if (sInstance == null) {
                    sInstance = new LivePrototype();
                }
            }
        }
        return sInstance;
    }

    private LivePrototype() {
    }

    public void setup(final Context context, final OpenLiveParam param, Callback<String> callback) {
        Logger.i(TAG, "setup to open live page");
        final UICallback<String> uiCallback = new UICallback<>(callback);
        if (isNetworkInvalid(context)) {
            uiCallback.onError("当前网络不可用，请检查后再试");
            return;
        }
        if (param == null) {
            uiCallback.onError("param不能为空");
            return;
        }
        if (param.role == null) {
            uiCallback.onError("role不能传空");
            return;
        }
        if (TextUtils.isEmpty(param.nick)) {
            uiCallback.onError("nick参数不能为空");
            return;
        }

        String userId = Const.getUserId();
        IMLoginHelper.login(userId, new com.aliyun.aliinteraction.base.Callback<Void>() {
            @Override
            public void onSuccess(Void unused) {
                LiveRole role = param.role;
                String liveId = param.liveId;
                boolean hasLive = !TextUtils.isEmpty(liveId);
                if (role == LiveRole.ANCHOR) {
                    // 主播身份
                    if (hasLive) {
                        // 有直播, 直接进入直播间
                        openLiveRoom(context, null, param, uiCallback);
                    } else {
                        // 无直播, 先创建再进入
                        createAndOpenLiveRoom(context, param, uiCallback);
                    }
                } else {
                    // 观众身份
                    if (hasLive) {
                        // 有直播, 直接进入直播间
                        openLiveRoom(context, null, param, uiCallback);
                    } else {
                        // 无直播, 报错
                        uiCallback.onError(Errors.PARAM_ERROR.getMessage());
                    }
                }
            }

            @Override
            public void onError(Error error) {
                uiCallback.onError(error.msg);
            }
        });
    }

    private void createAndOpenLiveRoom(final Context context, final OpenLiveParam param, @NonNull final UICallback<String> uiCallback) {
        String currentUserId = Const.getUserId();
        CreateLiveRequest request = new CreateLiveRequest();
        request.anchor = currentUserId;
        request.title = param.title;
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("userNick", Const.getUserId());
            jsonObject.put("userAvatar", "https://img.alicdn.com/imgextra/i1/O1CN01chynzk1uKkiHiQIvE_!!6000000006019-2-tps-80-80.png");
        } catch (JSONException e) {
            e.printStackTrace();
        }
        request.extend = jsonObject.toString();
        request.anchor_nick = param.nick;
        request.notice = param.notice;
        request.mode = param.model;
        AppServerApi.instance().createLive(request).invoke(new com.aliyun.aliinteraction.base.Callback<LiveModel>() {
            @Override
            public void onSuccess(LiveModel liveModel) {
                UpdateLiveRequest updateLiveRequest = new UpdateLiveRequest();
                updateLiveRequest.id = liveModel.id;
                updateLiveRequest.anchor = liveModel.anchorId;
                updateLiveRequest.title = liveModel.title;
                updateLiveRequest.notice = liveModel.notice;
                AppServerApi.instance().updateLive(updateLiveRequest).invoke(null);

                openLiveRoom(context, liveModel, param, uiCallback);
            }

            @Override
            public void onError(Error error) {
                uiCallback.onError(error.msg);
            }
        });
    }

    private void openLiveRoom(final Context context, LiveModel createdLiveModel, final OpenLiveParam param,
                              @NonNull final UICallback<String> uiCallback) {

        if (createdLiveModel != null) {
            // 主播新建
            LiveParam liveParam = new LiveParam();
            liveParam.liveId = createdLiveModel.id;
            liveParam.liveModel = createdLiveModel;
            liveParam.role = LiveRole.ANCHOR;
            liveParam.userNick = param.nick;
            liveParam.userExtension = param.userExtension;
            liveParam.notice = param.notice;
            openBusinessRoomPage(context, liveParam,true);
            uiCallback.onSuccess(liveParam.liveId);
            return;
        }

        GetLiveRequest request = new GetLiveRequest();
        request.id = param.liveId;
        request.userId = Const.getUserId();
        AppServerApi.instance().getLive(request).invoke(new com.aliyun.aliinteraction.base.Callback<LiveModel>() {
            @Override
            public void onSuccess(LiveModel liveModel) {
                LiveParam liveParam = new LiveParam();
                liveParam.liveId = param.liveId;
                liveParam.liveModel = liveModel;
                liveParam.role = param.role;
                liveParam.userNick = param.nick;
                liveParam.notice = liveModel.notice;
                liveParam.userExtension = param.userExtension;
                openBusinessRoomPage(context, liveParam,false);
                uiCallback.onSuccess(liveParam.liveId);
            }

            @Override
            public void onError(Error error) {
                uiCallback.onError(error.msg);
            }
        });

    }

    /**
     * 打开直播间参数，role为必传参数
     */
    public static class OpenLiveParam {
        public String liveId;
        public LiveRole role;

        public String nick;
        public String userExtension;
        // 公告
        public String notice;
        // 标题
        public String title;

        // 可选参数
        public AliLiveMediaStreamOptions mediaPusherOptions = null;
        // 0:普通直播间; 1:连麦直播间;
        public int model = 0;
    }

    /**
     * 跳转企业直播间
     *
     * @param context
     * @param liveParam
     */
    public void openBusinessRoomPage(Context context, LiveParam liveParam,boolean isCreateLive) {
            Intent intent = new Intent(context, EnterpriseLiveActivity.class);
            intent.putExtra(LiveConst.PARAM_KEY_LIVE_PARAM, liveParam);
            context.startActivity(intent);
    }
}
