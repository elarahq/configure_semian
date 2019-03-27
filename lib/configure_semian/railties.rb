module ConfigureSemian
  class Railties < ::Rails::Railtie
    initializer 'Rails logger' do
      ConfigureSemian.logger = Rails.logger
    end
  end
end