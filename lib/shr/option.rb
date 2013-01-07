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
          @stack.push opt
        when Symbol
          @stack << "-#{opt.length > 1 ? '-' : ''}#{opt}"
        when Hash
          opt.each do |k, v|
            if v.eql?(true)
              @stack << "-#{k.length > 1 ? '-' : ''}#{k}"
            else
              if k.length > 1
                @stack << "--#{k}=#{v}"
              else
                @stack << "-#{k.length > 1 ? '-' : ''}#{k}" << v
              end
            end
          end
        when Fixnum
          @stack << "-#{opt}"
        end
      end
      @stack
    end
  end
end
