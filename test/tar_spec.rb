require_relative '../lib/tar2rpm/tar'
require_relative 'FileHelpers.rb'
require 'tmpdir'
include FileUtils
include FileHelpers

describe Tar2Rpm do

  before(:each) do
    @tar = Tar2Rpm::Tar.new("#{TEST_DIR}/simple-3.4.tar.gz")
  end


  describe "when working with a TAR file" do

    expected_files = ["file1.txt", "file2.txt"]

    before(:each) do
      @tmpdir = Dir.mktmpdir
    end

    after(:each) do
      rm_rf(@tmpdir)
    end

    describe "doing validations" do

      it "should fail when passed a non-existant filename" do
        ->{Tar2Rpm::Tar.new("bogus.tar.gz")}.should raise_error(Tar2Rpm::Tar::FileNotFoundError)
      end


      it "should fail when passed a non-parsable filename" do
        ->{Tar2Rpm::Tar.new("#{TEST_DIR}/expected_simple.spec")}.should raise_error(Tar2Rpm::Tar::FilenameParsingError)
        ->{Tar2Rpm::Tar.new("#{TEST_DIR}/parsefile.tgz")}.should raise_error(Tar2Rpm::Tar::FilenameParsingError)
        ->{Tar2Rpm::Tar.new("#{TEST_DIR}/parsefile-abc.tgz")}.should raise_error(Tar2Rpm::Tar::FilenameParsingError)
      end

      it "should extract the basename and version" do
        tar = Tar2Rpm::Tar.new("#{TEST_DIR}/simple-3.4.tar.gz")
        tar.basename.should == 'simple'
        tar.version.should == '3.4'
      end

    end


    it "should read the file names in the tar" do
      @tar.tar_content_filenames.should == expected_files
    end

    it "should extract the tar to a directory" do
      @tar.extract_tar(@tmpdir)
      dir_files(@tmpdir).should == expected_files
    end

  end

end
