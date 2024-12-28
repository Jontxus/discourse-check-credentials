# name: discourse-check-credentials
# about: Plugin para validar credenciales de usuario mediante un endpoint personalizado
# version: 0.1
# authors: "Jon"
# url: https://github.com/Jontxus/discourse-check-credentials

# plugin.rb
Rails.logger.info(">>> Entrando a plugin.rb de discourse-check-credentials <<<")
enabled_site_setting :check_credentials_enabled

after_initialize do
  Rails.logger.info(">>> after_initialize del plugin discourse-check-credentials <<<")

  load File.expand_path('../lib/discourse_check_credentials/engine.rb', __FILE__)
end
