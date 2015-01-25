require 'sinatra'
require 'slim'
require 'sass'
require './song'

get('/styles.css'){ scss :styles }

get '/' do
  slim :home
end

get '/about' do
  @title = "All About This Website"
  slim :about
end

get '/contact' do
  @title = "Contact"
  slim :contact
end

not_found do
  @title = "404 Error"
  slim :not_found
end