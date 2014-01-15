require 'rubygems'
require 'sinatra'

set :sessions, true

get '/inline' do
	"Hi, directly from the action"
end

get '/template' do
	erb :my_template
end

get '/nested_template' do
	erb :"users/profile"
end

get '/nothere' do
	redirect '/inline'
end