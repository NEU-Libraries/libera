require 'om'

module Libera
  class Tei
    include OM::XML::Document
    
    set_terminology do |t|
      t.root(:path => 'tei', :xmlns => 'http://www.tei-c.org/ns/1.0', :namespace_prefix => nil)
      t.text(path: 'text'){
        t.page_break(path: 'pb')
        t.paragraph(path: 'p')  
      }
    end
    
    define_template :page_break do |xml, img_src|
      xml.pb(:facs => img_src)
    end
    
    define_template :paragraph do |xml, p_text|
      xml.p_ do
        xml.text(p_text)
      end
    end
    
    def self.xml_template
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.tei("xmlns"=>"http://www.tei-c.org/ns/1.0") {
          xml.teiHeader
          xml.text_
        }
      end
        
      return builder.doc
    end
    
    private
    
      def add_page_break(page_img)
        self.template_registry.add_child(x.find_by_terms(:text => 0), :page_break, page_img)
      end
      
      def add_paragraph(text)
        if self.find_by_terms(:text, :page_break).blank?
          # Raise error, page break required
          raise "Page Break not found, unable to add paragraph"
        elsif self.find_by_terms(:text, :page_break).count == 1
          self.template_registry.add_next_sibling(x.find_by_terms(:text, :page_break => 0).first, :paragraph, text)
        else
          self.template_registry.add_next_sibling(x.find_by_terms(:text, :paragraph).last, :paragraph, text)
        end
      end
  end
end