#!/usr/bin/env ruby

require "rubygems"
require "sinatra"
require "pp"
require "flickraw-cached"

FlickRaw.api_key="72245bbf7542ad1b377334731cb01cb4"
FlickRaw.shared_secret="9fba7d0bde24db8e"

enable :sessions

get "/" do
  session['frob'] = flickr.auth.getFrob
  auth_url = FlickRaw.auth_url(:frob => session['frob'], :perms => 'read')
  <<-HERE
    <a href="#{auth_url}" target="_blank">Click here to authenticate</a><br />
    <a href="/my_favorites">My Favorites</a>
  HERE
end

get "/my_favorites" do
  auth = flickr.auth.getToken :frob => session['frob']
  login = flickr.test.login

  # flickr.photos.search(:group_id => group_id, :sort => "interestingness-desc", :per_page => "500")
  my_favorites = flickr.favorites.getList(:user_id => "24918835@N03", :per_page => 10)
  favorite_images = my_favorites.map do |favorite|
    info = flickr.photos.getInfo(:photo_id => favorite.id)
    url = FlickRaw.url_b(info)
    "<img src='#{url}' /><br />"
  end

  <<-HERE
    <p>You are now authenticated as #{login.username} with token #{auth.token}</p>
    <pre>#{my_favorites.inspect}</pre>
    #{favorite_images}
  HERE
end

