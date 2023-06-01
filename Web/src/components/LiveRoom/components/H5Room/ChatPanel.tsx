import React, { useContext, useState, useRef, useCallback, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import classNames from 'classnames';
import { throttle } from 'throttle-debounce';
import { RoomContext } from '../../RoomContext';
import { ChevronsDownSvg } from '../CustomIcon';
import { scrollToBottom } from '../../utils/common';
import styles from './ChatPanel.less';

// 距离聊天列表底部最大值
const MaxBottomDistance = 60;

interface IChatPanelProps {
  className: string;
  hidden: boolean;
}

const ChatPanel: React.FC<IChatPanelProps> = (props) => {
  const { className, hidden } = props;
  const { roomState } = useContext(RoomContext);
  const { messageList } = roomState;
  const { t: tr } = useTranslation();
  const autoScroll = useRef<boolean>(true);
  const listRef = useRef<HTMLUListElement|null>(null);
  const [newTipVisible, setNewTipVisible] = useState<boolean>(false);

  useEffect(() => {
    if (!listRef.current) {
      return;
    }
    // 不允许自动滚动底部时不执行滚动，但显示新消息提示
    if (!autoScroll.current) {
      setNewTipVisible(true);
      return;
    }
    // 有新消息滚动到底部
    scrollToBottom(listRef.current);
  }, [messageList]);

  const handleScroll = useCallback(throttle(500, () => {
    if (!listRef.current) {
      return;
    }
    const dom = listRef.current;
    const diff = dom.scrollHeight - (dom.clientHeight + dom.scrollTop);
    // 与聊天列表底部的距离大于最大值，不允许自动滚动
    autoScroll.current = diff < MaxBottomDistance;
    // console.log('onWheelCapture', autoScroll.current, diff);
    // 若小于最大值需要隐藏新消息提示
    if (autoScroll.current) {
      setNewTipVisible(false);
    }
  }), []);

  const handleNewTipClick = () => {
    if (!listRef.current) {
      return;
    }
    setNewTipVisible(false);
    scrollToBottom(listRef.current);
    autoScroll.current = true;
  };

  useEffect(() => {
    // 切换至聊天模块后自动滚动都最新
    if (!hidden) {
      handleNewTipClick();
    }
  }, [hidden]);

  return (
    <div
      className={classNames(className, styles['chat-panel'])}
      style={{
        display: hidden ? 'none' : 'block',
      }}
    >
      <ul
        ref={listRef}
        className={styles['chat-list']}
        onWheelCapture={handleScroll}
        onScroll={handleScroll}
      >
        <li className={classNames(styles['chat-item'], styles['chat-item-notice'])}>
          {tr('liveroom_notice')}
        </li>

        {messageList.map((data, index: number) => (
          <li className={styles['chat-item']} key={data.messageId || index}>
            {
              data.isAnchor ? (
                <span className={styles['chat-item__anchor']}>{tr('anchor')}</span>
              ) : null
            }
            {
              data.isSelf ? (
                <span className={styles['chat-item__self']}>{tr('self')}</span>
              ) : null
            }
            {
              data.nickName ? (
                <span className={styles['chat-item__nick']}>
                  {data.nickName + ':'}
                </span>
              ) : null
            }
            <span>{data.content}</span>
          </li>
        ))}
      </ul>

      <div
        className={styles['chat-new__tip']}
        style={{ display: newTipVisible ? 'inline-block' : 'none' }}
        onClick={handleNewTipClick}
      >
        <ChevronsDownSvg /> {tr('new_message_tip')}
      </div>
    </div>
  );
}

export default ChatPanel;
