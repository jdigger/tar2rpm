require_relative '../tar2rpm'
require 'tmpdir'

describe Tar2Rpm do
  
  before(:each) do
    @tar2rpm = Tar2Rpm.new
    @tarfile = "#{File.dirname(__FILE__)}/simple.tar"
  end


  around(:each) do |example|
    with_tmpdir do |tmpdir|
      @tmpdir = tmpdir
      example.run
    end
  end


  it "should extract the tar to a directory" do
    @tar2rpm.tar_content_filenames(@tarfile).should == "file1.txt\nfile2.txt\n"

    @tar2rpm.extract_tar(@tarfile, @tmpdir)
    file_entries = dir_files(@tmpdir)
    file_entries.should include('file1.txt')
    file_entries.should include('file2.txt')
  end
  

  it "should create a simple Spec file with the list of files in it"

end


def dir_files(dir)
  Dir.entries(dir).grep(/^[^.]/)
end


def with_tmpdir
  tmpdir = Dir.mktmpdir
  begin
    yield(tmpdir)
  ensure
    rmdir_force(tmpdir)
  end
end


def rmdir_force(dir)
  file_entries = dir_files(dir)
  file_entries.each {|x|
    file = "#{dir}/#{x}"
    File.delete(file)
  }
  Dir.rmdir(dir)
end
