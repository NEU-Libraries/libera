require 'om'

module Libera
  class Tei
    include OM::XML::Document
    
    set_terminology do |t|
      t.root(:path => "TEI", :xmlns => '', :namespace_prefix => nil)
    end
    
    def self.xml_template
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.tei("xmlns"=>"http://www.tei-c.org/ns/1.0") {
          xml.teiHeader{
            
          }
          xml.text_{
            xml.pb('facs' => '')
            xml.p_
          }
        }
      end  
      return builder.doc
    end
  end
end