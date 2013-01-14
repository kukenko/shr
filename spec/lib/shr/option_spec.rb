#coding: utf-8
require 'spec_helper'

module Shr
  describe Option do
    let(:opt) { Option.new }

    SHORT_FORM = ['-o', 'page.html']
    LONG_FORM  = ['--shell=/bin/sh', '--silent']
    MIXED_FORM = SHORT_FORM + LONG_FORM

    it 'has the following methods' do
      o = Option.methods
      o.should include(:translate)
    end

    describe '#translate' do
      describe String do
        it 'remains argument unchanged' do
          Option.indicator = '-'
          Option.translate(MIXED_FORM).should eq(MIXED_FORM)
        end
      end

      describe Symbol do
        context 'with a character' do
          it 'tranlate argument to short-form' do
            Option.indicator = '-'
            Option.translate([:o]).should eq(['-o'])
          end

          it 'may be indicated by @indicator' do
            Option.indicator = '/'
            Option.translate([:o]).should eq(['/o'])
          end
        end

        context 'with some characters' do
          it 'translates argument to long-form' do
            Option.indicator = '-'
            Option.translate([:silent]).should eq(['--silent'])
          end

          it 'may be indicated by @indicator' do
            Option.indicator = '/'
            Option.translate([:silent]).should eq(['/silent'])
          end
        end
      end

      describe Hash do
        it {
          Option.indicator = '-'
          Option.translate([{ :o => 'page.html' }]).should eq(SHORT_FORM)
        }

        it {
          Option.indicator = '-'
          Option.translate([{ :shell => '/bin/sh', :silent => true }]).should eq(LONG_FORM)
        }

        context 'with indicator' do
          it 'may be indicated by @indicator' do
            Option.indicator = '/'
            Option.translate([{ :o => 'page.html' }]).should eq(['/o', 'page.html'])
          end
        end
      end

      describe Fixnum do
        it 'translates argument to short-form' do
          Option.indicator = '-'
          Option.translate([1, 2, 3]).should eq(['-1', '-2', '-3'])
        end

        context 'with indicator' do
          it 'may be indicated by @indicator' do
            Option.indicator = '/'
            Option.translate([1, 2, 3]).should eq(['/1', '/2', '/3'])
          end
        end
      end
    end
  end
end
