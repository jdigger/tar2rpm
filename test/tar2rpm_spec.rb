require_relative '../tar2rpm'
require 'tmpdir'
include FileUtils

describe Tar2Rpm do
  
  before(:each) do
    @tar2rpm = Tar2Rpm.new
  end


  around(:each) do |example|
    @tmpdir = Dir.mktmpdir
    begin
      example.run
    ensure
      rm_rf(@tmpdir)
    end
  end


  describe "working with a TAR file" do
  
    before(:each) do
      @tarfile = "#{File.dirname(__FILE__)}/simple.tar"
    end

    it "should read the file names in the tar" do
      @tar2rpm.tar_content_filenames(@tarfile).should == "file1.txt\nfile2.txt\n"
    end

    it "should extract the tar to a directory" do
      @tar2rpm.extract_tar(@tarfile, @tmpdir)
      file_entries = dir_files(@tmpdir)
      file_entries.should include('file1.txt')
      file_entries.should include('file2.txt')
    end

  end  


  describe "working with a Spec file" do

    it "should create a simple Spec file with the list of files in it" do
      File.open("#{@tmpdir}/test.spec", 'w') do |file|
        @tar2rpm.create_spec_file(file, :name => 'simple', :version => '3.4', :summary => "A simple example", :tar_filename => "simple.tar", :arch => 'x86_64')
      end
      
      compare_files("#{@tmpdir}/test.spec", "#{File.dirname(__FILE__)}/expected_simple.spec")
    end

  end

end


def dir_files(dir)
  Dir.entries(dir).grep(/^[^.]/)
end


def compare_files(file1name, file2name)
  str1 = IO.read(file1name)
  str2 = IO.read(file2name)
  str1.should == str2
end
