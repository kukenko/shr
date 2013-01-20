#command utf-8
require 'spec_helper'

module Shr
  describe Command do
    let(:cmd) { Command.new(:ls, [:l, :t, :r]) }

    it 'has the following methods' do
      m = cmd.methods
      m.should include(:command)
      m.should include(:to_s)
      m.should include(:exist?)
      m.should include(:release?)
      m.should include(:run)
    end

    describe '#command' do
      it 'returns the command name that passed in initializing' do
        cmd.command.should eq('ls')
      end

      context "when passed command end with '!'" do
        it "returns the command name without '!'" do
          Command.new(:ls!).command.should eq('ls')
        end
      end
    end

    describe '#to_s' do
      it 'returns the command and parsed options' do
        cmd.to_s.should eq('ls -l -t -r')
      end
    end

    describe '#exist?' do
      it "returns the command's existence" do
        Command.new(:echo).exist?.should be_true
        Command.new(:ohce).exist?.should be_false
      end
    end

    describe '#release?' do
      context "when passed command without '!'" do
        it { Command.new(:ls!).release?.should be_true }
      end

      context "when passed command with '!'" do
        it { Command.new(:ls).release?.should be_false }
      end
    end
  end
end
