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

    class DTypeDSLError < Exception
    end

    # domain specific language for describing DLMS data structure
    class DTypeDSL

        INSERT = Proc.new do |method, id, args, sub|

            element = {:type => method}

            if id.nil?
                @anon = true
            else
                element[:id] = id.to_s
            end
               
            if @stack.size > 0

                case @stack.last[:type]
                when :array, :compactArray

                    if @stack.last[:value].size == 1
                        raise DTypeDSLError.new "repeating type already defined"
                    end

                when :structure

                    @stack.last[:value].each do |v|
                        if id and !@anon
                            if v[:id] == id.to_s
                                raise DTypeDSLError.new "structure field names must be unique"
                            end
                        end
                    end

                end

                if method == :compactArray and @packed
                    raise DTypeDSLError.new "cannot nest a compactArray"
                end
                
                if @stack.last[:size] and @stack.last[:value].size == @stack.last[:size].max
                    raise DTypeDSLError.new "exceeded size limit of container (#{@stack.last[:size]} elements)"
                else
                    @stack.last[:value] << element
                end
                                    
            else

                if !@type.nil?
                    raise DTypeDSLError.new "type already defined"
                else
                    @type = element
                end
                
            end

            case method
            when :array, :compactArray
                if args[:size]
                    if args[:size].kind_of? Integer
                        element[:size] = Range.new(args[:size], args[:size])
                    elsif args[:size].kind_of? Range
                        element[:size] = args[:size]
                    else
                        raise DTypeDSLError
                    end
                end

                element[:value] = []

                if method == :compactArray
                    @packed = true
                end

                @stack << element
                self.instance_exec(&sub)
                if @stack.last[:value].size == 0
                    raise DTypeDSLError
                end
                @stack.pop

                if method == :compactArray
                    @packed = false
                end
                          
            when :structure
                element[:value] = []

                @stack << element
                instance_exec(&sub)
                @stack.pop

            when :visibleString, :octetString
                if args[:size]
                    if args[:size].kind_of? Integer
                        element[:size] = Range.new(args[:size], args[:size])
                    elsif args[:size].kind_of? Range
                        element[:size] = args[:size]
                    else
                        raise DTypeDSLError
                    end
                end
                
            end

        end

        attr_reader :type
        attr_reader :anon

        def initialize(&dsl)
            @anon = false
            @packed = false
            @type = nil
            @stack = []
            if dsl
                self.instance_exec(&dsl)
            end
            
        end

        def self.nullData(id=nil, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.dontCare(id=nil, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.bcd(id=nil, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.boolean(id=nil, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.enum(id=nil, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.unsigned(id=nil, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.longUnsigned(id=nil, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.doubleLongUnsigned(id=nil, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.long64Unsigned(id=nil, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.integer(id=nil, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.long(id=nil, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.doubleLong(id=nil, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.long64(id=nil, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.float32(id=nil, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.floatingPoint(id=nil, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.float64(id=nil, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.octetString(id=nil, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.visibleString(id=nil, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.bitString(id=nil, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.structure(id=nil, **args, &sub)
            self.new.method(__method__).call(id, **args, &sub)
        end
        def self.array(id=nil, **args, &sub)
            self.new.method(__method__).call(id, **args, &sub)
        end            
        def self.compactArray(id=nil, **args, &sub)
            self.new.method(__method__).call(id, **args, &sub)
        end            
        def self.dateTime(id=nil, **args)
            self.new.method(__method__).call(id, **args)
        end            
        def self.date(id=nil, **args)
            self.new.method(__method__).call(id, **args)
        end            
        def self.time(id=nil, **args)
            self.new.method(__method__).call(id, **args)
        end            
        

        def nullData(id=nil, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def dontCare(id=nil, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def bcd(id=nil, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def boolean(id=nil, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def enum(id=nil, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def unsigned(id=nil, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def longUnsigned(id=nil, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def doubleLongUnsigned(id=nil, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def long64Unsigned(id=nil, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def integer(id=nil, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def long(id=nil, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def doubleLong(id=nil, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def long64(id=nil, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def float32(id=nil, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def floatingPoint(id=nil, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def float64(id=nil, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def octetString(id=nil, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def visibleString(id=nil, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def bitString(id=nil, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def structure(id=nil, **args, &sub)
            instance_exec(__method__, id, args, sub, &INSERT)
            self
        end
        def array(id=nil, **args, &sub)
            instance_exec(__method__, id, args, sub, &INSERT)
            self
        end            
        def compactArray(id=nil, **args, &sub)
            instance_exec(__method__, id, args, sub, &INSERT)
            self
        end            
        def dateTime(id=nil, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end            
        def date(id=nil, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end            
        def time(id=nil, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end            
    
    end

end
