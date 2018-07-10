require 'httparty'

ENV["FOOD2FORK_KEY"] = '939c9d386fae35b4a5db386fea105a24'

class Recipe
  include HTTParty
  base_uri 'http://food2fork.com/api'
  default_params key: ENV["FOOD2FORK_KEY"]
  format :json

  def self.for(term)
    get("/search", query: {q: term})["recipes"]
  end
        
end
