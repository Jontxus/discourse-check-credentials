# lib/discourse_check_credentials/engine.rb

Rails.logger.info("=== Cargando engine: DiscourseCheckCredentials ===")

module DiscourseCheckCredentials
  class Engine < ::Rails::Engine
    engine_name "discourse_check_credentials"
    isolate_namespace DiscourseCheckCredentials
  end
end

Discourse::Application.routes.append do
  mount ::DiscourseCheckCredentials::Engine, at: "/check_credentials"
end

DiscourseCheckCredentials::Engine.routes.draw do
  post "/" => "check_credentials#index"
end
