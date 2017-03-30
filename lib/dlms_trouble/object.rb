



class ExtendedRegister4 < DLMSClass
    defineAttribute("logical_name")
    defineAttribute("data")
    defineAttribute("scaler_unit")
    defineMethod("reset")
end




module DLMSTrouble

    class DLMSClass
        
        VERSIONED_NAME_REGEX = /^(?<name>([A-Z][A-Za-z0-9]*))CID(?<classID>[0-9]+)V(?<version>[0-9]+)$/
        NAME_REGEX = /^(?<name>([A-Z][A-Za-z0-9]*))CID(?<classID>[0-9]+)$/

        def self.inherited(subclass)

            subclass.defineClass
            super
            
        end

        # @param classVersion [Integer] Class Version        
        def self.defineClass

            #if !classID.is_a? Integer or classID > CLASS_ID_MAX; raise ArgumentError.new "classID must be an Integer in the range (0..#{CLASS_ID_MAX})" end

            name = self.name.split('::').last
            match = VERSIONED_NAME_REGEX.match(name)

            if match

                @classVersion = match[:version].to_i
                @className = match[:name]
                @classID = match[:classID]                

            else

                match = NAME_REGEX.match(name)

                if match

                    @classVersion = 0
                    @className = match[:name]
                    @classID = match[:classID]

                else

                    raise "class name '#{name}' must be meet requirements"

                end

            end

            if @classVersion > CLASS_VERSION_MAX; raise ArgumentError.new "classVersion must be an Integer in the range (0..#{CLASS_VERSION_MAX})" end

            @methodByName = {}
            @methodByIndex = {}

        end

         # @return [String]
        def self.className; return @className end

        # @return [Integer]
        def self.classID; return @classID end

        # @return [Integer]
        def self.classVersion; return @classVersion end

        # @param [String,Integer]
        # @return [Hash] attribute descriptor
        def self.attribute(id=nil)
            if id.nil?
                @attrByName.values
            elsif id.kind_of? String
                @attrByName[id]             
            else
                @attrByIndex[id.to_i]
            end
        end

        def self.method(id)
            if id.kind_of? String
                @methByName[id]             
            else
                @methByIndex[id.to_i]
            end
        end

        def self.defineAttribute(name, **opts)
            id = opts[:attributeID]
            if id
                if id.to_i > 127 or id.to_i < -128; raise ArgumentError end
            else
                id = 1
                @attrs.each do |attr|
                    if attr[:attrID]
                    

            
            
        end

        def self.defineMethod(name, **opts)
            id = opts[:methodID]
        end
        
        def self.defineMethod(methodName, opts = {})

            methodIndex = opts[:methodIndex]

            if !methodName.is_a? String; raise ArgumentError.new "methodName '#{methodName}' is not [String]"end
            if !methodIndex.nil? and ( !methodIndex.is_a? Integer or methodIndex > METHOD_INDEX_MAX); raise ArgumentError.new "opts[:methodIndex] '#{methodIndex}' is not [Integer] in range (0..#{METHOD_INDEX_MAX})" end
            
            if methodIndex.nil?

                if @methodByIndex.size == 0; methodIndex = 0 else methodIndex = @methodByIndex.keys.last + 1 end

                if methodIndex > METHOD_INDEX_MAX; raise Exception "Implicitly allocated methodIndex is exhausted at method definition '#{methodName}'" end

            else

                if !methodByIndex[methodIndex].nil?; raise Exception "opts[:methodIndex] `#{methodIndex}` is already allocated to method `#{@methodByIndex[methodIndex][:methodName]}`" end

            end

            if @methodByName[methodName]; raise "Method '#{methodName}' is already defined" end

            @methodByName[methodName] = {
                :methodName => methodName,
                :methodIndex => methodIndex,
                :description => opts[:description],
                :argument => opts[:argument],
                :returnValue => opts[:returnValue]
            }

            @methodByIndex[methodIndex] = @methodByName[methodName]

        end

        

        
    end
    
end
