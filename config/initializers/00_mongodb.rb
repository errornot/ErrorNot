db_config = YAML::load(File.read("#{Rails.root}/config/database.yml"))

if db_config[Rails.env] && db_config[Rails.env]['adapter'] == 'mongodb'
  mongo = db_config[Rails.env]
  MongoMapper.setup(db_config, Rails.env, :logger => Rails.logger)
end
