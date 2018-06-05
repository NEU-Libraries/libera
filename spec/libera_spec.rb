RSpec.describe Libera do
  it "has a version number" do
    expect(Libera::VERSION).not_to be nil
  end

  it "produces a valid default XML template" do
    tei_xml = Libera::Tei.new
    expect(tei_xml.to_xml).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"\
      "<TEI xmlns=\"http://www.tei-c.org/ns/1.0\">\n  <teiHeader>"\
      "\n    <fileDesc>\n      <titleStmt>\n        <title/>\n   "\
      "   </titleStmt>\n      <publicationStmt>\n        <p/>\n  "\
      "    </publicationStmt>\n      <sourceDesc>\n        <p/>\n"\
      "      </sourceDesc>\n    </fileDesc>\n  </teiHeader>\n"\
      "  <text>\n    <body>\n      <ab/>\n    </body>\n  </text>\n</TEI>\n")
  end
  
  it "adds page breaks" do
    
  end
  
  it "adds anon blocks" do
    
  end
  
  it "generates TEI" do
    
  end
  
  it "parses images and makes OCR text" do
    
  end
end
