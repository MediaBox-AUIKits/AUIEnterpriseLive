package com.aliyun.enterprise.live;

import com.aliyun.auiappserver.RetrofitManager;
import com.aliyun.common.AlivcBase;

/**
 * @author baorunchen
 * @date 2023/7/12
 * @brief 企业直播启动配置
 * @note 建议在application中进行初始化调用
 */
public class AUIEnterpriseLiveManager {

    private static final String TAG_PROJECT_ENTERPRISE_LIVE = "aui-live-enterprise";

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
        RetrofitManager.setAppServerUrl(RetrofitManager.Const.APP_SERVER_URL_DEFAULT);
    }
}
