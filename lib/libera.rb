require "libera/version"
require 'RMagick'
require 'tmpdir'

include Magick

module Libera
  
  class << self
    # Simple attribute for configuration
    attr_accessor :configuration
  end
  
  # Allows for configuration by block
  #
  # Example:
  #  MegaLotto.configure do |config|
  #   config.drawing_count = 10
  #  end

  def self.configure
    yield(configuration) if block_given?
  end
  
  def self.configuration
    @configuration ||=  Configuration.new
  end

  # Undoes any configuration - this method was built for testing purposes
  #
  # Example:
  #   Kataba.reset

  def self.reset
    @configuration = Configuration.new
  end

  class Configuration
    # Example:
    #   Libera.configuration.example = "..."
    # attr_accessor :example_value
    
    attr_accessor :pdf_location
    attr_accessor :output_location
    attr_accessor :tmp_dir

    # Default configuration values
    def initialize
      @tmp_dir = "#{Dir.tmpdir}/libera" # Default value
    end
  end
  
  class Chatter
    def say_hello
      puts 'This is libera. Coming in loud and clear. Over.'
    end
  end
  
  
end
