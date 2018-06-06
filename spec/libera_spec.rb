RSpec.describe Libera do
  
  before(:each) do
    @tei_xml = Libera::Tei.new
    @parser = Libera::Parser.new
    @parser.mk_working_dir
  end
  
  after(:each) do
    FileUtils.rm_rf(Libera.configuration.working_dir)
  end
  
  it "has a version number" do
    expect(Libera::VERSION).not_to be nil
  end

  it "produces a valid default XML template" do
    expect(@tei_xml.to_xml).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"\
      "<TEI xmlns=\"http://www.tei-c.org/ns/1.0\">\n  <teiHeader>"\
      "\n    <fileDesc>\n      <titleStmt>\n        <title/>\n   "\
      "   </titleStmt>\n      <publicationStmt>\n        <p/>\n  "\
      "    </publicationStmt>\n      <sourceDesc>\n        <p/>\n"\
      "      </sourceDesc>\n    </fileDesc>\n  </teiHeader>\n"\
      "  <text>\n    <body>\n      <ab/>\n    </body>\n  </text>\n</TEI>\n")
  end
  
  it "adds page breaks" do
    @tei_xml.add_page_break("foo")
    
    expect(@tei_xml.to_xml).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"\
      "\n<TEI xmlns=\"http://www.tei-c.org/ns/1.0\">\n  <teiHeader>\n    "\
      "<fileDesc>\n      <titleStmt>\n        <title/>\n      "\
      "</titleStmt>\n      <publicationStmt>\n        <p/>\n      "\
      "</publicationStmt>\n      <sourceDesc>\n        <p/>\n     "\
      " </sourceDesc>\n    </fileDesc>\n  </teiHeader>\n  <text>\n"\
      "    <body>\n      <pb facs=\"foo\"/>\n    </body>\n  </text>\n</TEI>\n")
  end
  
  it "adds anon blocks" do
    @tei_xml.add_page_break("foo")
    @tei_xml.add_anon_block("bar")
    
    expect(@tei_xml.to_xml).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"\
      "<TEI xmlns=\"http://www.tei-c.org/ns/1.0\">\n  <teiHeader>\n    "\
      "<fileDesc>\n      <titleStmt>\n        <title/>\n      </titleStmt>\n"\
      "      <publicationStmt>\n        <p/>\n      </publicationStmt>\n    "\
      "  <sourceDesc>\n        <p/>\n      </sourceDesc>\n    </fileDesc>\n "\
      " </teiHeader>\n  <text>\n    <body>\n      <pb facs=\"foo\"/>\n      "\
      "<ab>bar</ab>\n    </body>\n  </text>\n</TEI>\n")
  end
  
  it "errors on adding anon blocks without a page break" do
    # tei_xml = Libera::Tei.new
    expect { @tei_xml.add_anon_block("bar") }.to raise_error(RuntimeError)
  end
  
  it "generates TEI" do
    @parser.mk_working_dir
    
    i = 0
    txt = @parser.parse_image("./test/fixtures/test.png", i)
    
    page_list = Hash.new
    file_name = "pdf-page-#{i}.#{Libera.configuration.format_type}"
    page_list[file_name] = txt
    
    @parser.generate_tei(page_list)
    
    tei_path = "#{Libera.configuration.working_dir}/tei.xml"
    
    xml_result = File.read(tei_path)
    
    expect(xml_result).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<TEI"\
      " xmlns=\"http://www.tei-c.org/ns/1.0\">\n  <teiHeader>\n    <fileDesc>\n"\
      "      <titleStmt>\n        <title/>\n      </titleStmt>\n      "\
      "<publicationStmt>\n        <p/>\n      </publicationStmt>\n    "\
      "  <sourceDesc>\n        <p/>\n      </sourceDesc>\n    </fileDesc>\n"\
      "  </teiHeader>\n  <text>\n    <body>\n      <pb facs=\"pdf-page-0.png\"/>\n"\
      "      <ab>I am all manner of test\ndocument.\n\nLorem ipsum lorem\nipsum"\
      " lorem ipsom.\n\nAsdfasdfasdf\nAsdfasdfasdf\n\n</ab>\n    </body>\n  </text>\n</TEI>\n")
  end
  
  it "parses images and makes OCR text" do
    @parser.mk_working_dir
    
    txt = @parser.parse_image("./test/fixtures/test.png", 0)
    
    expect(txt).to eq("I am all manner of test\ndocument.\n\nLorem ipsum lorem\n"\
      "ipsum lorem ipsom.\n\nAsdfasdfasdf\nAsdfasdfasdf\n\n")
  end
end
