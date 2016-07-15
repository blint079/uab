#service_helper.rb
require 'json/ext'
require 'couchrest'
require 'yaml'
#require_relative '../services/config'

class ServiceBase
#	include ConfigLoader
	attr_accessor :db, :doc, :config

	def initialize(db_name,config = nil)
		@db = CouchRest.database!("http://localhost:5980/#{db_name}")
		#@db = CouchRest.database!("http://54.186.175.170:5984/#{db_name}")
		RAISE "NO DB SELECTED .. UNCOMMENT ONE" unless @db
	end
	
	def save(data) 
		response =@db.save_doc(data)
		return response['id']
	end
	def load(id)
		begin
			@doc = @db.get(id)
		rescue Exception => e
			puts "unable to load document #{db}  l#{id}l  #{e.message}"
			@doc = nil

		end

	end
	def delete
		begin
			@db.delete_doc(@doc)
		rescue Exception => e 
			raise "failed to delete doc: #{e}"
		end

	end
	def find(view,query)
		resp = @db.view(view,query)
		resp
	end
end

