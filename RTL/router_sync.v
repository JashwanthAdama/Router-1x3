module router_sync(clock,resetn,data_in,detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,write_enb,fifo_full,vld_out_0,vld_out_1,vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2);
       input clock,resetn,detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg,read_enb_0,read_enb_1,read_enb_2;
       input [1:0]data_in;
       output reg fifo_full;
       output vld_out_0,vld_out_1,vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2;
       output reg [2:0]write_enb;
       reg[1:0]temp;
       reg[4:0]counter_0,counter_1,counter_2;

always@(posedge clock)
       begin
               if(!resetn)
               temp <= 2'b11;
               else if(detect_add) 
               temp <= data_in;
               else 
               temp <= temp;
       end
always@(*)
	begin
		case(temp)
			2'b00: fifo_full<=full_0;                                // fifo fifo_full logic
			2'b01: fifo_full<=full_1;                                
			2'b10: fifo_full<=full_2;				
			default: fifo_full<=1'b0;
		endcase
	end

assign vld_out_0 = ~empty_0;
assign vld_out_1 = ~empty_1;
assign vld_out_2 = ~empty_2;

	                                                                      
always@(*)                                                                    //write_enb_reb logic	
         begin 
				if(write_enb_reg)
				   begin
                        		case(temp)
						2'b00: write_enb<=3'b001;				
						2'b01: write_enb<=3'b010;
						2'b10: write_enb<=3'b100;
						default: write_enb<=3'b000;
					endcase
				    end
				else
					write_enb <= 3'b000;		
	end

//counter logic
always@(posedge clock)
       begin
                if(!resetn) 
                     {counter_0,counter_1,counter_2} = 0;
                     
                else
                    case(temp)
                              2'b00: begin
                                         if(vld_out_0 && (!read_enb_0) && (!soft_reset_0))
                                                   counter_0<=counter_0 + 1;
                                         else
                                                   counter_0<=0;
                                     end

                               2'b01: begin
                                         if(vld_out_1 && (!read_enb_1) && (!soft_reset_1))
                                                   counter_1<=counter_1 + 1;
                                         else
                                                   counter_1<=0;
                                     end

                               2'b10: begin
                                         if(vld_out_2 && (!read_enb_2) && (!soft_reset_2))
                                                   counter_2<=counter_2 + 1;
                                         else
                                                   counter_2<=0;
                                     end

                              default: {counter_0,counter_1,counter_2} = 0;
                     endcase
       end
 
assign soft_reset_0 = counter_0>=30;
assign soft_reset_1 = counter_1>=30;
assign soft_reset_2 = counter_2>=30;

endmodule