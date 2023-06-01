package com.aliyun.auiappserver;

import com.aliyun.aliinteraction.base.Callback;

public interface ApiInvoker<T> {

    void invoke(Callback<T> callback);
}
