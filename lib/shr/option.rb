#coding: utf-8

module Shr
  class Option
    # xxx
    def initialize
      @stack = []
    end

    # xxx
    # This method has not support Windows yet.
    def parse(options)
      options.each do |opt|
        case opt
        when String
          @stack << opt
        when Symbol
          @stack << translate_from(opt)
        when Hash
          opt.each do |k, v|
            if v.eql?(true)
              @stack << translate_from(k)
            else
              if k.length > 1
                @stack << "#{translate_from(k)}=#{v}"
              else
                @stack << translate_from(k) << v
              end

            end
          end
        when Fixnum
          @stack << "-#{opt}"
        end
      end
      @stack
    end

    private

    def translate_from(opt)
      s = opt.to_s
      "-#{s.length > 1 ? '-' : ''}#{s}"
    end
  end
end
