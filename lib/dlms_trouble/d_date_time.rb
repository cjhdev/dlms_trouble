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

    class DDateTime < DType

        @tag = 25

        attr_reader :year, :month, :dom, :dow, :hour, :min, :sec, :hun, :gmt_offset, :status

        # @param value [nil,Time,Hash] time value
        # @param opt [Hash] init options
        #
        def initialize(value=nil, **arg)

            default = {
                :year => :undefined,
                :month => :undefined,
                :dom => :undefined,
                :dow => :undefined,
                :hour => :undefined,
                :min => :undefined,
                :sec => :undefined,
                :hun => :undefined,
                :gmt_offset => :undefined,
                :status => [:invalidClockStatus]
            }
        
            if value.kind_of? Time

                default.merge!({
                    :year => value.year,
                    :month => value.month,
                    :dom => value.day,
                    :dow => value.wday,
                    :hour => value.hour,
                    :min => value.min,
                    :sec => value.sec,
                    :hun => value.usec / 1000,
                    :gmt_offset => value.gmt_offset                        
                })

            elsif value.kind_of? Hash

                default.merge!(value)

            elsif !value.nil?

                raise DTypeError.new "cannot handle this value"
                
            end

            default.merge!(arg)

            @year = default[:year]
            @month = default[:month]
            @dom = default[:dom]
            @dow = default[:dow]
            @hour = default[:hour]
            @min = default[:min]
            @sec = default[:sec]
            @hun = default[:hun]
            @gmt_offset = default[:gmt_offset]
            @status = default[:status]
            
        end

        def to_axdr(**opts)
        
            out = opts[:packed] ? "" : axdr_tag

            if year == :undefined
                out << [0xffff].pack("S>")
            else
                out << [year].pack("S>")
            end
            
            case month
            when :dls_end
                out << [0xfd].pack("C")
            when :dls_begin
                out << [0xfe].pack("C")
            when :undefined
                out << [0xff].pack("C")
            else
                out << [month].pack("C")
            end
            
            case dom
            when :last_dom
                out << [0xfe].pack("C")
            when :second_last_dom
                out << [0xfd].pack("C")
            when :undefined
                out << [0xff].pack("C")
            else
                out << [dom].pack("C")
            end
            
            if dow == :undefined
                out << [0xff].pack("C")
            else
                out << [dow].pack("C")
            end
            
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
            
            if gmt_offset == :undefined
                out << [0x8000].pack("S>")
            else
                out << [gmt_offset].pack("S>")
            end
            
            clockStatus = 0
            
            status.each do |s|
                case s
                when :invalidValue
                    clockStatus |=  0x1
                when :doubtfulValue
                    clockStatus |=  0x2
                when :differentClockBase
                    clockStatus |=  0x4
                when :invalidClockStatus
                    clockStatus |= 0x8                            
                when :dlsActive
                    clockStatus |= 0x80                                    
                end
            end
            out << [clockStatus].pack("C")
        end

        def to_native
            self
        end
            
    end

end
