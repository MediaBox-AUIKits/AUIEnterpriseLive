import React, { useContext, useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import { RoomContext } from '../../RoomContext';
import { formatDate } from '../../utils/common';
import styles from './IntroPanel.less';

interface IIntroPanelProps {
  className: string;
  hidden: boolean;
}

const IntroPanel: React.FC<IIntroPanelProps> = (props) => {
  const { className, hidden } = props;
  const { roomState } = useContext(RoomContext);
  const { title, notice, createdAt } = roomState;
  const { t: tr } = useTranslation();

  const dateStr = useMemo(() => {
    if (createdAt) {
      return formatDate(new Date(createdAt));
    }
    return '';
  }, [createdAt]);

  return (
    <div
      className={className}
      style={{
        display: hidden ? 'none' : 'block',
      }}
    >
      <h5 className={styles['intro-panel__title']}>
        {title}
      </h5>
      {
        dateStr ? (
          <p className={styles['intro-panel__date']}>
            {dateStr}
          </p>
        ) : null
      }
      <p className={styles['intro-panel__notice']}>
        {notice || tr('live_room_notice_empty')}
      </p>
    </div>
  );
}

export default IntroPanel;
