# register your app at facebook to get those infos
# your app id
APP_ID     = Enter app ID
# your app secret
APP_SECRET = 'Enter your key '
USER_PROFILE_OPTIONS = {
    fields: %w(id first_name last_name hometown email 
               gender birthday picture.width(320))
  }.freeze

class FbController < ApplicationController

  #use Rack::Session::Cookie, secret: 'a70dbd8d3694c390e'

  def fbimages
    if session[:access_token]
      'You are logged in! <a href="/logout">Logout</a>'
      facebook = Koala::Facebook::API.new(session[:access_token])
      @user = facebook.get_object("me", USER_PROFILE_OPTIONS)
      @fbphoto = @user['picture']['data']['url']
    end
  end

  def fblogin
    # generate a new oauth object with your app data and your callback url
    session[:oauth] = Koala::Facebook::OAuth.new(APP_ID, APP_SECRET, "#{request.base_url}/callback")
    # redirect to facebook to get your code
    redirect_to session[:oauth].url_for_oauth_code()
  end

  def fblogout
    session['oauth'] = nil
    session['access_token'] = nil
    redirect_to '/'
  end

  #method to handle the redirect from facebook back to you
  def fbcallback
    #get the access token from facebook with your code
    session['oauth'] = Koala::Facebook::OAuth.new(APP_ID, APP_SECRET, "#{request.base_url}/callback")
    session[:access_token] = session[:oauth].get_access_token(params[:code])
    redirect_to '/fbimages'
  end
end

