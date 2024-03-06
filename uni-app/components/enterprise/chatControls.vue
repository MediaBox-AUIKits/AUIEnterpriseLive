<template>
	<view class="chat-controls">
		<input
			:class="['chat-input', { 'fixed': inputFixedBottom > 0 }]"
			:style="{
				visibility: allowChat ? 'visible' : 'hidden',
				bottom: `${inputFixedBottom}px`,
			}"
			placeholder-class="chat-input-placeholder"
			:placeholder="chatPlaceholder"
			:disabled="chatInputDisbale"
			v-model="text"
			confirm-type="send"
			:adjust-position="false"
			@confirm="handleConfirm"
			@focus="handleFocus"
			@blur="handleBlur"
		/>
		
		<!-- 手动调起分享，处理逻辑在 pages/room.vue onShareAppMessage 中 -->
		<button
			class="operation-btn-wrap share-btn"
			<!-- #ifdef MP-WEIXIN -->
			open-type="share"
			<!-- #endif -->
			<!-- #ifdef H5 -->
			@click="handleShare"
			<!-- #endif -->
		>
			<view class="operation-btn auiicon-Share"></view>
		</button>
		<view class="operation-btn-wrap heart-btn" @click="handleClickLike">
			<view class="operation-btn auiicon-Heart"></view>
			<like-anime ref="animeRef" />
		</view>
	</view>
</template>

<script>
	import { mapGetters } from 'vuex';
	import { throttle } from '@/utils/common.js';
	import LikeAnime from '../likeAnime/likeAnime.vue';
	
	export default {
		name: 'ChatControls',
		
		components: {
			LikeAnime,
		},
		
		props: {
			allowChat: {
				type: Boolean,
				default: false,
			},
			joinedGroupId: {
				type: String,
				default: '',
			},
		},
		
		data() {
			return {
				text: '',
				sending: false,
				likeCount: 0,
				inputFixedBottom: 0, // 绝对定位时的值
			};
		},
		
		computed: {
			...mapGetters({
				roomInfo: 'liveroom/info',
			}),
			chatPlaceholder() {
				if (this.roomInfo.groupMuted) {
					return '全员禁言中';
				}
				if (!this.allowChat) {
					return ' '; // 真机模拟时发现不展示输入框
				}
				return '和主播说点什么';
			},
			chatInputDisbale() {
				return !this.allowChat || this.sending || !!this.roomInfo.groupMuted;
			}
		},
		
		created() {
			this.interaction = getApp().globalData.interaction;
			
			this.sendLike = throttle(this.sendLike, 1500, { noLeading: true });
		},
		
		methods: {
			handleFocus(evt) {
				if (evt.detail.height > 35) {
					this.inputFixedBottom = evt.detail.height;
				}
			},
			handleBlur() {
				this.inputFixedBottom = 0;
			},
			// 发送消息
			handleConfirm(evt) {
				const content = this.text.trim();
				if(
					!content ||
					!this.joinedGroupId ||
					this.sending ||
					this.roomInfo.groupMuted
				) {
					return;
				}
				// console.log(this.joinedGroupId, content);
				const options = {
				    groupId: this.joinedGroupId,
				    type: 10001,
				    data: JSON.stringify({ content }),
				};
				this.interaction
					?.getMessageManager()
					?.sendGroupMessage(options)
					.then(() => {
						console.log('发送成功');
						this.text = '';
					})
					.catch((err) => {
						console.log('发送失败', err);
					})
					.finally(() => {
						this.sending = false;
					});
			},
			handleClickLike() {
				this.$refs.animeRef.add();
				this.likeCount += 1;
				// 执行发送点赞数据
				this.sendLike();
			},
			// 点赞
			sendLike() {
				// 自行实现
				uni.showToast({
					title: '点赞逻辑请自行实现',
				});
			},
			handleShare() {
				uni.showToast({
					title: '分享请自行实现',
					icon: 'none',
				});
			},
		},
	}
</script>

<style lang="scss" scoped>
	@import 'base.scss';
	$text-color: #A6ACB9;
	$block-backgroud-color: #F4F4F6;
	
	.chat-controls {
		position: relative;
		display: flex;
		width: 100%;
		height: $controls-height;
		padding: 0.08rem 0.32rem;
	}
	
	.chat-input {
		color: $text-color;
		background-color: $block-backgroud-color;
		border: none;
		outline: none;
		border-radius: 0.5rem;
		width: 2.76rem;
		height: 0.72rem;
		min-height: 0.72rem;
		margin-right: auto;
		padding: 0 0.24rem;
		font-size: 0.28rem;
		
		&.fixed {
			position: fixed;
			left: 0;
			right: 0;
			width: auto;
			border-radius: 0;
			border-top: 1px solid $text-color;
		}
		
		.a-input-wrap {
			background-color: transparent;
		}
	}
	
	.chat-input-placeholder {
		color: $text-color;
		font-size: 0.28rem;
		
		&.fixed {
			color: #FCFCFD;
		}
	}
	
	.operation-btn-wrap {
		position: relative;
		box-sizing: content-box;
		margin-left: 0.24rem;
		
		&.heart-btn {
			color: #E91E63;
		}
	}
	
	.share-btn {
		margin-right: 0;
		padding: 0;
		color: $text-color;
		background-color: transparent;
		&::after {
			border: none;
		}
	}
	
	.operation-btn {
		position: relative;
		display: block;
		width: 0.72rem;
		height: 0.72rem;
		line-height: 0.72rem;
		font-size: 0.52rem;
		text-align: center;
		background-color: $block-backgroud-color;
		border-radius: 50%;
		cursor: pointer;
	}
</style>