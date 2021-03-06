require 'sinatra'
require 'slim'
require 'sass'
require './song'
require 'sinatra/flash'
require 'pony'
require './sinatra/auth'
require 'v8'
require 'coffee-script'

configure do
  enable :sessions
  set :username, 'frank'
  set :password, 'sinatra'
end

configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
  set :email_address => 'smtp.gmail.com',
      :email_user_name => '',
      :email_password => '',
      :email_domain => 'localhost.localdomain'
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
  set :email_address => 'smtp.sendgrid.net',
      :email_user_name => ENV['SENDGRID_USERNAME'],
      :email_password => ENV['SENDGRID_PASSWORD'],
      :email_domain => 'heroku.com'
end

before do
  set_title
end

helpers do
  def css(*stylesheets)
    stylesheets.map do |stylesheet| 
      "<link href=\"/#{stylesheet}.css\" media=\"screen, projection\" rel=\"stylesheet\" />"
    end.join
  end

  def current?(path='/')
    (request.path==path || request.path==path+'/') ? "current" : nil
  end

  def set_title
    @title ||= "Songs By Sinatra"
  end

  def send_message
    Pony.mail(
      :from => params[:name] + "<" + params[:email] + ">",
      :to => 'joe.astuccio@gmail.com',
      :subject => params[:name] + " has contaced you",
      :body => params[:message],
      :port => '587',
      :via => :smtp,
      :via_options => {
        :address              => 'smtp.gmail.com',
        :port                 => '587',
        :enable_starttls_auto => true,
        :user_name            => 'daz',
        :password             => 'secret',
        :authentication       => :plain,
        :domain               => 'localhost.localdomain'          
      })
  end
end

get('/styles.css'){ scss :styles }
get('/javascripts/application.js'){ coffee :application }

# grab the name entered in the URL and store it in the params hash
get '/set/:name' do
  session[:name] = params[:name]
end

get '/get/hello' do
  "Hello #{session[:name]}"
end

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

post '/contact' do
  send_message
  flash[:notice] = "Thank you for your message.  We'll be in touch soon"
  redirect to('/')
end

get '/logout' do
  session.clear
  redirect to('/login')
end

get '/login' do
  slim :login
end

post '/login' do
  if params[:username] == settings.username && params[:password] == settings.password
    session[:admin] = true
    redirect to('/songs')
  else
    slim :login
  end
end

not_found do
  @title = "404 Error"
  slim :not_found
end