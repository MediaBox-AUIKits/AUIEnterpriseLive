package com.aliyun.aliinteraction.common.roombase;

import com.aliyun.aliinteraction.InteractionEngine;
import com.aliyun.aliinteraction.common.base.util.CommonUtil;

/**
 * Created by KyleCe on 2021/10/27
 */
public class Const {

    protected static String userId;

    public static void setUserId(String userId) {
        Const.userId = userId;
    }

    /**
     * 当前登录用户Id
     */
    public static String getUserId() {
        return userId;
    }

    public static String getSdkKey(String key) {
        return "imp_sdk_key_" + key;
    }
}
