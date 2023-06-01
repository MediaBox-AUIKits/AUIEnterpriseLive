import React, {
  useEffect,
  useState,
  useContext,
  useCallback,
  useRef,
  useMemo,
} from 'react';
import { useTranslation } from 'react-i18next';
import classNames from 'classnames';
import { RoomContext } from '../../RoomContext';
import { CustomMessageTypes } from '../../types';
import styles from './index.less';

export const IntroTabKey = 'intro';
export const ChatTabKey = 'chat';
const MaxCount = 99;

interface IH5Tabs {
  value: string;
  tabs: string[];
  onChange: (tab: string) => void;
}

const H5Tabs: React.FC<IH5Tabs> = (props: IH5Tabs) => {
  const { value, tabs, onChange } = props;
  const { t: tr } = useTranslation();
  const { interaction } = useContext(RoomContext);
  const [newMsgCount, setNewMsgCount] = useState<number>(0);
  const newMsgCountRef = useRef<number>(0);
  const increaseTimer = useRef<NodeJS.Timer>(); // 节流

  const newMsgCountText = useMemo(() => {
    if (newMsgCount > MaxCount) {
      return `${MaxCount}+`;
    }
    return `${newMsgCount}`;
  }, [newMsgCount]);

  const increaseNewMsgCount = useCallback(() => {
    newMsgCountRef.current += 1;

    if (increaseTimer.current) {
      return;
    }
    // 节流
    increaseTimer.current = setTimeout(() => {
      setNewMsgCount(newMsgCountRef.current);
      increaseTimer.current = undefined;
    }, 500);
  }, []);

  useEffect(() => {
    if (!interaction) {
      return;
    }
    const { InteractionEventNames } = window.AliyunInteraction;

    const handler = (eventData: any) => {
      const { type } = eventData || {};
      if (type === CustomMessageTypes.Comment) {
        increaseNewMsgCount();
      }
    };

    if (tabs.includes(ChatTabKey) && value !== ChatTabKey) {
      interaction.on(InteractionEventNames.Message, handler);
    } else {
      interaction.remove(InteractionEventNames.Message, handler);
      newMsgCountRef.current = 0;
      setNewMsgCount(0);
    }

    return () => {
      interaction.remove(InteractionEventNames.Message, handler);
    };
  }, [interaction, tabs, value]);

  return (
    <div className={styles.h5tabs}>
      {
        tabs.map((key: string) => (
          <span
            key={key}
            className={classNames(
              styles['h5tabs-item'],
              { active: value === key && tabs.length > 1 }
            )}
            onClick={() => onChange(key)}
          >
            <span>{tr(key)}</span>
            {
              key === ChatTabKey && newMsgCount ? (
                <span className={styles['h5tabs-item__badge']}>{newMsgCountText}</span>
              ) : null
            }
          </span>
        ))
      }
    </div>
  );
};

export default H5Tabs;
