# lib/discourse-check-credentials/engine.rb

module ::DiscourseCheckCredentials
    class Engine < ::Rails::Engine
      engine_name "discourse_check_credentials"
      isolate_namespace DiscourseCheckCredentials
    end
  end
  
  Discourse::Application.routes.append do
    # Montamos el engine en una URL
    mount ::DiscourseCheckCredentials::Engine, at: "/check_credentials"
  end
  
  DiscourseCheckCredentials::Engine.routes.draw do
    post "/" => "check_credentials#index"
  end
  