#! differ.rb
require 'sinatra'
$LOAD_PATH.unshift(File.dirname(__FILE__)+'/lib/')

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
end
