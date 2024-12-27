# lib/discourse-check-credentials/controllers/check_credentials_controller.rb
module ::DiscourseCheckCredentials
    class CheckCredentialsController < ::ApplicationController
      #
      # OJO: Lo normal es que Discourse exija autenticación para cualquier endpoint POST,
      # y también protege con CSRF. Si queremos exponer un endpoint "libre",
      # hay que desactivar ciertas protecciones, pero con MUCHO CUIDADO.
      #
      skip_before_action :check_xhr
      skip_before_action :verify_authenticity_token
  
      # Opcional: una forma sencilla de requerir una "API key" propia
      before_action :ensure_valid_api_key
  
      def index
        return render(json: { error: 'Plugin deshabilitado' }, status: 403) unless SiteSetting.check_credentials_enabled
  
        username = params[:username]
        password = params[:password]
  
        if username.blank? || password.blank?
          return render(json: { valid: false, error: "Missing username or password" }, status: 400)
        end
  
        user = User.find_by_username_or_email(username)
  
        if user && user.valid_password?(password)
          # Opcional: devuelves algo más de info. ¡Cuidado con no exponer datos sensibles!
          render json: {
            valid: true,
            user_id: user.id,
            username: user.username,
            email: user.email,
          }
        else
          render json: { valid: false }, status: 401
        end
      end
  
      private
  
      def ensure_valid_api_key
        # Aquí implementas tu propia lógica de seguridad para el endpoint.
        # Por ejemplo, exigir un header X-Plugin-Token
        token = request.headers["X-Plugin-Token"]
        expected = SiteSetting.check_credentials_api_key.presence
  
        # Si no configuraste nada o no coincide, error 403
        if expected.blank? || token != expected
          render(json: { error: "Invalid API key" }, status: 403)
        end
      end
    end
  end
  