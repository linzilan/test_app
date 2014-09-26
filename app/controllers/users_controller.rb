require 'rubygems'
require 'json'
require 'net/http'

class UsersController < ApplicationController
 skip_before_filter :token_check
    respond_to :json
 
   def index

     if session[:user_id] && session[:token]
     Rails.logger.info @user
     redirect_to :controller=>"todos" ,:action=>"show"
     else
     end
   end
     

   def  create
         uri= URI.parse("http://recruiting-api.nextcapital.com/users")
         post_params = {:email=>params[:user], :password=>params[:password]}
         req = Net::HTTP::Post.new(uri.path)
         req.body = JSON.generate(post_params)
         req["Content-Type"] = "application/json"
         http = Net::HTTP.new(uri.host, uri.port)
         response = http.start {|htt| htt.request(req)}
         data = response.body
         after_parse=JSON.parse(data)
         Rails.logger.info after_parse
         unless after_parse.size==1  
            @email=after_parse["email"]
            render "show_message_success" 
          else
             @error_message="Sorry, your email "+after_parse["email"][0]
             render "show_message"    
          end
   end
   
   def login 
          uri= URI.parse("http://recruiting-api.nextcapital.com/users/sign_in")
         post_params = {:email=>params[:user], :password=>params[:password]}
         req = Net::HTTP::Post.new(uri.path)
         req.body = JSON.generate(post_params)
         req["Content-Type"] = "application/json"
         http = Net::HTTP.new(uri.host, uri.port)
         response = http.start {|htt| htt.request(req)}
         data = response.body
         after_parse=JSON.parse(data)
         Rails.logger.info after_parse    
         unless after_parse["error"]    
            @email=after_parse["email"]
            session[:user_id]=after_parse["id"]
            session[:token] = after_parse["api_token"]

            redirect_to:controller=>"todos" ,:action=>"show" 
          else
             @error_message=after_parse["error"]
             render "show_message"    
          end

   end

   def sign_out
      uri= URI.parse("http://recruiting-api.nextcapital.com/users/sign_out")
      post_params = {:api_token=>session[:token], :user_id=>session[:user_id]}
      Rails.logger.info post_params
      session[:user_id]=nil
      session[:token]=nil
      req = Net::HTTP::Delete.new(uri.path)
      req.body = JSON.generate(post_params)
      req["Content-Type"] = "application/json"
      http = Net::HTTP.new(uri.host, uri.port)
      response = http.start {|htt| htt.request(req)}
      data = response.body
      after_parse=JSON.parse(data)   
     redirect_to root_path
   end
   
   def show_message
    end

end