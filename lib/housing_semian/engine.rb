module HousingSemian
  class Engine < ::Rails::Engine
    config.autoload_paths += %W(#{config.root}/lib/housing_semian/net_http.rb)
  end
end