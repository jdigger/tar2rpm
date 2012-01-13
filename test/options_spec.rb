require_relative '../lib/tar2rpm/options'

describe Tar2Rpm do

  describe "when creation options" do

    it "should error if there is not a file" do
      ->{Tar2Rpm::Options.new(['-v', '-s', 'a summary'], true)}.should raise_error
    end
    
    it "should error if there is more than one file" do
      ->{Tar2Rpm::Options.new(['-v', '-s', 'a summary', 'file1', 'file2'], true)}.should raise_error
    end
    
    it "should error if there is more dthan one file" do
      options = Tar2Rpm::Options.new(['file1'], true)
    end
    
  end

end
