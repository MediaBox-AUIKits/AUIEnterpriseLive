import React, { useContext, useMemo, useState, useEffect } from 'react';
import Icon from '@ant-design/icons';
import Player from "../Player";
import { LeftOutlineSvg, AudienceSvg } from '../CustomIcon';
import { RoomContext } from '../../RoomContext';
import { RoomStatusEnum } from '../../types';
import styles from './H5Player.less';

const H5Room: React.FC = () => {
  const { exit, roomState } = useContext(RoomContext);
  const { pv, status } = roomState;
  const [barVisible, setBarVisible] = useState<boolean>(true);

  const pvText = useMemo(() => {
    if (pv > 10000) {
      // 若需要国际化，这里得区分地域，比如 14000 国外格式化为 14K
      return (pv / 10000).toFixed(1) + 'w';
    }
    return pv;
  }, [pv]);

  useEffect(() => {
    if (status === RoomStatusEnum.ended) {
      setBarVisible(true);
    }
  }, [status]);

  const onBarVisibleChange = (bool: boolean) => {
    setBarVisible(bool);
  };

  return (
    <div className={styles.h5player}>
      <Player
        wrapClassName={styles['h5player-container']}
        device="mobile"
        onBarVisibleChange={onBarVisibleChange}
        onError={() => setBarVisible(true)}
      />

      <div style={{ display: barVisible ? 'block' : 'none' }}>
        <span
          className={styles['h5player__exit']}
          onClick={exit}
        >
          <Icon component={LeftOutlineSvg} />
        </span>

        <span className={styles['h5player__audience']}>
          <AudienceSvg />
          <span>{pvText}</span>
        </span>
      </div>
    </div>
  );
};

export default H5Room;
