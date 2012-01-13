require_relative '../tar2rpm'
require 'tmpdir'
include FileUtils

describe Tar2Rpm do
  TEST_DIR = File.dirname(__FILE__)

  before(:each) do
    @tar = Tar2Rpm::Tar.new("#{TEST_DIR}/simple-3.4.tar.gz")
    @rpm_metadata = build_rpm = {summary: "A simple example", description: "A simple description.", tar: @tar, arch: 'noarch'}
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


  describe "when working with a Spec file" do

    before(:each) do
      @rpm_metadata[:top_dir] = Dir.mktmpdir
      @build_rpm = Tar2Rpm::BuildRpm.new(@rpm_metadata)
    end

    after(:each) do
      rm_rf(@build_rpm.top_dir)
    end


    it "should create a simple Spec file with the list of files in it" do
      @build_rpm.create_spec_file("#{@build_rpm.top_dir}/test.spec")

      compare_files("#{@build_rpm.top_dir}/test.spec", "#{TEST_DIR}/expected_simple.spec")
    end

  end


  describe "when creating RPM build" do
    
    describe "with missing meta-data" do
      md = {}
      
      before(:each) do
        md = @rpm_metadata
        md[:top_dir] = '/tmp/tar2rpm'
      end

      it "should catch missing top_dir" do
        md.delete(:top_dir)
        ->{Tar2Rpm::BuildRpm.new(md)}.should raise_error(ArgumentError, /top_dir/)
      end
    
      it "should catch missing tar" do
        md.delete(:tar)
        ->{Tar2Rpm::BuildRpm.new(md)}.should raise_error(ArgumentError, /tar/)
      end
    
      it "should catch tar of wrong type" do
        md[:tar] = ''
        ->{Tar2Rpm::BuildRpm.new(md)}.should raise_error(ArgumentError, /Tar2Rpm::Tar/)
      end

      it "should default the name based on the file name" do
        md.delete(:name)
        Tar2Rpm::BuildRpm.new(md).name.should == 'simple'
      end

      it "should default the version based on the file name" do
        md.delete(:version)
        Tar2Rpm::BuildRpm.new(md).version.should == '3.4'
      end

      it "should default the architecture" do
        md.delete(:arch)
        Tar2Rpm::BuildRpm.new(md).arch.should == 'noarch'
      end

      it "should default the prefix" do
        md.delete(:prefix)
        Tar2Rpm::BuildRpm.new(md).prefix.should == '/opt'
      end
    end
    
    it "should create the Spec and copy the tar" do
      @rpm_metadata[:top_dir] = "/tmp/tar2rpm"
      build_rpm = Tar2Rpm::BuildRpm.new(@rpm_metadata)
      build_rpm.create_build()

      dir_files(@rpm_metadata[:top_dir]).should == ["BUILD", "RPMS", "SOURCES", "SPECS", "SRPMS"]
      File.exist?("#{@rpm_metadata[:top_dir]}/SPECS/simple.spec").should be_true
      File.exist?("#{@rpm_metadata[:top_dir]}/SOURCES/simple-3.4.tar.gz").should be_true
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
