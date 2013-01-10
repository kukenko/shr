#coding: utf-8
require 'spec_helper'
require 'fileutils'
require 'tempfile'
require 'tmpdir'

module Shr
  describe Shell do
    let(:sh) { Shell.new }

    before(:all) do
      @tmpdir = Dir.mktmpdir
      ['perl.pl', 'python.py', 'ruby.rb'].each do |file|
        FileUtils.touch File.join(@tmpdir, file)
      end
      @tmpfile = File.join(@tmpdir, 'ruby.rb.back')
    end

    it 'has the following methods' do
      m = sh.methods
      m.should include(:capture)
      m.should include(:release)
      m.should include(:exitstatus)
      m.should include(:each)
      m.should include(:redirect_from)
      m.should include(:<)
      m.should include(:redirect_to)
      m.should include(:>)
    end

    it 'executes OS commands' do
      cmd_result = OS.windows? ? `chdir` : `pwd`
      sh_result  = OS.windows? ? sh.chdir.to_s : sh.pwd.to_s
      sh_result.should eq(cmd_result)
    end

    context "command end with '!'" do
      it 'executes OS commands' do
        if OS.windows?
          sh.copy!('nul', @tmpfile.gsub('/', '\\'))
        else
          sh.touch! @tmpfile
        end
        File.should exist(@tmpfile)
        FileUtils.rm @tmpfile
      end
    end

    describe '#capture' do
      it 'captures output of commands'
    end

    describe '#release' do
      it 'releases output of commands'
    end

    describe '#each' do
      it 'yields each line (result of command) to the block' do
        files = []
        if OS.windows?
          sh.dir(:B, @tmpdir.gsub('/', '\\')).sort(:R).each do |file|
            files << file.strip
          end
        else
          sh.ls(@tmpdir).sort(:r).each do |file|
            files << file.strip
          end
        end
        files.should eq(['ruby.rb', 'python.py', 'perl.pl'])
      end

      context 'without block' do
        it 'returns Enumerator' do
          if OS.windows?
            sh.dir.each.should be_kind_of(Enumerator)
          else
            sh.ls.each.should be_kind_of(Enumerator)
          end
        end
      end
    end

    it "emulates the shell pipe operator by method chaining" do
      if OS.windows?
        cmd_result = `chdir | ruby -ne 'puts $_.tr("a-z", "A-Z")'`
        sh_result = sh.chdir.ruby('-ne', %q{'puts $_.tr("a-z", "A-Z")'}).to_s
      else
        cmd_result = `pwd | tr '[:lower:]' '[:upper:]'`
        sh_result = sh.pwd.tr("'[:lower:]'", "'[:upper:]'").to_s
      end
      sh_result.should eq(cmd_result)
    end

    describe '#exitstatus' do
      it "shows an exit status of process" do
        sh.ruby('-e', "'exit 0'").exitstatus.should eq(0)
        sh.ruby('-e', "'exit 1'").exitstatus.should eq(1)
      end
    end

    describe '#redirect_from' do
      it 'redirect from file to command' do
        tempfile = Tempfile.new('temp')
        if OS.windows?
          sh.chdir.redirect_to(tempfile.path)
          sh.more.redirect_from(tempfile.path).to_s.should eq(`chdir`)
        else
          sh.pwd.redirect_to(tempfile.path)
          sh.cat.redirect_from(tempfile.path).to_s.should eq(`pwd`)
        end
        tempfile.close!
      end
    end

    describe '#redirect_to' do
      it 'redirecs result of command to file' do
        tempfile = Tempfile.new('temp')
        if OS.windows?
          sh.chdir.redirect_to(tempfile.path)
          File.read(tempfile.path).should eq(`chdir`)
        else
          sh.pwd.redirect_to(tempfile.path)
          File.read(tempfile.path).should eq(`pwd`)
        end
        tempfile.close!
      end
    end

    after(:all) do
      FileUtils.remove_entry_secure @tmpdir
    end
  end
end
