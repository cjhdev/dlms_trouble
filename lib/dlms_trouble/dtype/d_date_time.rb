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

require 'set'

module DLMSTrouble::DType

    class DateTime < DType

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
                :status => [:invalid_status]
            }
        
            if value.kind_of? ::Time

                default.merge!({
                    :year => value.year,
                    :month => value.month,
                    :dom => value.day,
                    :dow => value.wday,
                    :hour => value.hour,
                    :min => value.min,
                    :sec => value.sec,
                    :hun => value.usec / 10000,
                    :gmt_offset => value.gmt_offset / 60                        
                })

                if default[:dow] == 0
                    default[:dow] = 7
                end

            elsif value.kind_of? Hash

                default.merge!(value)
                
            elsif !value.nil?

                raise DTypeError.new "cannot handle this value"
                
            end

            default.merge!(arg)

            case default[:year]
            when :undefined, 0xffff
                default[:year] = :undefined
            else
                if !Range.new(0,0xfffe).include? default[:year]
                    raise DTypeError.new "year is invalid"
                end                    
            end

            case default[:month]
            when 0xff, :undefined
                default[:month] = :undefined
            when 0xfd, :dls_end
                default[:month] = :dls_end
            when 0xfe, :dls_begin
                default[:month] = :dls_begin
            else
                if !Range.new(1,12).include? default[:month]
                    raise DTypeError.new "month is invalid"
                end
            end

            case default[:dom]
            when 0xff, :undefined
                default[:dom] = :undefined
            when 0xfd, :last_dom
                default[:dom] = :last_dom
            when 0xfe, :second_last_dom
                default[:dom] = :second_last_dom
            else
                if !Range.new(1,31).include? default[:dom]
                    raise DTypeError.new "day of month is invalid"
                end
            end

            case default[:dow]
            when 0xff, :undefined
                default[:dow] = :undefined
            else
                if !Range.new(1,7).include? default[:dow]
                    raise DTypeError.new "day of week is invalid"
                end
            end

            case default[:hour]
            when :undefined, 0xff
                default[:hour] = :undefined
            else
                if !Range.new(0,23).include? default[:hour]
                    raise DTypeError.new "hour is invalid"
                end
            end

            case default[:min]
            when :undefined, 0xff
                default[:min] = :undefined
            else
                if !Range.new(0,59).include? default[:min]
                    raise DTypeError.new "minute is invalid"
                end
            end

            case default[:sec]
            when :undefined, 0xff
                default[:sec] = :undefined
            else
                if !Range.new(0,59).include? default[:sec]
                    raise DTypeError.new "second is invalid"
                end
            end

            case default[:hun]
            when :undefined, 0xff
                default[:hun] = :undefined
            else
                if !Range.new(0,99).include? default[:hun]
                    raise DTypeError.new "hundredth is invalid"
                end
            end

            case default[:gmt_offset]
            when :undefined, 0x8000
                default[:gmt_offset] = :undefined
            else
                if !Range.new(-720,720).include? default[:gmt_offset]
                    raise DTypeError.new "gmt_offset is invalid"
                end
            end

            if default[:status].respond_to? :to_i

                status = default[:status].to_i
                default[:status] = []

                if (status & 0x01) != 0
                    default[:status] << :invalid_value
                end
                if (status & 0x02) != 0
                    default[:status] << :doubtful_value
                end
                if (status & 0x04) != 0
                    default[:status] << :different_clock_base
                end
                if (status & 0x08) != 0
                    default[:status] << :invalid_status
                end                
                if (status & 0x80) != 0
                    default[:status] << :dls_active
                end
                if (status & 0x70) != 0
                    raise DTypeError.new "status has reserved bits set"
                end

            elsif default[:status].respond_to? :to_a

                status = default[:status].to_a
                default[:status] = []

                if status.include? :invalid_value
                    default[:status] << :invalid_value
                end
                if status.include? :doubtful_value
                    default[:status] << :doubtful_value
                end
                if status.include? :different_clock_base
                    default[:status] << :different_clock_base
                end
                if status.include? :invalid_status
                    default[:status] << :invalid_status
                end
                if status.include? :dls_active
                    default[:status] << :dls_active
                end
                    
            elsif default[:status].is_a? Symbol

                if [:invalid_value, :doubtful_value, :different_clock_base, :invalid_status, :dls_active].include? default[:status]
                    default[:status] = [default[:status]]
                else
                    raise DTypeError.new "cannot recognise status"
                end

            else
                raise DTypeError.new "cannot recognise status"
            end                        
               
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

        def encode(**opts)
        
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
                when :invalid_value
                    clockStatus |=  0x1
                when :doubtful_value
                    clockStatus |=  0x2
                when :different_clock_base
                    clockStatus |=  0x4
                when :invalid_status
                    clockStatus |= 0x8                            
                when :dls_active
                    clockStatus |= 0x80                                    
                end
            end
            out << [clockStatus].pack("C")
        end

        def self.decode(input, typedef=nil)
            begin                
                decoded = input.read(12).unpack("S>CCCCCCCS>C").each                
            rescue
                raise DTypeError.new "input too short while decoding #{self}"
            end
            val = {}
            val[:year] = decoded.next
            val[:month] = decoded.next
            val[:dom] = decoded.next
            val[:dow] = decoded.next
            val[:hour] = decoded.next
            val[:min] = decoded.next
            val[:sec] = decoded.next
            val[:hun] = decoded.next                   
            val[:gmt_offset] = decoded.next                   
            val[:status] = decoded.next                   
            self.new(val)           
        end

        def to_native
            self            
        end
            
    end

end
