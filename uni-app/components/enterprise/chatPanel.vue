<template>
	<view
		class="chat-panel-wrap"
		id="panelWrap"
	>
		<scroll-view
			class="chat-panel"
			:style="{ height: panelWrapHeight + 'px' }"
			:scroll-y="true"
			:enable-flex="true"
			:scroll-into-view="scrollIntoViewId"
			@scroll="handleScroll"
		>
			<view class="chat-item-wrap">
				<view class="chat-item chat-item-notice">
					欢迎大家来到直播间！直播间内严禁出现违法违规、低俗色情、吸烟酗酒等内容，若有违规行为请及时举报。
				</view>
			</view>
			
			<view
				v-for="(item) in commentList"
				:id="item.messageId"
				:key="item.messageId"
				class="chat-item-wrap"
			>
				<view class="chat-item">
					<view v-if="item.isSelf" class="chat-item__self">我</view>
					<view v-if="!item.isSelf && item.isAnchor" class="chat-item__anchor">主播</view>
					<view class="chat-item__nick">{{ item.nickName }}:</view>
					<view class="chat-item__content">{{ item.content }}</view>
				</view>
			</view>
		</scroll-view>
		
		<view
			v-show="newTipVisible"
			class="chat-new__tip"
			@click="handleNewTipClick"
		>
			您有新消息
		</view>
	</view>
</template>

<script>
	import { mapGetters } from 'vuex';
	import { InteractionEventNames, InteractionMessageTypes } from  '@/utils/aliyun-interaction-sdk.mini.esm.js';
	import { CustomMessageTypes, MaxMessageCount } from '@/utils/constants.js';
	import services from '@/utils/services.js';
	import { throttle } from '@/utils/common.js';
	
	// 距离聊天列表底部最大值
	const MaxBottomDistance = 60;
	
	export default {
		name: 'ChatPanel',
		
		props: {
			visible: {
				type: Boolean,
				default: false,
			},
		},
		
		data() {
			return {
				panelWrapHeight: 0,
				commentList: [],
				autoScroll: true,
				newTipVisible: false,
				scrollIntoViewId: '', // 聊天列表自动定位滚动到的id
			};
		},
		
		computed: {
			...mapGetters({
				roomInfo: 'liveroom/info',
			}),
		},
		
		created() {
			this.interaction = getApp().globalData.interaction;
			this.interaction.on(InteractionEventNames.Message, (eventData) => {
			    this.handleReceivedMessage(eventData || {});
			});
			
			this.handleScroll = throttle(this.handleScroll, 500, { noLeading: false });
		},
		
		watch: {
			visible(bool) {
				if (bool && !this.panelWrapHeight) {
					const query = uni.createSelectorQuery().in(this);
					query.select('#panelWrap').boundingClientRect(data => {
						if (data && data.height) {
							this.panelWrapHeight = data.height;
						}
					}).exec();
				}
				// 因 scroll-view 未可见时 scroll-into-view 不生效，所以可见时主动触发更新
				if (bool) {
					this.handleNewTipClick();
				}
			},
		},
		
		methods: {
			// 处理接收到的信息
			handleReceivedMessage(eventData) {
				const { type, data, messageId, senderId, senderInfo = {} } = eventData || {};
				const nickName = senderInfo.userNick || senderId;
				// console.log('chatbox 消息', type, data);
			
				switch (type){
					case InteractionMessageTypes.PaaSUserJoin:
					    // 用户加入聊天组，更新直播间统计数据
					    this.handleUserJoined(nickName, data, messageId);
					    break;
					case InteractionMessageTypes.PaaSLikeInfo:
					    // 用户点赞数据，目前页面未使用
					    // console.log(nickName, data, messageId);
					    break;
					case CustomMessageTypes.Comment:
						// 接收到评论消息
						if (data && data.content) {
							this.addMessageItem(data.content, senderId, nickName, messageId);
						}
						break;
					case InteractionMessageTypes.PaaSMuteGroup:
						this.text = '';
						this.$store.commit('liveroom/updateInfo', { groupMuted: true });
						this.showToast('主播已开启全员禁言');
						break;
					case InteractionMessageTypes.PaaSCancelMuteGroup:
						this.$store.commit('liveroom/updateInfo', { groupMuted: false });
						this.showToast('主播已解除全员禁言');
						break;
					case InteractionMessageTypes.PaaSMuteUser:
						this.handleMuteUser(true, data);
						break;
					case InteractionMessageTypes.PaaSCancelMuteUser:
						this.handleMuteUser(false, data);
						break;
					case CustomMessageTypes.NoticeUpdate:
						// banner 组件中的公告内容更新
						if (typeof data.notice === 'string') {
							this.$store.commit('liveroom/updateInfo', { notice: data.notice });
							this.showToast('公告已更新');
						}
						break;
					default:
						break;
				}
			},
			handleUserJoined(nickName, data, messageId) {
				// 更新统计数据
				if (data && data.statistics) {
				    this.$store.commit('liveroom/updateMetrics', data.statistics);
				}
			},
			// 添加评论
			addMessageItem(content, senderId, nickName, messageId) {
				const mid = `m_${messageId}`;
				const userData = services.getUserInfo();
				const isSelf = userData.userId === senderId;
				
				const messageItem = {
					messageId: mid,
					content,
					nickName,
					isSelf,
					isAnchor: this.roomInfo.anchorId === senderId,
				};
				if (isSelf) {
					this.autoScroll = true;
				}
				if (this.autoScroll) {
					// 因 scroll-view 未可见时 scroll-into-view 不生效
					// 这里只有可见时才更新 scrollIntoViewId ，不可见时不出来，待重新可见时再更新
					if (this.visible) {
						this.newTipVisible = false;
						// 需要加延时 H5 才生效
						setTimeout(() => {
							this.scrollIntoViewId = mid;
						}, 10);
					}
				} else {
					this.newTipVisible = true;
				}
				this.commentList.push(messageItem);
				if(this.commentList.length > MaxMessageCount) {
					this.commentList.shift();
				}
			},
			// 处理禁言
			handleMuteUser(isMuted, userInfo) {
				const userData = services.getUserInfo();
				// 只展示你个人的禁言消息
				if (userData.userId !== userInfo.userId) {
				    return;
				}
				if (isMuted) {
					this.text = '';
					this.$store.commit('liveroom/updateInfo', { selfMuted: true });
					this.showToast('已被禁言');
				} else {
					this.$store.commit('liveroom/updateInfo', { selfMuted: false });
					this.showToast('已被解除禁言');
				}
			},
			showToast(text) {
				uni.showToast({
					title: text,
					icon: 'none',
				});
			},
			handleScroll(event) {
				if (event && event.detail && event.detail.scrollHeight) {
					const diff = event.detail.scrollHeight - (this.panelWrapHeight + event.detail.scrollTop);
					this.autoScroll = diff < MaxBottomDistance;
					if (this.autoScroll) {
						this.newTipVisible = false;
					}
				}
			},
			handleNewTipClick() {
				this.autoScroll = true;
				this.newTipVisible = false;
				const len = this.commentList.length;
				if (len) {
					this.scrollIntoViewId = this.commentList[len - 1].messageId;
				}
			},
		},
	};
