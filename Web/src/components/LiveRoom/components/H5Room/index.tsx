import React, { useState, useMemo, useContext, useEffect, Fragment } from 'react';
import classNames from 'classnames';
import { RoomContext } from '../../RoomContext';
import { RoomStatusEnum } from '../../types';
import H5Player from './H5Player';
import H5Tabs, { ChatTabKey, IntroTabKey } from './H5Tabs';
import IntroPanel from './IntroPanel';
import ChatPanel from './ChatPanel';
import ChatControls from '../ChatControls';
import { supportSafeArea } from '../../utils/common';
import { usePrevious } from '../../utils/hooks';
import styles from './index.less';

const H5Room: React.FC = () => {
  const { roomState } = useContext(RoomContext);
  const { status } = roomState;
  const previousStatus = usePrevious(status);
  const [tabs, setTabs] = useState<string[]>([IntroTabKey]);
  const [tabKey, setTabKey] = useState<string>(IntroTabKey);

  const hasSafeAreaBottom = useMemo(() => {
    return supportSafeArea('bottom');
  }, []);

  const isInited = useMemo(() => {
    return status !== RoomStatusEnum.no_data;
  }, [status]);

  useEffect(() => {
    if (previousStatus === RoomStatusEnum.no_data && status !== RoomStatusEnum.ended) {
      // 只处理第一次初始化的情况，当前非结束态，加上聊天tab
      setTabs([IntroTabKey, ChatTabKey]);
    }
  }, [previousStatus, status]);

  return (
    <div className={styles.h5wrap}>
      <H5Player />

      <div className={classNames(styles.h5main, { [styles['not-safe-area']]: !hasSafeAreaBottom })}>
        {
          isInited ? (
            <Fragment>
              <H5Tabs
                value={tabKey}
                tabs={tabs}
                onChange={(tab) => setTabKey(tab)}
              />

              <IntroPanel
                className={styles.h5content}
                hidden={tabKey !== IntroTabKey}
              />

              {
                tabs.includes(ChatTabKey) ? (
                  <ChatPanel
                    className={styles.h5content}
                    hidden={tabKey !== ChatTabKey}
                  />
                ) : null
              }
              
              <ChatControls
                className={styles.h5controls}
                theme="light"
                heartIconActive
                allowChat={tabKey === ChatTabKey}
              />
            </Fragment>
          ) : null
        }
      </div>
    </div>
  );
};

export default H5Room;
