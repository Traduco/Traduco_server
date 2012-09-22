class ApplicationController < ActionController::Base
    protect_from_forgery
    helper_method :current_user

    def check_auth
        if !current_user
            redirect_to login_path, :notice => {
                :type => :error,
                :title => "Forbidden!",
                :message => "You can't access this area without being authenticated."
            }
        end
    end

    private

    def current_user
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end
end
