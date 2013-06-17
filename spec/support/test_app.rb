require 'sinatra/base'


# @private This is just a test class
class TestApp < Sinatra::Base

  set :root, File.dirname(__FILE__)
  set :raise_errors, true
  # set :show_exceptions, false


  get '/*' do
	  viewname = params[:splat].first   # eg "some/path/here"
	  if File.exist?("#{settings.root}/views/#{viewname}.erb")
	    erb :"#{viewname}"
	  else
	  	"can't find view #{viewname}"
	  end
	end
end

if __FILE__ == $0
  Rack::Handler::WEBrick.run TestApp, :Port => 8070
end
