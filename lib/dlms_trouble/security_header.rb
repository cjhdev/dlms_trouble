module DLMSTrouble

    class SecurityHeader

        def authenticate?
            @authenticate
        end
        def encrypt?
            @encrypt
        end
        def compress?
            @compress
        end
        def unicast?
            @unicast
        end
        def broadcast?
            !@unicast
        end
        attr_reader :suite_id

        def self.decode(input)
            result = input.read(1).unpack("C")
            suite_id = result & 0xf
            if result & 0x10
            else
                authenticate = false
            end
            if result & 0x20
                encrypt = true
            else
                encrypt = false
            end
            if result & 0x40
                broadcast = true
            else
                broadcast = false
            end
            if result & 0x80
                compress = true
            else
                compress = false
            end
            self.new(authenticate: authenticate, encrypt: encrypt, compress: compress, suite_id: suite_id)
        end
        def initialize(**opt)
            @authenticate = opt[:authenticate]
            @encrypt = opt[:encrypt]
            @compress = opt[:compress]
            @suite_id = opt[:suite_id]||0
        end
        def encode
            buffer = ( authenticate? ? 0x10 : 0x00 )
            buffer |= ( encrypt? ? 0x20 : 0x00 )
            buffer |= ( unicast? ? 0x40 : 0x00 )
            buffer |= ( compress? ? 0x80 : 0x00 )
            buffer |= suite_id & 0xf
            [buffer].pack("C")
        end
        
    end

end
