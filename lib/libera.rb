require "libera/version"
require 'rmagick'
require 'rtesseract'
require 'pdf-reader'
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
  
  class Parser
    def convert_pdf
      file_list = []
      reader = PDF::Reader.new(Libera.configuration.pdf_location)
      page_count = reader.page_count - 1
      
      for i in 0..page_count
        begin
          pdf = Magick::ImageList.new(Libera.configuration.pdf_location + "[#{i}]") {self.density = 300; self.quality = 100}
          page_img = pdf.first
          file_path = "#{Libera.configuration.tmp_dir}/images/#{Time.now.to_f.to_s.gsub!('.','-')}-pdf-page-#{i}.tiff"
          file_list << file_path
          page_img.write(file_path) {self.depth = 8}
        ensure
          pdf.destroy! && page_img.destroy!
        end
      end
      
      parse_image(file_list)
    end
    
    def parse_image(image_paths)
      image_paths.each_with_index do |img_path, i|
        begin
          file_path = "#{Libera.configuration.tmp_dir}/text/#{Time.now.to_f.to_s.gsub!('.','-')}-pdf-page-#{i}.txt"
          
          img = RTesseract.new(img_path)
          txt = img.to_s # Getting the value
          
          File.open(file_path, 'w') { |file| file.write(txt) }
        ensure
          img.destroy!
        end
      end
    end
    
    def generate_tei(page_list = Hash.new)
      # TODO
    end
  end
  
end
