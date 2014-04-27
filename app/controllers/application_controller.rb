class ApplicationController < ActionController::Base
    protect_from_forgery

    # Helper methods
    helper_method :current_user
    helper_method :is_site_admin
    helper_method :is_project_admin
    helper_method :is_translator

    def check_auth
        if !current_user
            redirect_to :root, :status => 401
            return false
        end
    end

    def check_site_admin
        restricted_redirect_to(root_url) if !is_site_admin
    end

    def check_project_admin
        redirect_to_project if !is_project_admin
    end

    def check_translator
        restricted_redirect_to(root_url) if !is_translator
    end

    def current_user
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end

    def is_site_admin
        @is_site_admin ||= current_user.is_site_admin
    end

    def is_project_admin
        @is_project_admin = true
        # @is_project_admin ||= (@project && (@project.users.map { |user| user.id }).include?(@current_user.id)) || is_site_admin
    end

    def is_translator
        @is_translator ||= (@translation && @translation.users.map { |user| user.id }.include?(@current_user.id)) || 
            (@translations && @project && !@translations.empty?) ||
            is_project_admin
    end

    protected

    def redirect_to_project
        restricted_redirect_to @project ? @project : root_url
    end

    def restricted_redirect_to (path)
        redirect_to path, :notice => {
            :type => :error,
            :title => "Forbidden!",
            :message => "You can't access this area."
        }
    end
end
