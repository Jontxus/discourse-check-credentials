# name: discourse-check-credentials
# about: Plugin para validar credenciales de usuario mediante un endpoint personalizado
# version: 0.1
# authors: "Jon"
# url: https://github.com/Jontxus/discourse-check-credentials

enabled_site_setting :check_credentials_enabled

after_initialize do
  load File.expand_path('../lib/discourse-check-credentials/engine.rb', __FILE__)
end
