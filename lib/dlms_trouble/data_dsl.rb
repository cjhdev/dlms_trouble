module DLMSTrouble

    class DataDSLError < Exception
    end

    # domain specific language for describing DLMS data structure
    class DataDSL

        INSERT = Proc.new do |method, id, args, sub|

            element = {:type => method, :id => id}

            if @stack.size > 0

                case @stack.last[:type]
                when :array, :compactArray

                    if @stack.last[:value].size == 1
                        raise DataDSLError.new "repeating type already defined"
                    end

                when :structure

                    @stack.last[:value].each do |v|
                        if v[:id] == id
                            raise DataDSLError.new "structure field names must be unique"
                        end
                    end

                end

                if method == :compactArray and @packed
                    raise DataDSLError.new "cannot nest a compactArray"
                end
                
                if @stack.last[:size] and @stack.last[:value].size == @stack.last[:size].max
                    raise DataDSLError.new "exceeded size limit of container (#{@stack.last[:size]} elements)"
                else
                    @stack.last[:value] << element
                end
                                    
            else

                if !@type.nil?
                    raise DataDSLError.new "type already defined"
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
                        raise DataDSLError
                    end
                end

                element[:value] = []

                if method == :compactArray
                    @packed = true
                end

                @stack << element
                self.instance_exec(&sub)
                if @stack.last[:value].size == 0
                    raise DataDSLError
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
                        raise DataDSLError
                    end
                end
                
            end

        end

        attr_reader :type

        def initialize(&dsl)

            @packed = false
            @type = nil
            @stack = []
            if dsl
                self.instance_exec(&dsl)
            end
            
        end

        def self.nullData(id, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.boolean(id, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.enum(id, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.unsigned(id, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.longUnsigned(id, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.doubleLongUnsigned(id, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.long64Unsigned(id, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.integer(id, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.long(id, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.doubleLong(id, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.long64(id, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.float32(id, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.floatingPoint(id, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.float64(id, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.octetString(id, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.visibleString(id, **args)
            self.new.method(__method__).call(id, **args)
        end
        def self.structure(id, **args, &sub)
            self.new.method(__method__).call(id, **args, &sub)
        end
        def self.array(id, **args, &sub)
            self.new.method(__method__).call(id, **args, &sub)
        end            
        def self.compactArray(id, **args, &sub)
            self.new.method(__method__).call(id, **args, &sub)
        end            
        

        def nullData(id, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def boolean(id, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def enum(id, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def unsigned(id, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def longUnsigned(id, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def doubleLongUnsigned(id, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def long64Unsigned(id, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def integer(id, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def long(id, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def doubleLong(id, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def long64(id, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def float32(id, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def floatingPoint(id, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def float64(id, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def octetString(id, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def visibleString(id, **args)
            instance_exec(__method__, id, args, nil, &INSERT)
            self
        end
        def structure(id, **args, &sub)
            instance_exec(__method__, id, args, sub, &INSERT)
            self
        end
        def array(id, **args, &sub)
            instance_exec(__method__, id, args, sub, &INSERT)
            self
        end            
        def compactArray(id, **args, &sub)
            instance_exec(__method__, id, args, sub, &INSERT)
            self
        end            
    
    end

end
