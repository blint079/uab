#!/usr/bin/ruby 

require 'csv' 
require 'services/service_helper'
#raise "NO FILE PROVIDED " unless ARGV[0] 

#f = File.open(ARGV[0]) 
class Parser
	attr_accessor :sku_buckets
	def parse 
		f = File.open('../data/catalog.csv') 
		
		csv_dump = CSV.parse(f.read) 
		sku_count = 0 
		@sku_buckets = Hash.new
		sku_cursor = nil 
		keys = csv_dump.shift 
		#puts "extracted keys as #{keys}"
		csv_dump.each do  |r| 
				row_sku = nil 
				if r[0] and r[0].length > 3 
					row_sku = r[0]	
					sku_count += 1 
				end
				if !row_sku.nil?
					sku_cursor = row_sku 
					#puts "set sku_cursor to #{sku_cursor}"
				end 
				@sku_buckets[sku_cursor] = Hash.new unless sku_buckets.has_key?(sku_cursor)
				@sku_buckets[sku_cursor]['raw'] = Array.new unless sku_buckets[sku_cursor]['raw'].kind_of?(Array)
				@sku_buckets[sku_cursor]['raw'].push(r) 
		end
		#puts "parsed #{ sku_buckets.keys.length } skus"
		@sku_buckets.keys.sample(4).each do |k| 
			 	@sku_buckets[k]['doc'] = Hash.new
			 	v = @sku_buckets[k]
			 	@sku_buckets[k]['doc']['options'] = Array.new
			 	#c_bk = @sku_buckets[k]['doc']
			 	v['raw'].each do |r|
					if r[0].nil?
						@sku_buckets[k]['doc']['options'].push(Hash.new)
						c_bk = @sku_buckets[k]['doc']['options'][-1]
					else
			 			c_bk = @sku_buckets[k]['doc']
					end
					r.each_index do |c|
						next if r[c].nil?
						clean_key = keys[c].sub('_','')
						if c_bk.has_key?(clean_key)
							 if   c_bk[clean_key].kind_of?(Array)
							 			c_bk[clean_key].push(r[c])
								else 
							 			option = c_bk[clean_key]
										 c_bk[clean_key] = Array.new
										 c_bk[clean_key].push(option)
										 c_bk[clean_key].push(r[c])
								end
						else
						c_bk[clean_key] = r[c]
						end 
					end
				end
				product_db = ServiceBase.new('products') 
				product_db.save(@sku_buckets[k]['doc'])
		end
	end
end
