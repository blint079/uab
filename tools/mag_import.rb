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
xml_o.each do |p|
	p = m.call('catalog_product.info',p['product_id'])
	product_db.save(p)
end




