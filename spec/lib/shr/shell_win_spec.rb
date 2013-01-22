#coding: utf-8
require 'spec_helper'
require 'fileutils'
require 'tempfile'
require 'tmpdir'

module Shr
  if OS.windows?
    describe Shell do
      let(:sh) { Shell.new }

      before(:all) do
        Option.indicator = '/'
        @tmpdir = Dir.mktmpdir
        ['perl.pl', 'python.py', 'ruby.rb'].each do |file|
          FileUtils.touch File.join(@tmpdir, file)
        end
        @tmpfile = File.join(@tmpdir, 'ruby.rb.back')
      end

      it 'executes OS commands' do
        cmd_result = `chdir`
        sh_result  = sh.chdir.to_s
        sh_result.should eq(cmd_result)
      end

      context "command end with '!'" do
        it 'executes OS commands' do
          sh.copy!('nul', @tmpfile.gsub('/', '\\'))
          File.should exist(@tmpfile)
          FileUtils.rm @tmpfile
        end
      end

      describe '#each' do
        it 'yields each line (result of command) to the block' do
          files = []
          sh.dir(:B, @tmpdir.gsub('/', '\\')).sort(:R).each do |file|
            files << file.strip
          end
          files.should eq(['ruby.rb', 'python.py', 'perl.pl'])
        end

        context 'without block' do
          it 'returns Enumerator' do
            sh.dir.each.should be_kind_of(Enumerator)
          end
        end
      end

      it "emulates the shell pipe operator by method chaining" do
        cmd_result = `chdir | ruby -ne 'puts $_.tr("a-z", "A-Z")'`
        sh_result = sh.chdir.ruby('-ne', %q{'puts $_.tr("a-z", "A-Z")'}).to_s
        sh_result.should eq(cmd_result)
      end

      describe '#redirect_from' do
        it 'redirect from file to command' do
          tempfile = Tempfile.new('temp')
          sh.chdir.redirect_to(tempfile.path)
          sh.more.redirect_from(tempfile.path).to_s.should eq(`chdir`)
          tempfile.close!
        end
      end

      describe '#redirect_to' do
        it 'redirecs result of command to file' do
          tempfile = Tempfile.new('temp')
          sh.chdir.redirect_to(tempfile.path)
          sh.more.redirect_from(tempfile.path).to_s.should eq(`chdir`)
          tempfile.close!
        end
      end

      after(:all) do
        FileUtils.remove_entry_secure @tmpdir
      end
    end
  end
end
