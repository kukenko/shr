#command utf-8
require 'spec_helper'

module Shr
  describe Command do
    let(:cmd) { Command.new(:ls, [:l, :t, :r]) }

    it 'has the following methods' do
      m = cmd.methods
      m.should include(:to_s)
      m.should include(:exist?)
      m.should include(:directly?)
      m.should include(:to_proc)
    end

    describe '#to_s' do
      it 'returns the command and parsed options' do
        cmd.to_s.should eq('ls -l -t -r') unless OS.windows?
        cmd.to_s.should eq('ls /l /t /r') if OS.windows?
      end
    end

    describe '#exist?' do
      it "returns the command's existence" do
        Command.new(:echo).exist?.should be_true
        Command.new(:ohce).exist?.should be_false
      end
    end

    describe '#directly?' do
      context "when passed command without '!'" do
        it { Command.new(:ls!).directly?.should be_true }
      end

      context "when passed command with '!'" do
        it { Command.new(:ls).directly?.should be_false }
      end
    end

    describe '#command' do
      it 'returns the command name that passed in initializing' do
        cmd.send(:command).should eq('ls')
      end

      context "when passed command end with '!'" do
        it "returns the command name without '!'" do
          Command.new(:ls!).send(:command).should eq('ls')
        end
      end
    end
  end
end
