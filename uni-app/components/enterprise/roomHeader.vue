<template>
	<view
		class="room-header"
		:style="[wrapStyles]"
	>
		<view
			class="exit-btn"
			@click="gotoRoomList"
		>
			<view class="auiicon-LeftOutline"></view>
		</view>
		<view
			class="info-audience"
			:style="{
				float: audienceFloat
			}"
		>
			{{ pvText }}
		</view>
	</view>
</template>

<script>
	import { mapGetters } from 'vuex';
	
	export default {
		name: 'RoomHeader',
		
		data() {
			return {
				height: 40,
				menuButtonTop: 0,
				audienceFloat: 'none',
			};
		},
		
		computed: {
			...mapGetters({
				roomInfo: 'liveroom/info',
			}),
			pvText() {
				const metrics = this.roomInfo.metrics || {};
				const pv = metrics.pv || 0;
				if (pv >= 10000) {
					const num = pv / 10000;
					return `${num.toFixed(1)}W`;
				}
				return pv;
			},
			wrapStyles() {
				const styles = {
					height: this.height + 'px',
					lineHeight: this.height + 'px',
				};
				if (this.menuButtonTop > 0) {
					styles.paddingTop = this.menuButtonTop + 'px';
				}
				return styles;
			},
		},
		
		created() {
			// #ifdef MP-WEIXIN
			this.getMenuPosition();
			// #endif
			
			// #ifdef H5
			this.audienceFloat = 'right'; // H5靠右展示，体验更好
			// #endif
		},
		
		methods: {
			getMenuPosition() {
				const res = uni.getMenuButtonBoundingClientRect();
				// 上下增加 4px，完善体验
				this.menuButtonTop = res.top - 4;
				this.height = res.height + 8;
			},
			
			gotoRoomList() {
				uni.redirectTo({
					url: '/pages/roomList/roomList',
				});
			},
		},
	}
</script>

<style lang="scss">
	.room-header {
		padding-top: constant(safe-area-inset-top); /* 兼容 iOS < 11.2 */
		padding-top: env(safe-area-inset-top); /* 兼容 iOS >= 11.2 */
		box-sizing: content-box;
		background: linear-gradient(180deg, #6f4d47 0%, #2e3336 100%);
		color: #fff;
		
		&:after {
			content: '';
			display: table;
			clear: both;
		}
	}
	
	.exit-btn {
		display: inline-block;
		vertical-align: middle;
		width: 32px;
		height: 100%;
		text-align: center;
		font-size: 0.48rem;
		
		.auiicon-LeftOutline {
			line-height: inherit;
			vertical-align: top;
		}
	}
	
	.info-audience {
		display: inline-block;
		vertical-align: middle;
		margin-left: 0.24rem;
		padding: 0 0.16rem 0 0.52rem;
		background-image: url('https://img.alicdn.com/imgextra/i1/O1CN01GC0HVZ1kWz8bvu0KX_!!6000000004692-2-tps-36-36.png');
		background-position: 0.08rem center;
		background-repeat: no-repeat;
		background-size: 0.32rem 0.32rem;
	}
</style>