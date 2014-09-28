require 'rubygems'
require 'json'
require 'net/http'

class TodosController < ApplicationController

    respond_to :json

   def show
      
       Rails.logger.info "session......."
        uri= URI.parse("http://recruiting-api.nextcapital.com/users/#{session[:user_id]}/todos.json?api_token=#{session[:token]}")
        response = Net::HTTP.get_response(uri)
         data = response.body
         after_parse=JSON.parse(data)
         @todos=after_parse
         Rails.logger.info @todos.inspect
         if @todos.size==1 && @todos[0]["error"] #token conflict?
             session[:user_id]=nil
             session[:token]=nil
             redirect_to :controller => :users, :action=> :index
         end
   end   
     
   
   def order_show
      @asc=params[:asc]
      Rails.logger.info @asc
      @all_todos=params[:all_todos]
      order_by_what=params[:order_by_what]
      if order_by_what=="id"
         if @asc=="false"
         @todos=@all_todos.sort_by{|a| -a[order_by_what].to_i}
         else 
         @todos=@all_todos.sort_by{|a| a[order_by_what].to_i}
      end
      else
         if @asc=="false"
         @todos=@all_todos.sort{|a,b| b[order_by_what].to_s <=> a[order_by_what].to_s}
         else 
         @todos=@all_todos.sort{|a,b| a[order_by_what].to_s <=> b[order_by_what].to_s}
      end
      end
      Rails.logger.info @todos
      respond_to do |format|
         format.js
      end
   end
   
   def move
        Rails.logger.info "move....."
        @todos=params[:all_todos]
        Rails.logger.info @todos
        move_id=params[:move_id].to_i
        if params[:direction]=="up" && move_id!=0
            tmp=@todos[move_id-1]
            @todos[move_id-1]=@todos[move_id]
            @todos[move_id]=tmp      
        elsif params[:direction]=="down" && move_id!=@todos.size-1
             tmp=@todos[move_id+1]
            @todos[move_id+1]=@todos[move_id]
            @todos[move_id]=tmp 
        end           
         respond_to do |format|
         format.js
      end   
         
   end   
   
   
   def add_todo
         uri= URI.parse("http://recruiting-api.nextcapital.com/users/#{session[:user_id]}/todos")
         obj_description={:description=>params[:description]}
         post_params = {:todo=>obj_description,:api_token=>session[:token]}
         req = Net::HTTP::Post.new(uri.path)
         req.body = JSON.generate(post_params)
         req["Content-Type"] = "application/json"
         http = Net::HTTP.new(uri.host, uri.port)
         response = http.start {|htt| htt.request(req)}
         data = response.body
         @after_parse=JSON.parse(data)
         render "show_message"
   end
   
   def edit
       @todo_id=params[:id]
       @description=params[:description]
       @is_complete=params[:is_complete]
   end
   def create
         uri= URI.parse("http://recruiting-api.nextcapital.com/users/#{session[:user_id]}/todos/#{params[:todo_id]}")
         obj_d_comp={:description=>params[:description],:is_complete=>params[:is_complete]}
         put_params = {:todo=>obj_d_comp,:api_token=>session[:token]}
         req = Net::HTTP::Put.new(uri.path)
         req.body = JSON.generate(put_params)
         req["Content-Type"] = "application/json"
         http = Net::HTTP.new(uri.host, uri.port)
         response = http.start {|htt| htt.request(req)}
         data = response.body
         @after_parse=JSON.parse(data)
         render "show_message"
         
   end
end