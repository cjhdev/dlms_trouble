require 'time'

module DLMSTrouble::HDLC

    class FrameDecoder
    
        include Checksum
    
        attr_reader :src
        attr_reader :dest
        attr_reader :control
        attr_reader :info
        attr_reader :rx
        attr_reader :segment
        
        def initialize(**attr)
            
            @dest = nil
            @src = nil
            @control = nil
            @info = nil
            @segment = false
            
            @rx = ""
            
            @state = :idle
            checksum_init
            @time = Time.now
        
            if attr.has_key? :tio
                @tio = attr[:tio]
                raise TypeError unless @tio.kind_of? Numeric and @tio > 0
            else
                @tio = 1.0
            end
            
            if attr.has_key? :logger
                @logger = attr[:logger]
                raise TypeError unless @logger.respond_to? :error            
            end
            
        end
        
        def push_block(block, &handler)
            
            raise TypeError unless block.kind_of? String
            
            block.bytes.each do |b|
                push(b, &handler)
            end
            
            self
            
        end
        
        # push a byte into the decoder
        #
        # @param b [Integer]
        # @return [self]
        def push(b)
        
            timeNow = Time.now
            
            if (@time - timeNow) > @tio
                @state = :idle                
            end
            
            @time = timeNow
            
            case @state
            when :idle
            
                if b == Frame::FRAME_CHAR
                    @state = :fsize_b1
                    @rx = ""
                    @info = ""
                end
                
            when :fsize_b1
            
                checksum_init
                checksum_next(b)
                @rx << b
            
                if (b & 0xf0) != 0xa0
            
                    if b != FRAME::FRAME_CHAR

                        log_error "first byte of frame is invalid"
                        @state = :start_frame;
                    
                    end
                        
                else
            
                    @frame_size = ( (b & 0x7) << 8 )
                    @segment = ( ((b & 0x8) == 0x8) ? true : false )
                    @state = :fsize_b2
                
                end
            
            when :fsize_b2

                checksum_next(b)
                @rx << b

                @frame_size |= b                

                if @frame_size < 6
                    log_error "frame will be too short"
                    @state = :start_frame
                else
                    @state = :dest_b1
                end
                            
            when :dest_b1
            
                checksum_next(b)
                @rx << b
            
                if (b & 1) == 1
                    @dest = OneByte.new(b >> 1)
                    @state = :src_b1
                else
                    @state = :dest_b2
                end
            
            when :dest_b2
            
                checksum_next(b)
                @rx << b
            
                if (b & 1) == 1
                    @dest = TwoByte.new(@rx[-2].to_i >> 1, b >> 1)
                    @state = :src_b1
                else
                    @state = :dest_b3
                end
            
            when :dest_b3
            
                checksum_next(b)
                @rx << b
            
                if (b & 1) == 1                
                    log_error "invalid address length"
                    @state = :idle
                else
                    @state = :dest_b4
                end
                
            when :dest_b4
            
                checksum_next(b)
                @rx << b
            
                if (b & 1) == 1                
                    @dest = FourByte.new((@rx[-4].to_i << 8) | @rx[-3].to_i, (@rx[-2].to_i << 8) | b)
                    @state = :src_b1
                else
                    log_error "invalid address length"
                    @state = :idle
                end
                
            when :src_b1
            
                checksum_next(b)
                @rx << b
            
                if (b & 1) == 1
                    @src = OneByte.new(b >> 1)
                    @state = :control
                else
                    @state = :src_b2
                end
            
            when :src_b2
            
                checksum_next(b)
                @rx << b
            
                if (b & 1) == 1
                    @src = TwoByte.new(@rx[-2].to_i >> 1, b >> 1)
                    @state = :control
                else
                    @state = :src_b3
                end
            
            when :src_b3
            
                checksum_next(b)
                @rx << b
            
                if (b & 1) == 1                
                    log_error "invalid address length"
                    @state = :idle
                else
                    @state = :src_b4
                end
                
            when :src_b4
            
                checksum_next(b)
                @rx << b
            
                if (b & 1) == 1                
                    @src = FourByte.new((@rx[-4].to_i << 8) | @rx[-3].to_i, (@rx[-2].to_i << 8) | b)
                    @state = :control
                else
                    log_error "invalid address length"
                    @state = :idle
                end
            
            when :control
            
                checksum_next(b)
                @rx << b
                @control = b
                @state = :hcs_b1
                
            when :hcs_b1
            
                checksum_next(b)
                @rx << b                
                @state = :hcs_b2
                
            when :hcs_b2
            
                checksum_next(b)
                @rx << b                
                
                if @fcs != 0xf0b8
                
                    log_error "invalid HCS"
                    @state = :start_frame
                    
                elsif @frame_size == @rx.size
                
                    @state = :end_frame
                    
                else
                
                    @state = :info
                    
                end
                
            when :info
            
                checksum_next(b)
                @rx << b  
                @info << b              
            
                if @rx.size == (@frame_size - 2)
                    
                    @state = :fcs_b1
                    
                end
            
            when :fcs_b1
            
                checksum_next(b)
                @rx << b  
                @state = :fcs_b2
            
            when :fcs_b2
            
                checksum_next(b)
                @rx << b 
                @state = :end_frame
            
            when :end_frame
            
                if b == Frame::FRAME_CHAR
                
                    if @fcs == 0xf0b8
                    
                        begin
                            
                            f = Frame.from_decoder(self)
                            
                            # todo enforce rules for which frames are allowed certain fields
                            
                            yield(f) if block_given?
                            
                        rescue => e
                            log_error "#{e.exception}: #{e.message}"
                            log_error e.backtrace.join("\n")
                        end
                        
                    else
                    
                        log_error "invalid fcs"
                    
                    end
                
                else
                
                    log_error "expecting end of frame"
                
                end
                
                @state = :idle
                
            end
            
            self
            
        end
    
        def checksum_next(b)
            @fcs = (@fcs >> 8) ^ checksum( ( @fcs ^ b ) & 0xff )
        end
        
        def checksum_init
            @fcs = 0xffff
        end
        
        def log_error(msg)
            if @logger
                @logger.error msg
            end
        end
        
        private :checksum_init, :checksum_next, :log_error
    
    end
    
end
