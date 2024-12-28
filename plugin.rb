# name: discourse-check-credentials
# about: Plugin para validar credenciales de usuario mediante un endpoint personalizado
# version: 0.1
# authors: "Jon"
# url: https://github.com/Jontxus/discourse-check-credentials

# plugin.rb

require_relative 'lib/discourse_check_credentials/utils'

after_initialize do
  Dir.glob(File.expand_path('../lib/discourse_check_credentials/**/*.rb', __FILE__)).each do |file|
    require file unless file.include?('utils.rb')
  end

end