</script>

<style lang="scss" scoped>
	@import 'base.scss';
	
	.chat-panel-wrap {
		@extend %panel-wrap;
	}
	
	.chat-panel {
		height: 100%;
	}
	
	.chat-item-wrap {
		padding: 0 0.32rem 0.24rem;
	}
	
	.chat-item {
		display: inline-block;
		padding: 0.04rem 0.16rem;
		color: $text-color-darken;
		background-color: #FFF;
		border-radius: 2px;
		word-break: break-word;
		line-height: 0.44rem;
	}
	
	.chat-item-notice {
		margin-top: 0.32rem;
		padding: 0.2rem 0.16rem;
		font-size: 0.24rem;
		line-height: 1.5;
		color: #3BB346;
	}
	
	.chat-item__nick {
		display: inline-block;
		vertical-align: middle;
		color: $text-color-lighten;
		margin-right: 4px;
	}
	
	.chat-item__content {
		display: inline;
		vertical-align: middle;
	}
	
	%chat-item__mark {
		display: inline-block;
		vertical-align: middle;
		margin-right: 0.08rem;
		padding: 0.04rem 0.08rem;
		border-radius: 2px;
		font-size: 0.24rem;
	}
	
	.chat-item__anchor {
		@extend %chat-item__mark;
		color: #FC8800;
		background-color: #FFF8EA;
	}
	
	.chat-item__self {
		@extend %chat-item__mark;
		color: #FF5722;
		background-color: #FBE9E7;
	}
	
	.chat-new__tip {
		position: absolute;
		right: 0;
		bottom: 0.24rem;
		padding: 0.1rem 0.12rem;
		font-size: 0.24rem;
		text-align: right;
		color: $uni-color-primary;
		background-color: #FFF;
		box-shadow: 0 4px 8px 0 rgba($uni-color-primary, 0.50);
		border-radius: 0.32rem 0 0 0.32rem;
		cursor: pointer;
		z-index: 10;
	}
</style>