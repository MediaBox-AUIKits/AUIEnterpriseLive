package com.aliyun.aliinteraction.uikit.component;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.aliyun.aliinteraction.common.biz.exposable.enums.LiveStatus;
import com.aliyun.aliinteraction.model.Message;
import com.aliyun.aliinteraction.roompaas.message.listener.SimpleOnMessageListener;
import com.aliyun.aliinteraction.roompaas.message.model.StartLiveModel;
import com.aliyun.aliinteraction.roompaas.message.model.StopLiveModel;
import com.aliyun.aliinteraction.uikit.R;
import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.ComponentHolder;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.aliinteraction.uikit.uibase.util.AnimUtil;
import com.aliyun.aliinteraction.uikit.uibase.util.ViewUtil;
import com.aliyun.auipusher.LiveContext;

/**
 * 直播未开始的视图
 *
 * @author puke
 * @version 2021/7/29
 */
public class LiveNotStartComponent extends RelativeLayout implements ComponentHolder {

    private final Component component = new Component();
    private final TextView tips;
    private LiveStatus status;
    public LiveNotStartComponent(Context context) {
        this(context, null, 0);
    }

    public LiveNotStartComponent(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public LiveNotStartComponent(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        View.inflate(context, R.layout.ilr_view_live_not_start, this);
        tips = findViewById(R.id.liveNotStartCurtain);
        this.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if(!status.equals(LiveStatus.NOT_START)&&!status.equals(LiveStatus.END)) {
                    hide();
                }
            }
        });
    }

    private void show() {
        if (ViewUtil.isNotVisible(this)) {
            ViewUtil.setVisible(this);
            ViewUtil.clickableView(this);
            AnimUtil.animIn(this);
        }
    }

    private void hide() {
        if (ViewUtil.isVisible(this)) {
            AnimUtil.animOut(this, new Runnable() {
                @Override
                public void run() {
                    ViewUtil.setGone(LiveNotStartComponent.this);
                }
            });
            ViewUtil.notClickableView(this);
        }
    }

    @Override
    public IComponent getComponent() {
        return component;
    }

    private class Component extends BaseComponent {
        @Override
        public void onInit(LiveContext liveContext) {
            super.onInit(liveContext);
            hide();
            getMessageService().addMessageListener(new SimpleOnMessageListener() {
                @Override
                public void onStartLive(Message<StartLiveModel> message) {
                    hide();
                }

                @Override
                public void onStopLive(Message<StopLiveModel> message) {
                    tips.setText("直播已结束～");
                    show();
                }
            });

            status = liveService.getLiveModel().getLiveStatus();
            switch (status) {
                case NOT_START:
                    if (!isOwner()) {
                        show();
                    }
                    break;
                case END:
                    if (!needPlayback()) {
                        tips.setText("直播已结束～");
                        show();
                    }
                    break;
            }
        }
    }
}
