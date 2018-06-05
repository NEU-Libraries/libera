require 'om'

module Libera
  class Tei
    include OM::XML::Document
    
    set_terminology do |t|
      t.root(:path => 'tei', :xmlns => 'http://www.tei-c.org/ns/1.0', :namespace_prefix => nil)
      t.text(path: 'text'){
        t.body(path: 'body'){
          t.page_break(path: 'pb')
          t.anon_block(path: 'ab')  
        }  
      }
    end
    
    define_template :page_break do |xml, img_src|
      xml.pb(:facs => img_src)
    end
    
    define_template :anon_block do |xml, ab_text|
      xml.ab do
        xml.text(ab_text)
      end
    end
    
    def self.xml_template
      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.TEI("xmlns"=>"http://www.tei-c.org/ns/1.0") {
          xml.teiHeader{
            xml.fileDesc{
              xml.titleStmt{
                xml.title
              }
              xml.publicationStmt{
                xml.p_
              }
              xml.sourceDesc{
                xml.p_
              }
            }
          }
          xml.text_{
            xml.body{
              xml.ab
            }
          }
        }
      end
        
      return builder.doc
    end
    
    def add_page_break(page_img)
      # any anon breaks?
      ab_count = self.find_by_terms(:text, :body, :anon_block).count
      
      if ab_count == 1 && self.find_by_terms(:text, :body, :anon_block).first.text.blank?
        self.find_by_terms(:text, :body, :anon_block).first.remove
        ab_count = 0
      end
      
      if !(ab_count > 0)
        # if not add to child of body
        self.template_registry.add_child(self.find_by_terms(:text, :body => 0), :page_break, page_img)
      else
        # else add as sibling
        self.template_registry.add_next_sibling(self.find_by_terms(:text, :body, :anon_block).last, :page_break, page_img)
      end
    end
    
    def add_anon_block(text)
      if self.find_by_terms(:text, :body, :page_break).blank?
        # Raise error, page break required
        raise "Page Break not found, unable to add anon block"
      end
      
      if self.find_by_terms(:text, :body, :page_break).count == 1
        self.template_registry.add_next_sibling(self.find_by_terms(:text, :body, :page_break => 0).first, :anon_block, text)
      else
        self.template_registry.add_next_sibling(self.find_by_terms(:text, :body, :page_break).last, :anon_block, text)
      end
    end
  end
end