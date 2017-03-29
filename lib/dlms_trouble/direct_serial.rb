# Copyright (c) 2016 Cameron Harper
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#  
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'ruby-serial'

module DLMSTrouble

    class ModeEPort

        def initialize(port, **opts)

            puts "opening port '#{port}'"

            @port = SerialPort.new(port)
            @port.baud = 300
            @port.data_bits = 7
            @port.parity = 1
            @port.read_timeout = opts[:timeout]||1500
            @port.flush_input
            
            puts "writing Request..."

            @port.write(DirectLocal::Request.new.to_line)

            sleep(1)

            puts "reading line"
    
            line = @port.readline

            puts "expecting Idenfification"

            id = DirectLocal::Identification.from_line(line)

            puts "device '#{id.id}' answered"

            puts "switch to mode E"

            DirectLocal::Ack.new(

            @port.flush_input
            
        end

        def read
        end

        def write
        end
        
    end

    module DirectLocal

        MODE_A
        MODE_B
        MODE_C
        MODE_D
        MODE_E

        class Request
            def self.from_line(msg)
                result = /\/\?(?<addr>[A-Za-z0-9 ]{1,32})?\r\n/.match(msg)
                if result.nil?
                    raise
                end
                self.new(result[:addr])
            end
            def initialize(addr=nil)
                @addr = addr
            end
            def to_line
                "/?#{@addr}\r\n"
            end
        end

        class Identification
            attr_reader :flagID, :baud, :id
            def self.from_line(msg)
                msg.match(/\/()/
            end
            def initialize(flagID, baud, id)
                @flagID = flagID
                @baud = baud
                @id = id
            end
            def to_line
                "/#{@flagID}#{@baud}" + ( @id ? "\\W"
            end                        
        end

        class Ack
            def self.from_line(msg)
                result = /\x06(?<protocol>)(?<baud>)(?<>)\r\n/.match(msg)
                if result.nil?
                    raise
                end
                self.new(result[:protocol], result[:baud], result[:])
            end
            def initialize(protocol, baud, control)
                @protocol = protocol
                @baud = baud
                @control = control
            end
            def to_line
                "\x06#{@protocol}#{@baud}#{@control}\r\n"
            end            
        end
        
    end

end
