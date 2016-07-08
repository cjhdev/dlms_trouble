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

    module AXDR

        class AXDRError < Exception
        end

        # @param size [Integer]
        # @return [Integer] byte length to encode size
        def self.sizeSize(size)

            if size < 0x80
                return 1
            else
                max = 0x100
                bytes = 2

                loop do

                    if size < max
                        return bytes
                    end

                    bytes += 1
                    max = max << 8

                end
            end
        end

        # @param size [Integer]
        # @return [String] encoded size
        def self.putSize(size)

            bytes = sizeSize(size.to_i)
            out = Array.new(bytes)

            if bytes == 1
                out[0] = size
            else
                out.each_with_index do |v,i|
                    if i == 0
                        out[i] = 0x80 + bytes - 1
                    else
                        out[i] = size >> ((bytes - i - 1)*8)
                    end
                end
            end

            out.pack("C#{bytes}")
        end       

        # @param input [String]
        # @return [Integer] decoded size
        # @raise [AXDRError]
        def self.getSize!(input)

            begin

                size = 0
                lead = input.slice!(0).unpack("C").first

                if lead.nil? or lead == 0x80
                    raise AXDRError
                elsif lead < 0x80
                    size = lead
                else
                    input.slice!(0, lead & 0x7f).unpack("C#{lead & 0x7f}").each do |v|
                        if v.nil?; raise AXDRError end
                        size = (size << 8) | v            
                    end
                end

            rescue
                raise AXDRError
            end

            size
                            
        end
        
    end

end
