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

module DLMSTrouble

    module BER

        class Identifier
        
            CLS = {
                :UNIVERSAL => 0,
                :APPLICATION => 0x40,
                :CONTEXT => 0x80,
                :PRIVATE => 0xC0
            }
            
            attr_reader :cls, :tag

            def primitive?
                @primitive
            end
            
            def self.decode(input)
                raw = input.read(1).unpack("C")

                opts = {
                    :cls => CLS.key(raw & 0xc0),
                    :primitive => (((raw & 0x20) == 0x20) ? true : false)
                }
                    
                self.new(raw & 0x1f, **opts)                    
                    
            end
            
            def initialize(tag, **opts)

                @tag = tag.to_i & 0x1f

                if opts[:cls]      
                    if !CLS.keys.include? opts[:cls]
                        raise
                    end
                    @cls = opts[:cls]
                else
                    @cls = :UNIVERSAL
                end
                
                if opts[:primitive]
                    @primitive = (primitive ? true : false)
                else
                    @primitive = false
                end
                
            end
            
            def encode
                raw = CLS[cls]
                raw |= ( @primitive ? 0x20 : 0x00 )
                raw |= tag & 0x1f
                [raw].pack("C")
            end
            
        end

        class Length

            attr_reader :value

            def definite?
                !@length.nil?
            end

            def indefinite?
                @length.nil?
            end
    
            def self.decode(input)
                bytes = input.read(1).unpack("C")
                if bytes == 0x80
                    self.new
                elsif bytes < 0x80
                    self.new(bytes)
                else
                    length = input.read(bytes).unpack("C#{bytes}")                    
                end                    
            end

            def initialize(length=nil)
                @value = length
            end

            def encode
                if @length.nil?
                    [0x80].pack("C")
                else
                    bytes = @value & 0x7f
                end
            end
        
        end

    end

end
