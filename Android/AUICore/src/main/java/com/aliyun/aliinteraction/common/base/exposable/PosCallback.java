package com.aliyun.aliinteraction.common.base.exposable;

/**
 * @author puke
 * @version 2021/4/28
 */
public interface PosCallback<T> {
    void onSuccess(T data);
}
