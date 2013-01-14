#coding: utf-8

module Shr
  class Option
    class << self
      attr_accessor :indicator

      def indicator
        @indicator ||= '-'
      end

      def translate(options)
        result = []
        options.each do |opt|
          case opt
          when String then result << opt
          when Symbol then result << translate_from(opt)
          when Fixnum then result << "#{indicator}#{opt}"
          when Hash
            opt.each do |k, v|
              if v.eql?(true)
                result << translate_from(k)
              else
                if k.length > 1
                  result << "#{translate_from(k)}=#{v}"
                else
                  result << translate_from(k) << v
                end
              end
            end
          end
        end
        result
      end

      private

      def translate_from(opt)
        s = opt.to_s
        "#{indicator}#{(s.length > 1 ? '-' : '') if indicator == '-'}#{s}"
      end
    end
  end
end
