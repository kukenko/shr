#coding: utf-8

module Shr
  class Option
    def initialize
      @options   = []
      @indicator = '-'
    end
    attr_accessor :indicator

    def parse(options)
      options.each do |opt|
        case opt
        when String
          @options << opt
        when Symbol
          @options << translate_from(opt)
        when Hash
          opt.each do |k, v|
            if v.eql?(true)
              @options << translate_from(k)
            else
              if k.length > 1
                @options << "#{translate_from(k)}=#{v}"
              else
                @options << translate_from(k) << v
              end
            end
          end
        when Fixnum
          @options << "#{@indicator}#{opt}"
        end
      end
      @options
    end

    private

    def translate_from(opt)
      s = opt.to_s
      "#{@indicator}#{(s.length > 1 ? '-' : '') if @indicator == '-'}#{s}"
    end
  end
end
