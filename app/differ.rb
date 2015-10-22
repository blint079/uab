#! differ.rb
require 'sinatra'
$LOAD_PATH.unshift(File.dirname(__FILE__)+'/lib/')

require 'services/service_helper'

set :protection, except: :session_hijacking 

class Differ < Sinatra::Application
	helpers do
		def h(text)
    			rack::utils.escape_html(text)
  		end
	end
	get '/' do 
		erb :top_template
	end
	get '/display_sku' do 
		404 unless params.has_key?('sku')
		sku = params['sku']
		product = ServiceBase.new('products')
		result = product.find('lookups/sku',{:key => sku})
		id = result['rows'].first['id']
		product.load(id) 
		puts "used SKU #{sku} to find #{id}" 
		erb :display_sku, locals: {:product => product.doc}
	end
end
