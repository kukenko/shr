#coding: utf-8
require 'spec_helper'
require 'tempfile'

module Shr
  describe Builtin do
    let(:sh) { Shell.new }

    it 'has the following methods' do
      m = sh.methods
      m.should include(:capture)
    end

    describe '#capture' do
      it 'captures output from block' do
        sh.capture { print 'hello capture' }.to_s.should eq("hello capture")
      end

      it 'redirects output from block to file' do
        tempfile = Tempfile.new('temp')
        sh.capture { print 'hello capture'}.redirect_to(tempfile.path)
        sh.cat.redirect_from(tempfile.path).to_s.should eq('hello capture')
        tempfile.close!
      end
    end

    describe '#cd' do
      it 'changes the current working directory'
    end
  end
end
