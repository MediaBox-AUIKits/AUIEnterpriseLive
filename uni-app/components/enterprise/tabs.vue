<template>
	<view class="tabs">
		<view
			v-for="(item) in tabs"
			:key="item.key"
			:class="[
				'tabs-item',
				{
					active: activeTab === item.key,
				},
			]"
			@click="updateActiveTab(item.key)"
		>
			{{item.text}}
		</view>
	</view>
</template>

<script>
	export default {
		name: 'Tabs',
		
		props: {
			tabs: {
				type: Array,
				default: () => [],
			},
			activeTab: {
				type: String,
				default: '',
			},
		},
		
		methods: {
			updateActiveTab(val) {
				this.$emit('update', val)
			}
		},
	}
</script>

<style lang="scss" scoped>
	@import 'base.scss';
	
	.tabs {
	  display: flex;
	  justify-content: space-around;
	  width: 100%;
	  height: $tabs-height;
	  line-height: $tabs-height;
	}
	
	.tabs-item {
	  position: relative;
	  padding: 0 0.12rem;
	  font-size: 0.28rem;
	  color: $text-color;
	
	  &.active {
	    color: $text-color-darken;
	    box-shadow: inset 0px -2px $uni-color-primary;
	  }
	}
</style>