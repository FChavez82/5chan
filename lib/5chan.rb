#Jalar todos los gems en Gemfile
require 'rubygems'
require 'bundler'
Bundler.require

require './lib/ooyala_api'
require './lib/asset'
require './lib/comment'
require './lib/user'
require 'yaml'

config = YAML.load(File.read("#{File.dirname __FILE__}/..//config/credentials.yaml"))

api_key = ENV['API_KEY'] || config['api_key']
secret = ENV['SECRET'] || config['secret']
api=Ooyala::API.new api_key, secret

DataMapper.finalize
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/db.sqlite")
DataMapper.auto_upgrade!

#use Rack::Session::Cookie

enable :sessions

use OmniAuth::Builder do
  provider :facebook, ENV['APP_ID'] || config['facebook']['app_id'],
           ENV['APP_SECRET'] || config['facebook']['app_secret'], :scope => 'email'
end

helpers do
  def current_user
    User.get(session[:user_id])
  end
end

get '/' do
  response = api.get("/v2/assets")
  @assets = response['items']

  erb :index
end

get '/assets/:embed_code' do
  @asset = Asset.get(params[:embed_code])
  unless @asset
    response = api.get("/v2/assets/#{params[:embed_code]}")
    @asset=Asset.new( :embed_code => response['embed_code'],
                      :name => response['name'],
                      :description => response['description'],
                      :preview_image_url => response['preview_image_url'])
    @asset.save
  end
  erb :asset 
end

post '/assets/:embed_code' do
  @asset = Asset.get(params[:embed_code])
  @comment = @asset.comments.new( :body => params[:new_comment], :user => current_user)
  @comment.save
  
  erb :asset
end

get '/auth/failure' do
#  "GAME OVER"    
end

get '/auth/:provider/callback' do
  auth = request.env['omniauth.auth']
  @user = User.get(auth['uid']) || User.create_with_omniauth(auth)
  session[:user_id] = @user.uid
  redirect '/'
end

get '/logout' do
  session[:user_id] = nil
  
  redirect '/'
end


