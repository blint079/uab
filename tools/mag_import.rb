require "mag_api" 
require 'services/service_helper'

m = MagentoAPI.new('http://www.aspectsofdecor.com','dataexport','fuckM4gento') 
xml_o = m.call('catalog_product.list')
stp = Hash.new
#xml_o.each do |p|
#	stp[p['sku']] = Array.new if !stp.has_key?(p['sku'])		
#	stp[p['sku']].push(p['product_id'])
#end
product_db = ServiceBase.new('products') 
# xml_o.each { |p| pts[p['product_id']] = { :sku => p['sku'], :category => p['category_ids']}}
pids = xml_o.map{|p| p['product_id']}
#pids = [986]
pids.each do |pid|
	p = m.call('catalog_product.info',pid)
	#puts "got product #{p}"
	p_i =  m.call('catalog_product_attribute_media.list',pid)
	#puts "got product images #{p_i}"
	p['images'] = p_i
	p_a =  m.call('product_custom_option.list',pid)
	#puts "got product attributes #{p_a.map{|o| o['option_id']}}"
	options = Array.new
	p_a.each do |op| 
		o_id =  op['option_id']
		option = m.call('product_custom_option.info',o_id)
		p[option['title']] = option 
	end
	p['category_ids'] = p['categories']
	p['categories'] = Array.new
	p['category_ids'].each do |c_id|
		cat = m.call('catalog_category.info',c_id) 		
		p['categories'].push(cat['name'])
	end
	
	product_db.save(p)
end
