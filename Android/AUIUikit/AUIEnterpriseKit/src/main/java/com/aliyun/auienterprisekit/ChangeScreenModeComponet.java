package com.aliyun.auienterprisekit;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatImageView;

import com.aliyun.aliinteraction.common.biz.exposable.enums.LiveStatus;
import com.aliyun.aliinteraction.core.base.Actions;
import com.aliyun.aliinteraction.model.Message;
import com.aliyun.aliinteraction.roompaas.message.listener.SimpleOnMessageListener;
import com.aliyun.aliinteraction.roompaas.message.model.StartLiveModel;
import com.aliyun.aliinteraction.roompaas.message.model.StopLiveModel;
import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.ComponentHolder;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.auipusher.LiveContext;

public class ChangeScreenModeComponet extends AppCompatImageView implements ComponentHolder {

    private final Component component = new Component();
    private int countClicked = 1;

    public ChangeScreenModeComponet(@NonNull Context context) {
        this(context, null, 0);
    }

    public ChangeScreenModeComponet(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ChangeScreenModeComponet(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        setImageResource(R.drawable.ilr_full_screen);
        setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                component.handleChangeScreenClick();
                if (countClicked % 2 == 0) {
                    setImageResource(R.drawable.ilr_small_screen);
                } else {
                    setImageResource(R.drawable.ilr_full_screen);
                }
            }
        });
    }

    @Override
    public IComponent getComponent() {
        return component;
    }

    private class Component extends BaseComponent {
        @Override
        public void onInit(final LiveContext liveContext) {
            super.onInit(liveContext);
            LiveStatus status = liveService.getLiveModel().getLiveStatus();
            switch (status) {
                case NOT_START:
                    if (!isOwner()) {
                      setVisibility(View.GONE);
                    }
                    break;
            }
            getMessageService().addMessageListener(new SimpleOnMessageListener() {
                @Override
                public void onStartLive(Message<StartLiveModel> message) {
                    setVisibility(View.VISIBLE);
                }
            });
        }

        private void handleChangeScreenClick() {
            countClicked++;
            if (countClicked % 2 == 0) {
                component.postEvent(Actions.CHANGE_FULL_MODE);
            } else {
                component.postEvent(Actions.CHANGE_SAMLL_MODE);
            }
        }
        @Override
        public void onEvent(String action, Object... args) {
            switch (action) {
                case Actions.IMMERSIVE_PLAYER:
                    if(args[0].equals(true)){
                        setVisibility(View.GONE);
                    }else{
                        setVisibility(View.VISIBLE);
                    }
                    break;
                default:
                    break;
            }
        }

    }

}
