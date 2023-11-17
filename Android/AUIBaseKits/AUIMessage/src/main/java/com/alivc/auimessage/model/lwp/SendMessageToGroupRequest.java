package com.alivc.auimessage.model.lwp;

import com.alivc.auimessage.AUIMessageLevel;

import java.io.Serializable;

/**
 * @author puke
 * @version 2023/4/23
 */
public class SendMessageToGroupRequest implements Serializable {

    /**
     * 群组
     */
    public String groupId;

    /**
     * 消息类型
     */
    public int msgType;

    /**
     * 消息级别
     */
    public @AUIMessageLevel int msgLevel;

    /**
     * 消息体内容
     */
    public String data;

    /**
     * 是否跳过消息审核
     */
    public boolean skipAudit;

    /**
     * 跳过禁言检测
     *
     * @apiNote true:忽略被禁言用户，还可发消息；false：当被禁言时，消息无法发送，默认为false，即为不跳过禁言检测。
     */
    public boolean skipMuteCheck;


    @Override
    public String toString() {
        return "SendMessageToGroupRequest{" +
                "groupId='" + groupId + '\'' +
                ", msgType=" + msgType +
                ", msgLevel=" + msgLevel +
                ", data='" + data + '\'' +
                ", skipAudit=" + skipAudit +
                ", skipMuteCheck=" + skipMuteCheck +
                '}';
    }

}
