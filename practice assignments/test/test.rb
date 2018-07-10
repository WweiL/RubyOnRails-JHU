require 'httparty'

# ENV["FOOD2FORK_KEY"] = '939c9d386fae35b4a5db386fea105a24'
# ENV["FOOD2FORK_SERVER_AND_PORT"] = "food2fork.com:80"

class Recipe
  include HTTParty
  hostport = ENV['FOOD2FORK_SERVER_AND_PORT'] || 'www.food2fork.com'
  base_uri "http://#{hostport}/api"
  default_params key: ENV["FOOD2FORK_KEY"]
  format :json

  def self.for(keyword)
    get("/search", query: {q: keyword})["recipes"]
  end
        
end
