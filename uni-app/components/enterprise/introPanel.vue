<template>
	<view class="intro-panel">
		<view class="intro-panel__title">
			{{ roomInfo.title }}
		</view>
		<view v-if="dateStr" class="intro-panel__date">
			{{ dateStr }}
		</view>
		<view class="intro-panel__notice">
			{{ roomInfo.notice || '暂无公告' }}
		</view>
	</view>
</template>

<script>
	import { mapGetters } from 'vuex';
	import { formatDate } from '@/utils/common.js';
	
	export default {
		name: 'IntroPanel',
		
		computed: {
			...mapGetters({
				roomInfo: 'liveroom/info',
			}),
			dateStr() {
				if (this.roomInfo.createdAt) {
					return formatDate(new Date(this.roomInfo.createdAt));
				}
				return '';
			},
		},
	}
</script>

<style lang="scss" scoped>
	@import 'base.scss';
	
	.intro-panel {
		@extend %panel-wrap;
		padding: 0.24rem 0.32rem;
	}
	
	.intro-panel__title {
	  margin: 0;
	  font-size: 0.32rem;
	  font-weight: 500;
	  color: $text-color-darken;
	}
	
	.intro-panel__date {
	  margin: 0.08rem 0 0;
	  color: $text-color-lighten;
	  font-size: 0.24rem;
	}
	
	.intro-panel__notice {
	  margin: 0.16rem 0 0;
	  line-height: 0.44rem;
	  word-break: break-word;
	}
</style>