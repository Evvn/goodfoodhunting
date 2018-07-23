# app_console is just a pry session with your data models loaded

require "pry"
require_relative "db_config"
require_relative "models/dish"
require_relative "models/comment"
require_relative "models/user"

binding.pry
