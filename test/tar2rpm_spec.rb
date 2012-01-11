require_relative '../tar2rpm'
require 'tmpdir'

describe "TAR 2 RPM" do

  it "should extract the tar to the SOURCES directory" do
    tr = Tar2Rpm.new
    tarfile = "#{File.dirname(__FILE__)}/simple.tar"
    tr.tar_content_filenames(tarfile).should == "file1.txt\nfile2.txt\n"

    with_tmpdir do |tmpdir|
      tr.extract_tar(tarfile, tmpdir)
      file_entries = Dir.entries(tmpdir).grep(/^[^.]/)
      file_entries.should include('file1.txt')
      file_entries.should include('file2.txt')
    end
  end
  

  it "should create a simple Spec file with the list of files in it"


  def with_tmpdir
    tmpdir = Dir.mktmpdir
    begin
      yield(tmpdir)
    ensure
      file_entries = Dir.entries(tmpdir).grep(/^[^.]/)
      file_entries.each {|x|
        file = "#{tmpdir}/#{x}"
        File.delete(file)
      }
      Dir.rmdir(tmpdir)
    end
  end

end
