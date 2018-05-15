require 'libera/version'
require 'libera/tei'

require 'rmagick'
require 'rtesseract'
require 'pdf-reader'
require 'tmpdir'
require 'fileutils'

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
    attr_accessor :working_dir
    attr_accessor :density
    attr_accessor :quality
    attr_accessor :format_type

    # Default configuration values
    def initialize
      @working_dir =  "."   # Default value
      @density =      300   # Default value
      @quality =      100   # Default value
      @format_type =  "png" # Default value
    end
  end
  
  class Parser
    def convert_pdf
      mk_tmp_dirs
      
      file_list = []
      reader = PDF::Reader.new(Libera.configuration.pdf_location)
      page_count = reader.page_count - 1
      
      page_list = Hash.new
      
      for i in 0..page_count
        begin
          pdf = Magick::ImageList.new(Libera.configuration.pdf_location + "[#{i}]") {self.density = Libera.configuration.density; self.quality = Libera.configuration.quality}
          page_img = pdf.first
          
          page_img.border!(0, 0, 'white')
          page_img.alpha(Magick::DeactivateAlphaChannel)
          
          file_path = "#{Libera.configuration.working_dir}/images/#{Time.now.to_f.to_s.gsub!('.','')}-pdf-page-#{i}.#{Libera.configuration.format_type}"
          file_list << file_path
          page_img.write(file_path) {self.depth = 8}
          
          txt = parse_image(file_path, i)
          page_list[file_path] = txt
        ensure
          pdf.destroy! && page_img.destroy!
        end
      end
      
      generate_tei(page_list)
    end
    
    def parse_image(image_path, i)
      file_path = "#{Libera.configuration.working_dir}/text/#{Time.now.to_f.to_s.gsub!('.','')}-pdf-page-#{i}"
      `tesseract #{image_path} #{file_path} >> /dev/null 2>&1`
      return File.read(file_path + ".txt")
    end
    
    def generate_tei(page_list)
      tei_path = "#{Libera.configuration.working_dir}/tei/#{Time.now.to_f.to_s.gsub!('.','')}-output.xml"
      tei_xml = Libera::Tei.new
      
      page_list.each do |k, v|
        tei_xml.add_page_break(k)
        tei_xml.add_anon_block(v)
      end
      
      # write out xml to file
      IO.write(tei_path, tei_xml.to_xml)
    end
    
    def mk_tmp_dirs
      # Check if dirs exist - If not, make them
      FileUtils.mkdir("#{Libera.configuration.working_dir}/images") unless File.exists? "#{Libera.configuration.working_dir}/images"
      FileUtils.mkdir("#{Libera.configuration.working_dir}/text") unless File.exists? "#{Libera.configuration.working_dir}/text"
      FileUtils.mkdir("#{Libera.configuration.working_dir}/tei") unless File.exists? "#{Libera.configuration.working_dir}/tei"
    end
  end
  
end
