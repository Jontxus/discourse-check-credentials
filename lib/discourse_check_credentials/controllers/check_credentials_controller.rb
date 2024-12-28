# lib/discourse_check_credentials/controllers/check_credentials_controller.rb
module ::DiscourseCheckCredentials
    class CheckCredentialsController < ::ApplicationController

        # skip_before_action :redirect_to_login_if_required, raise: false
        # skip_before_action :ensure_logged_in, raise: false
        # skip_before_action :enforce_login_if_required, raise: false

        skip_before_action :check_xhr
        skip_before_action :verify_authenticity_token
  
        before_action :ensure_valid_api_key
        before_action :limit_rate
        before_action :ensure_allowed_ip

        def index
    
            username = params[:username]
            password = params[:password]
    
            if username.blank? || password.blank?
                Rails.logger.warn("[CheckCredentials] IP=#{request.ip} intentó sin username o password")
                return render(json: { valid: false, error: "Missing username or password" }, status: 400)
            end
    
            user = User.find_by_username_or_email(username)
    
            if user && UserAuthenticator.new(user, nil).authenticate(password)
                Rails.logger.info("[CheckCredentials] IP=#{request.ip} username=#{username} -> OK")
        
                render json: {
                    valid: true,
                    user_id: user.id,
                    username: user.username,
                    email: user.email,
                }
            else
                Rails.logger.warn("[CheckCredentials] IP=#{request.ip} username=#{username} -> Credenciales inválidas")
                render json: { valid: false }, status: 401
            end
        end
    
        private
    
        def ensure_valid_api_key

            token = request.headers["X-Plugin-Token"]
            expected = SiteSetting.check_credentials_api_key.presence
    
            if expected.blank? || token != expected
                Rails.logger.warn("[CheckCredentials] IP=#{request.ip} token inválido='#{token}'")
                render(json: { error: "Invalid API key" }, status: 403)
            end
        end

        def limit_rate
            RateLimiter.new(
                nil,
                "check-credentials-ip-#{request.ip}",
                SiteSetting.check_credentials_max_rate,
                1.minute
            ).performed!
        rescue RateLimiter::LimitExceeded
            Rails.logger.warn("[CheckCredentials] IP=#{request.ip} superó el límite de peticiones")
            render(json: { error: "Too many requests" }, status: 429)
        end

        def ensure_allowed_ip
            allowed_ips = SiteSetting.check_credentials_allowed_ips.to_s
                                    .split(",")
                                    .map { |ip| ip.strip }
                                    .reject(&:blank?)
            remote_ip = request.ip  
            unless allowed_ips.include?(remote_ip)
                Rails.logger.warn("[CheckCredentials] IP=#{remote_ip} no está en la lista permitida -> 403")
                render(json: { error: "IP not allowed" }, status: 403) and return
            end
        end

    end
end
  