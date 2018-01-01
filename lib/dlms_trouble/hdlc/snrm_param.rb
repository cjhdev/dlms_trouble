module DLMSTrouble::HDLC
    
    class SNRMParam

        HDLC_NEGOPARAMS_FORMAT          = 0x81
        HDLC_NEGOPARAMS_GROUP           = 0x80
        HDLC_NEGOPARAMS_MAXWINDOWTX     = 0x07
        HDLC_NEGOPARAMS_MAXWINDOWRX     = 0x08
        HDLC_NEGOPARAMS_MAXINFOTX       = 0x05
        HDLC_NEGOPARAMS_MAXINFORX       = 0x06            
        
        attr_reader :tx_size
        attr_reader :rx_size
        attr_reader :tx_window
        attr_reader :rx_window
        
        # @param tx_size [Integer]
        # @param rx_size [Integer]
        # @param tx_window [Integer]
        # @param rx_window [Integer]
        def initialize(**param)
            
            @tx_size = param[:tx_size]||2048
            @rx_size = param[:rx_size]||2048
            @tx_window = param[:tx_window]||7
            @rx_window = param[:rx_window]||7
            
            raise TypeError unless tx_size.kind_of? Integer and (0..2048).include? tx_size
            raise TypeError unless rx_size.kind_of? Integer and (0..2048).include? rx_size
            raise TypeError unless tx_window.kind_of? Integer and (1..7).include? tx_window
            raise TypeError unless rx_window.kind_of? Integer and (1..7).include? rx_window
            
        end
        
        def ==(other)
            tx_size == other.tx_size and rx_size == other.rx_size and tx_window == other.tx_window and rx_window == other.rx_window
        end
        
        # @return [String]
        def encode
        
            [
                HDLC_NEGOPARAMS_FORMAT,
                HDLC_NEGOPARAMS_GROUP,
                20,
                HDLC_NEGOPARAMS_MAXINFOTX,
                2,
                tx_size,
                HDLC_NEGOPARAMS_MAXINFORX,
                2,
                rx_size,
                HDLC_NEGOPARAMS_MAXWINDOWTX,
                4,
                tx_window,
                HDLC_NEGOPARAMS_MAXWINDOWRX,
                4,
                rx_window
            ].pack("C5S>C2S>C2L>C2L>")
            
        end               
        
        def self.get_int(input)
            output = 0
            input.read(1).unpack("C").first.times do
                output = output << 8
                output |= input.read(1).unpack("C").first
            end            
            output
        end
        
                    
        # unpack snrm parameters
        #
        # @note we only support two variants -
        #   either a one or two byte frame size and must be consistent
        #
        # @param input [String]
        #
        def self.decode(input)
            
            setting = {}
                
            raise TypeError unless input.kind_of? String
            
                i = StringIO.new(input)
                
                raise RangeError unless (i.read(1).unpack("C").first == HDLC_NEGOPARAMS_FORMAT)
                raise RangeError unless (i.read(1).unpack("C").first == HDLC_NEGOPARAMS_GROUP)
                
                group_size = i.read(1).unpack("C").first
                
                group = i.read(group_size)
                
                raise RangeError.new "input too short" unless group.size == group_size
                raise RangeError.new "snrm parameter must occupy entire payload" unless  i.pos == input.size
                
                i = StringIO.new group
                
                    loop do
                        
                        tag = i.read(1).unpack("C").first
                        
                        case tag
                        when HDLC_NEGOPARAMS_MAXINFOTX                        
                            setting[:tx_size] = get_int(i)                        
                        when HDLC_NEGOPARAMS_MAXINFORX            
                            setting[:rx_size] = get_int(i)                        
                        when HDLC_NEGOPARAMS_MAXWINDOWTX
                            setting[:tx_window] = get_int(i)                        
                        when HDLC_NEGOPARAMS_MAXWINDOWRX
                            setting[:rx_window] = get_int(i)                        
                        else
                            raise RangeError.new "unknown tag '#{tag}'"
                        end
                        
                        break unless not i.eof?
                            
                    end

                
            
            self.new(**setting)
            
        end
    
    end

end
