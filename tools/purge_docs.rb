#!/usr/bin/ruby 
# from CLI do `ruby -I . purge_docs.rb [name_of_the_db_you want to purge]
# DO NOT PURGE REPORTS OR IT WILL DELETE OVERRIDES
require 'services/service_helper' 
targets = ARGV.length > 0 ? ARGV : ['products']
targets.each do |t| 
	raise "DO NOT DELETE REPORTS" if t =~ /reports/
	puts "purging docs for #{t}"
	p = ServiceBase.new(t)
	doc_ids = Array.new
	all_docs = p.db.all_docs
	all_docs['rows'].map{|d| doc_ids.push(d['key'])unless  d['key'] =~ /_design/} 
	doc_ids.each do |id|
		p.load(id)
		p.delete
	end
end
