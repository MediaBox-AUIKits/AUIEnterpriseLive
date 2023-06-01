import React, { useRef, useState, useEffect, Fragment, useCallback, useMemo } from 'react';
import { Button, Space, NoticeBar, Divider, Toast } from 'antd-mobile'
import services from '@/services';
import { CustomMessageTypes, BroadcastTypeEnum } from '@/types/interaction';
import styles from './index.less';

enum TestStatus {
  init = 0,
  logging = 1,
  logged = 2,
  joining = 3,
  joined = 4,
  leaving = 5,
};

const StatusText = {
  0: '未登录',
  1: '登录中...',
  2: '已登录',
  3: '加入房间中...',
  4: '已加入房间',
  5: '离开房间中...',
};

const IMGroupIdStorageKey = 'IMGroupId';
enum LevelEnum {
  low = 0,
  middle,
  high,
}

export default function IMTestPage() {
  const InteractionRef = useRef<any>();
  const userInfoRef = useRef({
    id: '',
    name: '',
  });
  const joinedGroupId = useRef<string>('');
  const [status, setStatus] = useState<TestStatus>(TestStatus.init);
  const [nickname, setNickname] = useState<string>('');
  const [groupId, setGroupId] = useState<string>('');
  const [comment, setComment] = useState<string>('');
  const [sending, setSending] = useState<boolean>(false);
  const [userIds, setUserIds] = useState<string>('');
  const commentListCache = useRef<any[]>([]);
  const [commentList, setCommentList] = useState<any[]>([]);
  const [creatorId, setCreatorId] = useState<string>('');
  const [muteUserId, setMuteUserId] = useState<string>('');
  const [pageStr, setPageStr] = useState<string>('1');
  const [testMethod, setTestMethod] = useState<string>('');
  const [testOption, setTestOption] = useState<string>('');
  const testPlaceholder = '输入测试数据json字符串，如 {"groupId":"ae57f8b4-2a7b-413c-95c3-3f40c933a147"}';

  const isCreator = useMemo(() => {
    return creatorId && creatorId === userInfoRef.current.id;
  }, [creatorId]);

  const userTypeText = useMemo(() => {
    if (!creatorId) {
      return '';
    }
    if (creatorId === userInfoRef.current.id) {
      return '您是该 IM 组的创建者';
    } else {
      return '您不是该 IM 组的创建者';
    }
  }, [creatorId]);

  useEffect(() => {
    const gid = localStorage.getItem(IMGroupIdStorageKey);
    if (gid) {
      setGroupId(gid);
    }

    const { InteractionEngine } = window.AliyunInteraction;
    InteractionRef.current = InteractionEngine.create();
    (window as any).testim = InteractionRef.current;
    listenMessage();
  }, []);

  const listenMessage = useCallback(() => {
    const { InteractionEventNames } = window.AliyunInteraction;
    InteractionRef.current.on(InteractionEventNames.Message, (eventData: any) => {
      console.log('收到信息啦', eventData);
      const { type } = eventData || {};
      if (type === CustomMessageTypes.Comment) {
        upateCommentList(eventData);
      }
    });
  }, []);

  const upateCommentList = useCallback((eventData: any) => {
    // console.log('current', JSON.stringify(commentListCache.current));
    const { data, messageId, senderId, senderInfo = {} } = eventData || {};
    if (data && data.content && (senderInfo.userNick || senderId)) {
      const list = [{
        messageId,
        content: data.content,
        senderNick: senderInfo.userNick || senderId,
        senderId,
        datetime: Date.now(),
      }, ...commentListCache.current];
      // console.log('new list', list);
      commentListCache.current = list;
      setCommentList(list);
    }
  }, [commentList]);

  const login = async () => {
    const userName = nickname.trim();
    if (!/^[a-zA-Z0-9]+$/.test(userName)) {
      Toast.show({
        icon: 'fail',
        content: '仅支持英文字母、数字',
      });
      return;
    }

    userInfoRef.current = {
      id: userName,
      name: userName,
    };

    console.log('用户信息', userInfoRef.current);

    try {
      setStatus(TestStatus.logging);
      
      await services.login(userInfoRef.current.id, userInfoRef.current.name);
      const token: any = await services.getToken(userInfoRef.current.id);
      // im 服务认证
      await InteractionRef.current.auth(token.access_token);

      setStatus(TestStatus.logged);
    } catch (error) {
      console.log(error);
      setStatus(TestStatus.init);
    }
  };

  const logout = () => {
    InteractionRef.current.logout().then(() => {
      setStatus(TestStatus.init);
    });
  };

  const createGroup = () => {
    InteractionRef.current
      .createGroup()
      .then((res: any) => {
        console.log('创建IM组成功', res);
      })
      .catch((err: any) => {
        console.log('创建IM组失败', err);
      });
  };

  const closeGroup = () => {
    const gid = groupId.trim();
    if (!gid) {
      return;
    }

    InteractionRef.current
      .closeGroup({ groupId: gid })
      .then((res: any) => {
        console.log('关闭IM组成功', res);
      })
      .catch((err: any) => {
        console.log('关闭IM组失败', err);
      });
  };

  const getGroup = () => {
    const gid = groupId.trim();
    if (!gid) {
      return;
    }

    InteractionRef.current
      .getGroup({ groupId: gid })
      .then((res: any) => {
        console.log('获取IM组信息成功', res);
      })
      .catch((err: any) => {
        console.log('获取IM组信息失败', err);
      });
  };

  // 测试进入group
  const joinGroup = () => {
    const gid = groupId.trim();
    if (!gid) {
      return;
    }

    const options = {
      groupId: gid,
      userId: userInfoRef.current.id,
      userNick: userInfoRef.current.name,
      userAvatar: '',
      userExtension: '{}',
      broadCastType: 2,
      broadCastStatistics: true,
    };

    setStatus(TestStatus.joining);

    InteractionRef.current
      .joinGroup(options)
      .then(() => {
        joinedGroupId.current = gid;
        localStorage.setItem(IMGroupIdStorageKey, gid);
        setStatus(TestStatus.joined);
        // 获取加入的互动消息信息
        InteractionRef.current
          .getGroup({ groupId: gid })
          .then((res: any) => {
            setCreatorId(res.creatorId);
          })
          .catch((err: any) => {
            console.log('获取IM组信息失败', err);
          });
      })
      .catch((err: any) => {
        console.log('加入房间失败', err);
        setStatus(TestStatus.logged);
      });
  };

  const leaveGroup = () => {
    setStatus(TestStatus.leaving);

    InteractionRef.current
      .leaveGroup({ groupId: joinedGroupId.current })
      .then((res: any) => {
        console.log('离开房间成功', res);
        setStatus(TestStatus.logged);
        setCreatorId('');
      })
      .catch((err: any) => {
        console.log('离开房间失败', err);
        setStatus(TestStatus.joined);
      });
  };

  const fetchLatestComments = () => {
    const pageNum = Number(pageStr) || 1;
    InteractionRef.current
      .listMessage({
        groupId: joinedGroupId.current,
        sortType: 1,
        type: CustomMessageTypes.Comment,
        pageNum,
        pageSize: 20,
      })
      .then((res: any) => {
        console.log('listMessage 最新评论', res);
      })
      .catch((err: any) => {
        console.log('listMessage 获取最新评论失败', err);
      });
  };

  const sendComment = () => {
    const content = comment.trim();
    if (!content || sending) {
      return;
    }

    const options = {
      groupId: joinedGroupId.current,
      type: CustomMessageTypes.Comment,
      data: JSON.stringify({ content }),
    }

    setSending(true);
    InteractionRef.current
      .sendMessageToGroup(options)
      .then(() => {
        console.log('发送成功');
        setComment('');
      })
      .catch((err: any) => {
        console.log('发送失败', err);
      }).finally(() => {
        setSending(false);
      });
  };

  const sendCommentToUser = (level: number = LevelEnum.low) => {
    const content = comment.trim();
    if (!content || sending) {
      return;
    }

    const options = {
      level,
      groupId: joinedGroupId.current,
      type: CustomMessageTypes.Comment,
      data: JSON.stringify({ content }),
      receiverIdList: [creatorId],
    }
    const ids = userIds.trim().split(',').filter((str: string) => !!str);
    if (level > LevelEnum.low) {
      if (!ids.length) {
        return;
      }
      options.receiverIdList = [...(new Set(ids))];
    }

    setSending(true);
    InteractionRef.current
      .sendMessageToGroupUsers(options)
      .then(() => {
        console.log('发送成功');
        setComment('');
      })
      .catch((err: any) => {
        console.log('发送失败', err);
      }).finally(() => {
        setSending(false);
      });
  };

  const sendLike = () => {
    InteractionRef.current
      .sendLike({
        groupId: joinedGroupId.current,
        count: 1,
        broadCastType: 2,
      })
      .then((res: any) => {
        console.log('点赞成功', res);
      })
      .catch((err: any) => {
        console.log('点赞失败', err);
      });
  };

  const listGroupUser = () => {
    const pageNum = Number(pageStr) || 1;
    InteractionRef.current
      .listGroupUser({
        groupId: joinedGroupId.current,
        sortType: 1,
        pageNum,
        pageSize: 20,
      })
      .then((res: any) => {
        console.log('listGroupUser 成功', res);
      })
      .catch((err: any) => {
        console.log('listGroupUser 失败', err);
      });
  };

  const getGroupStatistics = () => {
    InteractionRef.current
      .getGroupStatistics({
        groupId: joinedGroupId.current,
      })
      .then((res: any) => {
        console.log('getGroupStatistics 成功', res);
      })
      .catch((err: any) => {
        console.log('getGroupStatistics 失败', err);
      });
  };

  const getGroupUserByIdList = () => {
    InteractionRef.current
      .getGroupUserByIdList({
        groupId: joinedGroupId.current,
        userIdList: [userInfoRef.current.id],
      })
      .then((res: any) => {
        console.log('getGroupUserByIdList 成功', res);
      })
      .catch((err: any) => {
        console.log('getGroupUserByIdList 失败', err);
      });
  };

  const muteAll = () => {
    InteractionRef.current
      .muteAll({
        groupId: joinedGroupId.current,
        broadCastType: BroadcastTypeEnum.all,
      })
      .then((res: any) => {
        console.log('muteAll 成功', res);
      })
      .catch((err: any) => {
        console.log('muteAll 失败', err);
      });
  };

  const cancelMuteAll = () => {
    InteractionRef.current
      .cancelMuteAll({
        groupId: joinedGroupId.current,
        broadCastType: BroadcastTypeEnum.all,
      })
      .then((res: any) => {
        console.log('cancelMuteAll 成功', res);
      })
      .catch((err: any) => {
        console.log('cancelMuteAll 失败', err);
      });
  };

  const listMuteUsers = () => {
    InteractionRef.current
      .listMuteUsers({
        groupId: joinedGroupId.current,
      })
      .then((res: any) => {
        console.log('listMuteUsers 成功', res);
      })
      .catch((err: any) => {
        console.log('listMuteUsers 失败', err);
      });
  };

  const muteUser = () => {
    const uid = muteUserId.trim();
    if (!uid) {
      return;
    }

    InteractionRef.current
      .muteUser({
        groupId: joinedGroupId.current,
        muteUserList: [uid],
        broadCastType: BroadcastTypeEnum.all,
      })
      .then((res: any) => {
        console.log('muteUser 成功', res);
      })
      .catch((err: any) => {
        console.log('muteUser 失败', err);
      });
  };

  const cancelMuteUser = () => {
    const uid = muteUserId.trim();
    if (!uid) {
      return;
    }

    InteractionRef.current
      .cancelMuteUser({
        groupId: joinedGroupId.current,
        cancelMuteUserList: [uid],
        broadCastType: BroadcastTypeEnum.all,
      })
      .then((res: any) => {
        console.log('cancelMuteUser 成功', res);
      })
      .catch((err: any) => {
        console.log('cancelMuteUser 失败', err);
      });
  };

  const senMsg = () => {
    const path = testMethod.trim();
    const optionStr = testOption.trim();
    if (!path || !optionStr) {
      return;
    }

    // console.log('optionStr-->', optionStr);
    try {
      let options: any = JSON.parse(optionStr);
      // console.log('options11-->', options);
      if (typeof options === 'string') {
        // console.log('options22-->', options);
        options = JSON.parse(options);
      }
      
      InteractionRef.current
        .authService
        .sendMsg(path, undefined, [options])
        .then((res: any) => {
          console.log('自定义数据发送成功', res);
        })
        .catch((err: any) => {
          console.log('自定义数据发送失败', err);
        });
    } catch (error) {
      console.log('解析自定义数据失败，请检查格式！', error);
    }
  };

  return (
    <section style={{ padding: 16 }}>
      <NoticeBar content={StatusText[status]} color="info" className={styles.mb16} />
      {
        status === TestStatus.init ? (
          <Fragment>
            <input
              value={nickname}
              placeholder="输入昵称（仅支持英文字母、数字）"
              className={styles.input}
              id="userid-input"
              autoComplete="off"
              onChange={(e) => setNickname(e.target.value)}
            />
            <Button className="login-btn" size="small" color="primary" onClick={login}>登录</Button>
          </Fragment>
        ) : null
      }
      {
        status === TestStatus.logged ? (
          <Space direction="vertical">
            <Space wrap>
              <Button className="logout-btn" size="small" color="primary" onClick={logout}>退出登录</Button>
              <Button className="create-im-btn" size="small" color="primary" onClick={createGroup}>创建IM组</Button>
            </Space>
            <input
              value={groupId}
              className={styles.input}
              placeholder="输入测试的groupId"
              id="groupId-input"
              autoComplete="off"
              onChange={(e) => setGroupId(e.target.value)}
            />
            <Space wrap>
              <Button className="get-im-btn" size="small" color="primary" onClick={getGroup}>获取IM组信息</Button>
              <Button className="close-im-btn" size="small" color="primary" onClick={closeGroup}>关闭IM组</Button>
              <Button className="join-im-btn" size="small" color="primary" onClick={joinGroup}>加入IM组</Button>
            </Space>
          </Space>
        ) : null
      }
      {
        status === TestStatus.joined ? (
          <Space direction="vertical">
            <p>{userTypeText}</p>
            <Space wrap>
              <Button className="leave-im-btn" size="small" color="primary" onClick={leaveGroup}>离开IM组</Button>
              <Button className="listGroupUser-btn" size="small" color="primary" onClick={listGroupUser}>获取该IM组用户数据</Button>
              <Button className="getGroupStatistics-btn" size="small" color="primary" onClick={getGroupStatistics}>获取该IM组观看数据</Button>
              <Button className="getGroupUserByIdList-btn" size="small" color="primary" onClick={getGroupUserByIdList}>获取当前用户信息</Button>
              <Button className="fetchLatestComments-btn" size="small" color="primary" onClick={fetchLatestComments}>获取IM组最新评论列表</Button>
              <input
                value={pageStr}
                type="number"
                max={10}
                min={1}
                className={styles.input}
                style={{ width: 140 }}
                placeholder="用户/消息列表分页"
                onChange={(e) => setPageStr(e.target.value)}
              />
            </Space>

            <Divider />
            <Space direction="vertical">
              <div>测试自定义数据</div>
              <input
                value={testMethod}
                className={styles.input}
                style={{ width: 500 }}
                id="custom-api-input"
                autoComplete="off"
                placeholder="输入测试的接口路径，如 /r/IMMessageLwp/sendMessageToGroup"
                onChange={(e) => setTestMethod(e.target.value)}
              />
              <input
                value={testOption}
                className={styles.input}
                style={{ width: 500 }}
                id="custom-option-input"
                autoComplete="off"
                placeholder={testPlaceholder}
                onChange={(e) => setTestOption(e.target.value)}
              />
              <Button className="senMsg-btn" size="small" color="primary" onClick={senMsg}>调用</Button>
            </Space>
            <Divider />

            <Space wrap>
              <input
                value={comment}
                className={styles.input}
                placeholder="输入评论"
                disabled={sending}
                id="comment-input"
                autoComplete="off"
                onChange={(e) => setComment(e.target.value)}
              />
              <Button className="sendComment-btn" size="small" color="primary" loading={sending} onClick={sendComment}>发送到消息组</Button>
              {
                isCreator ? null : (
                  <Button
                    className="sendCommentToCreator-btn"
                    size="small"
                    color="primary"
                    loading={sending}
                    onClick={() => sendCommentToUser()}
                  >
                    仅发送给IM组创建者
                  </Button>
                )
              }
              <Button className="sendLike-btn" size="small" color="primary" onClick={sendLike}>点赞</Button>
            </Space>

            <Space wrap>
              <input
                value={userIds}
                className={styles.input}
                placeholder="输入要发送的用户ID （多个用,号隔开）"
                disabled={sending}
                id="users-input"
                autoComplete="off"
                onChange={(e) => setUserIds(e.target.value)}
              />
              <Button
                className="highCommentToUsers-btn"
                size="small"
                color="primary"
                disabled={!userIds || !comment}
                loading={sending}
                onClick={() => sendCommentToUser(LevelEnum.high)}
              >
                高优发送给部分用户
              </Button>
              <Button
                className="middleCommentToUsers-btn"
                size="small"
                color="primary"
                disabled={!userIds || !comment}
                loading={sending}
                onClick={() => sendCommentToUser(LevelEnum.middle)}
              >
                中优发送给部分用户
              </Button>
            </Space>
            
            <p>以下功能除了获取禁言用户列表外，其余功能只有 IM 组创建者才能调用</p>
            <Space wrap>
              <Button className="muteAll-btn" size="small" color="primary" onClick={muteAll}>全员禁言</Button>
              <Button className="cancelMuteAll-btn" size="small" color="primary" onClick={cancelMuteAll}>取消全员禁言</Button>
              <input
                value={muteUserId}
                className={styles.input}
                placeholder="输入要处理禁言的用户id"
                id="muteUserId-input"
                autoComplete="off"
                onChange={(e) => setMuteUserId(e.target.value)}
              />
              <Button className="muteUser-btn" size="small" color="primary" onClick={muteUser}>禁言某人</Button>
              <Button className="cancelMuteUser-btn" size="small" color="primary" onClick={cancelMuteUser}>取消禁言某人</Button>
              <Button className="listMuteUsers-btn" size="small" color="primary" onClick={listMuteUsers}>获取禁言的用户列表</Button>
            </Space>

            {commentList.map((item: any) => (
              <div key={item.messageId} style={{ marginTop: 8 }}>
                <span
                  data-js="messageItem"
                  data-senderid={item.senderId}
                  data-messageid={item.messageId}
                  data-datetime={item.datetime}
                >
                  {item.senderNick}
                </span>
                <span style={{ marginLeft: 8}}>{item.content}</span>
              </div>
            ))}
          </Space>
        ) : null
      }
    </section>
  )
}
