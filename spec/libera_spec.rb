RSpec.describe Libera do
  
  before(:each) do
    Libera.reset
    @tei_xml = Libera::Tei.new
    @parser = Libera::Parser.new
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
    FileUtils.rm_rf(Libera.configuration.working_dir)
    
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
    FileUtils.rm_rf(Libera.configuration.working_dir)
    
    expect(txt).to eq("I am all manner of test\ndocument.\n\nLorem ipsum lorem\n"\
      "ipsum lorem ipsom.\n\nAsdfasdfasdf\nAsdfasdfasdf\n\n")
  end
  
  it "sets PDF location" do
    # No default value expected
    expect(Libera.configuration.pdf_location).to be_nil
    
    Libera.configuration.pdf_location = "shmants"
    expect(Libera.configuration.pdf_location).to eq("shmants")
  end
  
  it "sets working directory" do
    # Default value expected
    expect(Libera.configuration.working_dir).to be
    
    Libera.configuration.working_dir = "pants"
    expect(Libera.configuration.working_dir).to eq("pants")
  end
  
  it "sets density" do
    # Default value expected
    expect(Libera.configuration.density).to eq(300)
    
    Libera.configuration.density = 999
    expect(Libera.configuration.density).to eq(999)
  end
  
  it "sets quality" do
    # Default value expected
    expect(Libera.configuration.quality).to eq(100)
    
    Libera.configuration.quality = 999
    expect(Libera.configuration.quality).to eq(999)
  end
  
  it "sets format type" do
    # Default value expected
    expect(Libera.configuration.format_type).to eq("png")
    
    Libera.configuration.density = "tif"
    expect(Libera.configuration.density).to eq("tif")
  end
  
  it "accepts external XML template" do
    @tei_xml = Libera::Tei.from_xml(File.read("./test/fixtures/template.xml"))
    
    expect(@tei_xml.to_xml).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<?xml-model href=\"http://paramedic.wwp.neu.edu/~syd/temp/BPTL/2018-05-02T09/lib1.rnc\" type=\"application/relax-ng-compact-syntax\"?>\n<?tapas keepFirst=3 ?>\n<TEI xmlns=\"http://www.tei-c.org/ns/1.0\">\n  <teiHeader xml:lang=\"??\"> <!-- the \"??\" should be the language code for this document -->\n    <fileDesc>\n      <titleStmt>\n        <title> <!-- title of TEI document goes here --> </title>\n      </titleStmt>\n      <publicationStmt>\n        <!-- use either <publisher> or <distributor> or both -->\n        <publisher>\n          <!-- name of publisher goes here, preferably in <orgName> or <persName> -->\n        </publisher>\n        <pubPlace> <!-- City of publication goes here, w/o <placeName> --> </pubPlace>\n        <address>\n\t  <!-- optional detailed addr of publisher -->\n\t  <addrLine/>\n\t  <addrLine/>\n\t</address>\n        <distributor>\n          <!-- name of distributor goes here, preferably in <orgName> or <persName> -->\n        </distributor>\n        <address>\n          <!-- optional detailed addr of distributor -->\n\t  <addrLine/>\n\t  <addrLine/>\n        </address>\n        <availability>\n          <licence><!-- Licensing info goes here --></licence>\n        </availability>\n      </publicationStmt>\n      <sourceDesc>\n        <biblStruct>\n          <monogr> <!-- ... --> </monogr>\n        </biblStruct>\n      </sourceDesc>\n    </fileDesc>\n    <encodingDesc>\n      <editorialDecl>\n        <hyphenation>\n          <p>All hyphens in source document encoded as U+002D.</p>\n        </hyphenation>\n      </editorialDecl>\n      <tagsDecl>\n        <namespace name=\"http://www.tei-c.org/ns/1.0\">\n          <tagUsage gi=\"sourceDoc\">Logical divisions not encoded.</tagUsage>\n        </namespace>\n      </tagsDecl>\n    </encodingDesc>\n  </teiHeader>\n  <sourceDoc>\n    <!-- one <surface> for each page with a URL that points to the page image on @facs -->\n    <surface facs=\"pageImages/Flatland-p010.pdf\">\n      <!-- each <surface> has one <line> element for each typographic line -->\n      <!-- a <surface> element may have @ulx, @uly, @lrx, @lry to indicate where it is on the surface -->\n      <line/>\n      <line/>\n      <line/>\n    </surface>\n    <surface facs=\"pageImages/Flatland-p011.pdf\"/>\n    <surface facs=\"pageImages/Flatland-p012.pdf\">\n      <line/>\n      <line/>\n      <line/>\n    </surface>\n  </sourceDoc>\n</TEI>\n")
  end
end
