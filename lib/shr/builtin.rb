#coding: utf-8
require 'stringio'

module Shr
  module Builtin

    def capture(&block)
      proc = Proc.new do |environment|
        output = relay capture_stdout(&block)
        if environment.key? :out
          File.write(environment[:out], output.read)
        end
        [output, nil]
      end
      @commands << [:capture, proc]
      self
    end

    private

    def capture_stdout
      begin
        $stdout = StringIO.new
        yield
        out = $stdout.string
      ensure
        $stdout = STDOUT
      end
      out
    end

    def relay(source)
      r, w = IO.pipe
      w.write source
      w.close
      r
    end
  end
end
