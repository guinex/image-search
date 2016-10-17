module ReadonlyConnection
  def self.connect
    ActiveRecord::Base.establish_connection(
      adapter:  "postgresql",
      host:     ENV['READONLY_HOST'],
      port:     ENV['READONLY_PORT'],
      username: ENV['READONLY_USERNAME'],
      password: ENV['READONLY_PASSWORD'],
      database: ENV['READONLY_DB']
    ).connection
  end

  def self.reset_connection
    config = ActiveRecord::Base.configurations[Rails.env] ||
            Rails.application.config.database_configuration[Rails.env]
    ActiveRecord::Base.establish_connection(config)
  end
end