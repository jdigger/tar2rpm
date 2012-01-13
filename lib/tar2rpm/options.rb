require 'optparse'
require_relative 'tar'

module Tar2Rpm

  class Options

    attr_reader :summary, :description, :architecture, :filename, :top_dir, :verbose

    
    def initialize(argv, suppress_exit=false)
      @architecture = 'noarch'
      @verbose = false
      @suppress_exit = suppress_exit
      parse(argv)
    end


    private
    
    def parse(argv)
      OptionParser.new do |opts|
        opts.banner = "Usage: tar2rpm [ options ] tarfile"

        opts.on("-s", "--summary msg", String, "Package Summary") do |sum|
          @summary = sum
        end

        opts.on("-d", "--descr msg", String, "Package Description") do |desc|
          @description = desc
        end

        opts.on("-a", "--arch val",  [:noarch, :x86_64, :i386], String, "Architecture") do |arch|
          @architecture = arch
        end

        opts.on("-t", "--topdir val",  String, "Where to put the files for building the RPM") do |td|
          @top_dir = td
        end

        opts.on("-v", "--verbose", "Verbose") do |v|
          @verbose = true
        end

        opts.on("-h", "--help", "Show this message") do
          puts opts
          exit
        end

        begin
          begin
            argv << "-h" if argv.empty?
            opts.parse!(argv)

            if argv.empty?
              raise "Must have at least one file.\n\n#{opts}"
            end

            @filename = argv.pop

            unless argv.empty?
              raise "Can only handle one file.\n\n#{opts}"
            end
          rescue OptionParser::ParseError => e
            raise "#{e.message}\n#{opts}"
          end
        rescue RuntimeError => e
          unless @suppress_exit then
            STDERR.puts e.message
            exit(-1)
          else
            raise e
          end
        end
      end
    end

  end

end
