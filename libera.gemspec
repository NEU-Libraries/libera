lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "libera/version"

Gem::Specification.new do |spec|
  spec.name          = "libera"
  spec.version       = Libera::VERSION
  spec.authors       = ["David Cliff"]
  spec.email         = ["dgcliff@northeastern.edu"]

  spec.summary       = %q{A utility gem for processing PDFs for OCR and TEI}
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/NEU-Libraries/libera"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  # spec.bindir        = "exe"
  # spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }

  spec.executables   = ["libera"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10"
  spec.add_development_dependency "rspec", "~> 3"

  spec.add_dependency "rtesseract", "~> 2.2"
  spec.add_dependency "rmagick", "~> 2.16"
  spec.add_dependency "nokogiri", "~> 1.8"
  spec.add_dependency "pdf-reader", "~> 2.1"
  spec.add_dependency "om", "~> 3.1"
  spec.add_dependency "fileutils", "~> 1"
  spec.add_dependency "ruby-progressbar", "~> 1.9"
end
