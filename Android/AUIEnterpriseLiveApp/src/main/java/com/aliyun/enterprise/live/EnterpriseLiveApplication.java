package com.aliyun.enterprise.live;

import android.app.Application;

/**
 * @author baorunchen
 * @date 2023/7/7
 * @brief
 */
public class EnterpriseLiveApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        AUIEnterpriseLiveManager.setup();
    }
}
