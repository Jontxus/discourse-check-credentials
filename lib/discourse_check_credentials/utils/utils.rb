# lib/discourse_check_credentials/utils.rb
require 'openssl'
require 'base64'

module DiscourseCheckCredentials
  module Utils
    def self.verify_password(stored_hash, salt, provided_password)
      scheme, iterations, params, stored_hash_value = stored_hash.split('$')
      iterations = iterations.split('=')[1].to_i
      hash_length = params.split('=')[1].to_i

      salt = Base64.decode64(salt)
      stored_hash_value = Base64.decode64(stored_hash_value)

      derived_key = OpenSSL::KDF.pbkdf2_hmac(
        provided_password,
        salt: salt,
        iterations: iterations,
        length: hash_length,
        hash: 'sha256'
      )

      ActiveSupport::SecurityUtils.secure_compare(derived_key, stored_hash_value)
    end
  end
end
