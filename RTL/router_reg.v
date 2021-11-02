module router_reg(clock,resetn,pkt_valid,data_in,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg,err,parity_done,low_packet_valid,dout);
         input clock,resetn,pkt_valid,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg;
         input [7:0] data_in;
         output reg err,parity_done,low_packet_valid;
         output reg [7:0] dout;
         reg [7:0] hold_header_byte, FIFO_full_state_byte, internal_parity, packet_parity_byte;
//parity_done logic
always@(posedge clock)                                              
      begin                                    
            if(~resetn)
                    parity_done <=1'b0;
            else if(ld_state && !fifo_full && !pkt_valid)
                    parity_done <=1'b1;
            else if(laf_state && low_packet_valid && !parity_done)
                     parity_done <=1'b1;
            else
               begin
                    if(detect_add)
                        parity_done <=1'b0;
               end
      end
//low_packet_valid logic
always@(posedge clock)                                            
      begin
            if(~resetn)
                   low_packet_valid <= 1'b0;
            else if(rst_int_reg)
                   low_packet_valid <= 1'b0;
            else if(ld_state && !pkt_valid)
                   low_packet_valid <= 1'b1;
      end
//dout logic
always@(posedge clock)                                            
      begin
            if(~resetn)
                 dout <=8'b00000000;  
            else
               begin
                   if(detect_add && pkt_valid)
                        hold_header_byte <= data_in;
                   else if(lfd_state)
                         dout <= hold_header_byte;
                   else if(ld_state && !fifo_full)
                         dout <= data_in;
                   else if(ld_state && fifo_full)
                         FIFO_full_state_byte <= data_in;
                   else
                       begin
                            if(laf_state)
                                    dout <=  FIFO_full_state_byte;
                       end
               end
        end
//internal_parity logic
always@(posedge clock)                                                 
         begin
             if(~resetn)
                    internal_parity <= 8'b00000000;     
             else if(lfd_state)
                    internal_parity <= internal_parity ^ hold_header_byte;
             else if(ld_state && !full_state && pkt_valid)
                    internal_parity <= internal_parity ^ data_in;
             else
                begin
                  if(detect_add)
                    internal_parity<=8'b0;
                end
         end
 //packet_parity_byte logic
always@(posedge clock)                                               
         begin
              if(~resetn)
                    packet_parity_byte <= 8'b00000000;
              else if(ld_state && ~pkt_valid)
                     packet_parity_byte <= data_in;
          end

 //err logic  
always@(posedge clock)                                            
         begin
              if(~resetn)
                     err <=1'b0;
              else if(parity_done)
                  begin
                      if(internal_parity != packet_parity_byte)
                               err <=1'b1;
                      else
                               err <=1'b0;
                  end
          end

endmodule     