require './app'
set :environment, :development
disable :run

#use Rack::ShowExceptions
#use Rack::Static, :urls => [ '/favicon.ico', '/css' ], :root => "public"

run Sinatra::Application
