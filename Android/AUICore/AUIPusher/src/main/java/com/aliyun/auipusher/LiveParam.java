package com.aliyun.auipusher;

import com.aliyun.auiappserver.model.LiveModel;

import java.io.Serializable;

/**
 * @author puke
 * @version 2021/12/15
 */

/**
 * 跳转直播间参数
 */
public class LiveParam implements Serializable {

    public String liveId;//直播id
    public LiveModel liveModel;//liveModel
    public LiveRole role;//角色
    public String userNick;//昵称
    public String userExtension;//扩展字段
    public String notice;//公告
}
