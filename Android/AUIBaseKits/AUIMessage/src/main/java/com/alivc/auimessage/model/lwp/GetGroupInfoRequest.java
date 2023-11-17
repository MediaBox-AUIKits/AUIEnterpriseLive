package com.alivc.auimessage.model.lwp;

import java.io.Serializable;

/**
 * @author puke
 * @version 2023/4/23
 */
public class GetGroupInfoRequest implements Serializable {

    /**
     * 群组id
     */
    public String groupId;

    @Override
    public String toString() {
        return "GetGroupInfoRequest{" +
                "groupId='" + groupId + '\'' +
                '}';
    }

}
