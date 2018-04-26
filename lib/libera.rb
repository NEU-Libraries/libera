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

    # Default configuration values
    def initialize
      @working_dir = "." # Default value
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
          pdf = Magick::ImageList.new(Libera.configuration.pdf_location + "[#{i}]") {self.density = 300; self.quality = 100}
          page_img = pdf.first
          
          page_img.border!(0, 0, 'white')
          page_img.alpha(Magick::DeactivateAlphaChannel)
          
          file_path = "#{Libera.configuration.working_dir}/images/#{Time.now.to_f.to_s.gsub!('.','')}-pdf-page-#{i}.png"
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
      
      x = File.read(file_path)
      txt = x.split("\n").reject { |c| c.empty? }
      return txt
    end
    
    def generate_tei(page_list)
      tei_path = "#{Libera.configuration.working_dir}/tei"
      tei_xml = Libera::Tei.new
      
      page_list.each do |k, v|
        tei_xml.template_registry.add_child(tei_xml.ng_xml.root.elements[1], :page_break, k)
        v.each_with_index do |str, index|
          if index == 0
            # tei_xml.template_registry.add_child(tei_xml.ng_xml.root.elements[1], :paragraph, str)
          end
          # tei_xml.template_registry.add_child(tei_xml.ng_xml.root.elements[1], :paragraph, str)
        end
      end
    end
    
    def mk_tmp_dirs
      # Check if dirs exist - If not, make them
      FileUtils.mkdir("#{Libera.configuration.working_dir}/images") unless File.exists? "#{Libera.configuration.working_dir}/images"
      FileUtils.mkdir("#{Libera.configuration.working_dir}/text") unless File.exists? "#{Libera.configuration.working_dir}/text"
      FileUtils.mkdir("#{Libera.configuration.working_dir}/tei") unless File.exists? "#{Libera.configuration.working_dir}/tei"
    end
  end
  
end
