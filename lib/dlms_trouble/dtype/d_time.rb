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

module DLMSTrouble::DType

    class Time < DType

        @tag = 27

        attr_reader :hour, :min, :sec, :hun

        def initialize(value=nil, **arg)

            default = {
                :hour => :undefined,
                :min => :undefined,
                :sec => :undefined,
                :hun => :undefined
            }
        
            if value.kind_of? ::Time

                default.merge!({
                    :hour => value.hour,
                    :min => value.min,
                    :sec => value.sec,
                    :hun => value.usec / 10000,
                })

            elsif value.kind_of? Hash

                default.merge!(value)
            
            elsif !value.nil?

                raise DTypeError.new "cannot handle this value"
                
            end

            default.merge!(arg)

            case default[:hour]
            when :undefined, 0xff
                default[:hour] = :undefined
            else
                if !Range.new(0,23).include? default[:hour]
                    raise DTypeError
                end
            end

            case default[:min]
            when :undefined, 0xff
                default[:min] = :undefined
            else
                if !Range.new(0,59).include? default[:min]
                    raise DTypeError
                end
            end

            case default[:sec]
            when :undefined, 0xff
                default[:sec] = :undefined
            else
                if !Range.new(0,59).include? default[:sec]
                    raise DTypeError
                end
            end

            case default[:hun]
            when :undefined, 0xff
                default[:hun] = :undefined
            else
                if !Range.new(0,99).include? default[:hun]
                    raise DTypeError
                end
            end

            @hour = default[:hour]
            @min = default[:min]
            @sec = default[:sec]
            @hun = default[:hun]
            
        end

        def encode(**opts)
            
            out = opts[:packed] ? "" : axdr_tag

            if hour == :undefined
                out << [0xff].pack("C")
            else
                out << [hour].pack("C")
            end
            if min == :undefined
                out << [0xff].pack("C")
            else
                out << [min].pack("C")
            end
            if sec == :undefined
                out << [0xff].pack("C")
            else
                out << [sec].pack("C")
            end
            if hun == :undefined
                out << [0xff].pack("C")
            else
                out << [hun].pack("C")
            end
        end

        def self.decode(input, typedef=nil)
            begin
                decoded = input.read(4).unpack("CCCC").each                
            rescue
                raise DTypeError.new "input too short while decoding #{self}"
            end
            val = {}
            val[:hour] = decoded.next
            val[:min] = decoded.next
            val[:sec] = decoded.next
            val[:hun] = decoded.next                   
            self.new(val)           
        end

        def to_native
            self
        end

    end

end
