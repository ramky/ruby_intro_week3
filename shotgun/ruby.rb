require 'sinatra'

set :sessions, true

get '/home' do
	"Welcome home! It's been a while!!!"
end