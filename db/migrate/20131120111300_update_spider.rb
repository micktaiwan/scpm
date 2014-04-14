class UpdateSpider < ActiveRecord::Migration
	def self.up
		history_counters = HistoryCounter.find(:all, :conditions => ["concerned_spider_id IS NOT NULL"])
		history_counters.each do |history_counter|
			spider = Spider.find(:first, :conditions=>["id = ?",history_counter.concerned_spider_id])
			if spider
				spider.impact_count = 1
				spider.save
			end
		 end
	end

	def self.down
		Spider.find(:all).each {|s| 
			s.impact_count = 0
			s.save
		}
	end
end

