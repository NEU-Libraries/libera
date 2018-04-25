require 'om'

module Libera
  class Tei
    include OM::XML::Document
    
    set_terminology do |t|
      t.root(:path => "TEI", :xmlns => 'http://www.tei-c.org/ns/1.0', :namespace_prefix => nil)
      t.page_break(path: 'pb')
      t.paragraph(path: 'p')
    end
    
    define_template :page do |xml, img_src|
      xml.page_break(:facs => img_src) do
        xml.paragraph
      end
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