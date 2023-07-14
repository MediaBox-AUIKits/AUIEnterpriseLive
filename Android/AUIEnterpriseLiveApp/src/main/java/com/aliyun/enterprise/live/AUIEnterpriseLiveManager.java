package com.aliyun.enterprise.live;

import com.aliyun.auiappserver.RetrofitManager;
import com.aliyun.common.AlivcBase;
import com.aliyun.enterprise.live.BuildConfig;

/**
 * @author baorunchen
 * @date 2023/7/12
 * @brief 企业直播启动配置
 * @note 建议在application中进行初始化调用
 */
public class AUIEnterpriseLiveManager {

    private static final String TAG_PROJECT_ENTERPRISE_LIVE = "aui-live-enterprise";

    private static final String BUILD_IM_TYPE_RONGCLOUD = "rongcloud";

    private AUIEnterpriseLiveManager() {
    }

    /**
     * 启动配置
     */
    public static void setup() {
        AlivcBase.setIntegrationWay(TAG_PROJECT_ENTERPRISE_LIVE);
        setupAppServerUrl();
    }

    private static void setupAppServerUrl() {
        if (BUILD_IM_TYPE_RONGCLOUD.equals(BuildConfig.BUILD_IM_TYPE)) {
            RetrofitManager.setAppServerUrl(RetrofitManager.Const.APP_SERVER_URL_RONG_CLOUD);
        } else {
            RetrofitManager.setAppServerUrl(RetrofitManager.Const.APP_SERVER_URL_ALIVC);
        }
    }
}
