#!/usr/bin/env ruby

require "rubygems"
require "sinatra"
require "flickraw-cached"
require "peach"

FlickRaw.api_key="72245bbf7542ad1b377334731cb01cb4"
FlickRaw.shared_secret="9fba7d0bde24db8e"

enable :sessions
set :public, File.dirname(__FILE__)

get "/" do
  session["frob"] = flickr.auth.getFrob
  auth_url = FlickRaw.auth_url(:frob => session["frob"], :perms => 'read')
  <<-HERE
    <p>The idea here is that people who take photos that you like like favorite
    photos that you also like. So this little app will show you some of your
    favorites. Click on a photo to load in some of the favorites from the
    photographer. New photos will show up at the end of the list. Hope you find
    some gems.</p>
    <p>
      <a href="#{auth_url}" target="_blank">Click here to authenticate</a><br />
      <a href="/check_authentication">Once youve authenticated click here</a>
    </p>
  HERE
end

get "/check_authentication" do
  auth = flickr.auth.getToken :frob => session["frob"]
  session["token"] = auth.token
  redirect to("/favorites_of/#{auth.user.nsid}")
end

get "/favorites_of/:flickr_id" do |flickr_id|

  auth = flickr.auth.checkToken :auth_token => session["token"]

  favorites = flickr.favorites.getList(:user_id => flickr_id, :per_page => 10).to_a
  favorites_info = favorites.pmap do |favorite|
    info = flickr.photos.getInfo(:photo_id => favorite.id)
    url = FlickRaw.url_z(info)
    {
      :title => info["title"],
      :username => info["owner"]["username"],
      :nsid => info["owner"]["nsid"], 
      :url => url
    }
  end

  favorites_code = favorites_info.map do |info|
    <<-HERE
      <p>
        #{info[:title]} by #{info[:username]}<br />
        <a href="/favorites_of/#{info[:nsid]}">
          <img src="#{info[:url]}" />
        </a>
      </p>
    HERE
  end

  (request.xhr? ? "" : "<script src='https://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.js'></script><script src='/application.js'></script>") + 
  favorites_code.to_s

end

