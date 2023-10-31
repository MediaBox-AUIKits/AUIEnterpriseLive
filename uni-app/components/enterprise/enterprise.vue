<template>
  <!-- 企业直播模块入口 -->
	<view class="wrap">
		<room-header />
		<view class="player-container">
			<player
				:is-playback="isPlayback"
				@update-is-playback="updateIsPlayback"
			/>
		</view>
		<view
			v-if="isInited"
			class="room-content"
		>
			<tabs
				:tabs="tabs"
				:active-tab="activeTab"
				@update="updateActiveTab"
			/>
			<intro-panel
				v-show="activeTab === 'intro'"
			/>
			<chat-panel
				v-show="activeTab === 'chat'"
				:visible="activeTab === 'chat'"
			/>
			<char-controls
				:allow-chat="activeTab === 'chat'"
				:joined-group-id="joinedGroupId"
			/>
		</view>
	</view>
</template>

<script>
	import { mapGetters } from 'vuex';
	import RoomHeader from './roomHeader.vue';
	import Player from '../player/player.vue';
	import Tabs from './tabs.vue';
	import IntroPanel from './introPanel.vue';
	import ChatPanel from './chatPanel.vue';
	import CharControls from './chatControls.vue';
	import { RoomStatus } from '@/utils/constants.js';
	
	const IntroTabKey = 'intro';
	const ChatTabKey = 'chat';
	
	export default {
		name: 'enterprise',
		
		components: {
			RoomHeader,
			Player,
			Tabs,
			IntroPanel,
			ChatPanel,
			CharControls,
		},
		
		props: {
			joinedGroupId: {
				type: String,
				default: '',
			},
		},
		
		data() {
			return {
				isPlayback: false,
				tabs: [{
					key: IntroTabKey,
					text: '简介',
				}],
				activeTab: IntroTabKey,
			};
		},
		
		computed: {
			...mapGetters({
				roomInfo: 'liveroom/info',
			}),
			roomStatus() {
				return this.roomInfo.status;
			},
			isInited() {
				return this.roomStatus !== RoomStatus.no_data;
			},
		},
		
		watch: {
			roomStatus(val, oldVal) {
				// 从未初始化变为未开始、直播中时，展示聊天 tab
				if (oldVal === RoomStatus.no_data && [RoomStatus.not_start, RoomStatus.started].includes(val)) {
					this.tabs.push({
						key: ChatTabKey,
						text: '聊天',
					});
				}
			},
		},
		
		methods: {
			updateIsPlayback(bool) {
				this.isPlayback = bool;
			},
			
			updateActiveTab(val) {
				this.activeTab = val;
			}
		},
	}
</script>

<style lang="scss">
	@import 'base.scss';
	
	.wrap {
		position: relative;
		display: flex;
		flex-direction: column;
		width: 100%;
		height: 100%;
		font-size: 0.28rem;
	}
	
	.player-container {
		position: relative;
		flex: none;
		width: 100%;
		padding-top: 56.25%;
		color: #fff;
		background-color: #000;
	}
	
	.room-content {
		flex: auto;
		min-height: 300px;
		padding-bottom: constant(safe-area-inset-bottom); /* 兼容 iOS < 11.2 */
		padding-bottom: env(safe-area-inset-bottom); /* 兼容 iOS >= 11.2 */
	}
</style>