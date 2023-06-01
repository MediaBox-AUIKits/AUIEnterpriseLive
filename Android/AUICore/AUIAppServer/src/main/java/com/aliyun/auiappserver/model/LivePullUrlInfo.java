package com.aliyun.auiappserver.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.io.Serializable;

/**
 * @author puke
 * @version 2022/9/2
 */
@JsonIgnoreProperties(ignoreUnknown=true)
public class LivePullUrlInfo implements Serializable {

    @JsonProperty("flv_url")
    public String flvUrl;

    @JsonProperty("flv_oriaac_url")
    public String flvOriaacUrl;

    @JsonProperty("rtmp_url")
    public String rtmpUrl;

    @JsonProperty("rts_url")
    public String rtsUrl;

    @JsonProperty("hls_url")
    public String hlsUrl;
}
