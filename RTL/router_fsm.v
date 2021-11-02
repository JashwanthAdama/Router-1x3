module router_fsm(clock,resetn,pkt_valid,data_in,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid,write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);
     input clock,resetn,pkt_valid,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid;
     input [1:0]data_in;
     output write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy;
parameter 
          DECODE_ADDRESS = 3'b000,
          LOAD_FIRST_DATA = 3'b001,
          LOAD_DATA = 3'b010,
          FIFO_FULL_STATE = 3'b011,
          LOAD_AFTER_FULL = 3'b100,
          LOAD_PARITY = 3'b101,
          CHECK_PARITY_ERROR = 3'b110,
          WAIT_TILL_EMPTY = 3'b111;

reg [2:0]state,next_state;
reg [1:0]temp;

always@(posedge clock)
      begin
          if(~resetn)
               temp<=2'b0;
          else if(detect_add)
               temp<=data_in;
      end  

always@(posedge clock)
      begin
                 if(!resetn)
                     state<= DECODE_ADDRESS;
                 else if((soft_reset_0 && (temp==2'b00)) || (soft_reset_1 && (temp==2'b01)) || (soft_reset_2 && (temp==2'b10)))
                     state<= DECODE_ADDRESS;
                 else
                     state<= next_state;  
      end

always@(*)
      begin
           next_state= DECODE_ADDRESS;
            case(state)
               DECODE_ADDRESS :    
                                  if((pkt_valid && (data_in[1:0]==2'b00)) && fifo_empty_0 || (pkt_valid && (data_in[1:0]==2'b01)) && fifo_empty_1 || (pkt_valid && (data_in[1:0]==2'b10)) && fifo_empty_2)
                                         next_state=LOAD_FIRST_DATA;
                                  else if((pkt_valid && (data_in[1:0]==2'b00)) && ~fifo_empty_0 || (pkt_valid && (data_in[1:0]==2'b01)) && ~fifo_empty_1 || (pkt_valid && (data_in[1:0]==2'b10)) && ~fifo_empty_2)
                                         next_state=WAIT_TILL_EMPTY;
                                  else
                                         next_state=DECODE_ADDRESS;
  
               LOAD_FIRST_DATA :        
                                         next_state=LOAD_DATA; 
                                         

               LOAD_DATA :       
                                 if(fifo_full==1)
                                         next_state=FIFO_FULL_STATE;
                                  else if(fifo_full==0 && pkt_valid==0)
                                         next_state=LOAD_PARITY;
                                  else
                                        next_state=LOAD_DATA;
                                 

              FIFO_FULL_STATE :    
                                  if(fifo_full==0)
                                         next_state=LOAD_AFTER_FULL;
                                  else
                                         next_state=FIFO_FULL_STATE;
                                 

              LOAD_AFTER_FULL :   
                                  if(parity_done==0 && low_packet_valid==1)
                                         next_state=LOAD_PARITY;
                                  else if(parity_done==0 && low_packet_valid==0)
                                         next_state=LOAD_DATA;
                                  else if(parity_done==1)
                                         next_state=DECODE_ADDRESS;
                                  

             LOAD_PARITY :             
                                    next_state=CHECK_PARITY_ERROR;
                                         
 
             CHECK_PARITY_ERROR :   
                                  if(fifo_full==1)
                                        next_state=FIFO_FULL_STATE;
                                  else
                                        next_state=DECODE_ADDRESS;
                                   

             WAIT_TILL_EMPTY :    
                                 if((fifo_empty_0 && (temp==2'b00)) || (fifo_empty_1 && (temp==2'b01)) || (fifo_empty_2 && (temp==2'b10)))
                                        next_state=LOAD_FIRST_DATA;
                                 else
                                        next_state=WAIT_TILL_EMPTY;
                                  

            default :                  
                                next_state=DECODE_ADDRESS;
                                        
       endcase
   end

assign write_enb_reg = ((state == LOAD_DATA) || (state == LOAD_AFTER_FULL) || (state == LOAD_PARITY));
assign detect_add = (state == DECODE_ADDRESS);
assign ld_state = (state == LOAD_DATA);
assign laf_state = (state == LOAD_AFTER_FULL);
assign lfd_state = (state == LOAD_FIRST_DATA);
assign full_state = (state == FIFO_FULL_STATE);
assign rst_int_reg = (state == CHECK_PARITY_ERROR);
assign busy = ((state == LOAD_FIRST_DATA) || (state == FIFO_FULL_STATE) || (state == LOAD_AFTER_FULL) || (state ==  LOAD_PARITY) || (state ==  CHECK_PARITY_ERROR) || (state == WAIT_TILL_EMPTY));

endmodule        