require 'rubygems'
require 'json'
require 'net/http'
 
class TestController < ApplicationController
 
  respond_to :json
  $usaGovURI = "http://recruiting-api.nextcapital.com/users/1/todos.json?api_token=KyvGjBHBeDsBeNsXx9XP"
 
  def getJobs
    response = Net::HTTP.get_response(URI.parse($usaGovURI))
    data = response.body
    JSON.parse(data)
 
    render :text => JSON.parse(data)
    Rails.logger.info JSON.parse(data)
  end
end