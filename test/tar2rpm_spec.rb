require_relative '../tar2rpm'
require 'tmpdir'

describe "TAR 2 RPM", "basic extraction" do
  it "should extract the tar to the SOURCES directory" do
    tr = Tar2Rpm.new
    tr.tar_content_filenames("#{File.dirname(__FILE__)}/simple.tar").should == "file1.txt\nfile2.txt\n"

    tmpdir = Dir.mktmpdir
    tr.extract_tar("#{File.dirname(__FILE__)}/simple.tar", tmpdir)
    file_entries = Dir.entries(tmpdir).grep(/^[^.]/)
    file_entries.should == ['file1.txt', 'file2.txt']
    file_entries.each {|x|
      file = "#{tmpdir}/#{x}"
      File.delete(file)
    }
    Dir.rmdir(tmpdir)
  end

  it "should create a simple Spec file with the list of files in it"
end
