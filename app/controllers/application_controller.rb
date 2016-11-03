class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, if: Proc.new {|c| c.request['auth_code'] == ENV['MIRRAW_INHOUSE_AUTH_CODE']}
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!
  include CanCan::ControllerAdditions

  def after_sign_in_path_for(resource)
    root_path
  end

  protected
  def is_admin?
    redirect_to root_path unless current_user.has_role? :admin
  end
  def authorised_user?
    redirect_to root_path unless @user == current_user
  end
  def configure_permitted_parameters
    added_attrs = [:email, :password, :password_confirmation]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end
end
