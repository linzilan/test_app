class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :token_check

  protected

  def token_check
    unless session[:token]&&session[:user_id]
      redirect_to :controller => :users, :action=> :index
    end
  end
end