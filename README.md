# Libera

Libera is a gem built for Charon - https://github.com/NEU-Libraries/charon - a digital humanities focused Samvera head.

It's purpose is to take PDF files as input, and split them apart into individual page images for OCR and TEI generation.

## Docker

Whilst there are installation instructions below for work as a developer, often times there are significant environmental challenges to software setup. To that end, Libera can  be run in Docker. Install Docker as instructed here - https://docs.docker.com/install/

Then pull down the libera container image;

    docker pull nakatomi/libera

To share the PDF with the application, you'll need to bind mount a directory to the container. If you run into permission errors or an empty directory issue, you'll need to consult the variances that can occur based on host operating system - https://docs.docker.com/storage/bind-mounts/

An example of how to run the container, use a bind mount, and instruct libera is below

    docker run -ti --mount type=bind,source=/c/Libera,target=/home/libera/work_dir nakatomi/libera libera -p /home/libera/work_dir/dsg.pdf -w /home/libera/work_dir

In the above example, the mounted host directory ```/c/Libera``` becomes ```/home/libera/work_dir``` inside the container. In this use case, we use the same directory to deliver the PDF ```dsg.pdf``` as well as use it for where the produced artifacts are then made.

The last section of the above is the same as if you'd run Libera in your home operating system

    libera -p /home/libera/work_dir/dsg.pdf -w /home/libera/work_dir

## Installation

There are some programs that are required for Libera to work;

* Tesseract - https://github.com/tesseract-ocr/tesseract
* ImageMagick - https://www.imagemagick.org

Tesseract 3.03 and ImageMagick 6.7.7-10 were the versions used in the development of this gem.

Both should be available through package managers such as APT, Yum, Homebrew etc.

Add this line to your application's Gemfile:

```ruby
gem 'libera'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install libera

## Usage

To use this gem at the command-line:

```
libera -p ./input.pdf
```

There are several adjustable parameters;

* -p | --pdf_location (no default)
* -w | --working_directory (default is a unique directory made in the directory you run libera)
* -d | --density (default is 300)
* -q | --quality (default is 100)
* -f | --format_type (default is PNG)
* -h | --help

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/NEU-Libraries/libera.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
