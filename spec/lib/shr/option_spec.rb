#coding: utf-8
require 'spec_helper'

module Shr
  describe Option do
    let(:opt) { Option.new }

    SHORT_FORM = ['-o', 'page.html']
    LONG_FORM  = ['--shell=/bin/sh', '--silent']
    MIXED_FORM = SHORT_FORM + LONG_FORM

    it 'has the following methods' do
      o = opt.methods
      o.should include(:parse)
    end

    describe '#parse' do
      describe String do
        it 'remains argument unchanged' do
          opt.parse(MIXED_FORM).should eq(MIXED_FORM)
        end
      end

      describe Symbol do
        context 'with a character' do
          it 'tranlate argument to short-form' do
            opt.parse([:o]).should eq(['-o'])
          end
        end

        context 'with some characters' do
          it 'translates argument to long-form' do
            opt.parse([:silent]).should eq(['--silent'])
          end
        end
      end

      describe Hash do
        it { opt.parse([{ :o => 'page.html' }]).should eq(SHORT_FORM) }
        it { opt.parse([{ :shell => '/bin/sh', :silent => true }]).should eq(LONG_FORM) }
      end

      describe Fixnum do
        it 'translates argument to short-form' do
          opt.parse([1, 2, 3]).should eq(['-1', '-2', '-3'])
        end
      end

      describe Array do
        # xxx
      end
    end
  end
end
