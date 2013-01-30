#coding: utf-8
require 'spec_helper'
require 'fileutils'
require 'tempfile'
require 'tmpdir'

module Shr
  describe Shell do
    let(:sh) { Shell.new }

    it 'has the following methods' do
      m = sh.methods
      m.should include(:exitstatus)
      m.should include(:each)
      m.should include(:redirect_from)
      m.should include(:<)
      m.should include(:redirect_to)
      m.should include(:>)
      m.should include(:bake)
    end

    unless OS.windows?
      before(:all) do
        Option.indicator = '-'
        @tmpdir = Dir.mktmpdir
        ['perl.pl', 'python.py', 'ruby.rb'].each do |file|
          FileUtils.touch File.join(@tmpdir, file)
        end
        @tmpfile = File.join(@tmpdir, 'ruby.rb.back')
      end

      it 'executes OS commands' do
        cmd_result = `pwd`
        sh_result  = sh.pwd.to_s
        sh_result.should eq(cmd_result)
      end

      context "command end with '!'" do
        it 'executes OS commands' do
          sh.touch! @tmpfile
          File.should exist(@tmpfile)
          FileUtils.rm @tmpfile
        end
      end

      describe '#each' do
        it 'yields each line (result of command) to the block' do
          files = []
          sh.ls(@tmpdir).sort(:r).each do |file|
            files << file.strip
          end
          files.should eq(['ruby.rb', 'python.py', 'perl.pl'])
        end

        context 'without block' do
          it 'returns Enumerator' do
            sh.ls.each.should be_kind_of(Enumerator)
          end
        end
      end

      it "emulates the shell pipe operator by method chaining" do
        cmd_result = `pwd | tr '[:lower:]' '[:upper:]'`
        sh_result = sh.pwd.tr("'[:lower:]'", "'[:upper:]'").to_s
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
          sh.pwd.redirect_to(tempfile.path)
          sh.cat.redirect_from(tempfile.path).to_s.should eq(`pwd`)
          tempfile.close!
        end
      end

      describe '#redirect_to' do
        it 'redirecs result of command to file' do
          tempfile = Tempfile.new('temp')
          sh.pwd.redirect_to(tempfile.path)
          sh.cat.redirect_from(tempfile.path).to_s.should eq(`pwd`)
          tempfile.close!
        end
      end

      describe '#bake' do
        it 'bakes new command' do
          sh.bake(:sort_r, :sort, [:r])

          files = []
          sh.ls(@tmpdir).sort_r.each do |file|
            files << file.strip
          end
          files.should eq(['ruby.rb', 'python.py', 'perl.pl'])
        end
      end

      after(:all) do
        FileUtils.remove_entry_secure @tmpdir
      end
    end
  end
end
