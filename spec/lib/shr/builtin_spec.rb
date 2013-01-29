#coding: utf-8
require 'spec_helper'
require 'tempfile'

module Shr
  describe Builtin do
    let(:sh) { Shell.new }

    before(:all) do
      @original = Dir.pwd
    end

    it 'has the following methods' do
      m = sh.methods
      m.should include(:capture)
      m.should include(:cd!)
    end

    describe '#capture' do
      it 'captures output from block' do
        sh.capture { print 'hello capture' }.to_s.should eq("hello capture")
      end

      it 'redirects output from block to file' do
        tempfile = Tempfile.new('temp')
        sh.capture { print 'hello capture' }.redirect_to(tempfile.path)
        File.read(tempfile.path).should eq('hello capture')
        tempfile.close!
      end
    end

    describe '#cd!' do
      it 'changes the current working directory' do
        sh.cd! Dir.home
        Dir.pwd.should eq(Dir.home)
        Dir.chdir @original
      end

      context 'with no argument' do
        it 'changes the current working directory to users home' do
          sh.cd!
          Dir.pwd.should eq(Dir.home)
        end
      end
    end

    after(:all) do
      Dir.chdir @original
    end
  end
end
