module router_sync_tb();
       reg clock,resetn,detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg,read_enb_0,read_enb_1,read_enb_2;
       reg [1:0]data_in;
       wire fifo_full;
       wire vld_out_0,vld_out_1,vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2;
       wire [2:0]write_enb;
router_sync DUT(clock,resetn,data_in,detect_add,full_0,full_1,full_2,
                empty_0,empty_1,empty_2,write_enb_reg,read_enb_0,read_enb_1,
				read_enb_2,write_enb,fifo_full,vld_out_0,vld_out_1,vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2);    
initial
       begin
           clock=0;
           forever 
           #5 clock=~clock;
       end

task Resetn;
       begin
           @(negedge clock)
           resetn=1'b0;
           @(negedge clock)
           resetn=1'b1;
      end
endtask
task write_enb_s;	                             //write_enb_reg
	begin
	write_enb_reg=1'b1; 
	@(negedge clock);
	//write_enb_reg=1'b0;
	end
	endtask
	
task data(input[1:0]m);
		begin
		data_in=m;
		#10;
		end
endtask
		
	initial
	begin

      Resetn;
	data(00);
	detect_add=1'b1;
	read_enb_0=1'b0;
	read_enb_1=1'b0;
	read_enb_2=1'b1;
	write_enb_s;
	full_0=1'b1;
	full_1=1'b0;
	full_2=1'b0;
	empty_0=1'b0;
	empty_1=1'b1;
	empty_2=1'b1;
	#300;
	#600;
	
   	data(01);
	detect_add=1'b1;
	read_enb_0=1'b0;
	read_enb_1=1'b0;
	read_enb_2=1'b1;
	write_enb_s;
	full_0=1'b0;
	full_1=1'b1;
	full_2=1'b0;
	empty_0=1'b1;
	empty_1=1'b0;
	empty_2=1'b1;
	#300;
	#600;

  
	data(10);
	detect_add=1'b1;
	read_enb_0=1'b1;
	read_enb_1=1'b0;
	read_enb_2=1'b0;
	write_enb_s;
	full_0=1'b0;
	full_1=1'b0;
	full_2=1'b1;
	empty_0=1'b1;
	empty_1=1'b1;
	empty_2=1'b0;
	#300;
	#600;
	
	#1000 $finish;
	end
initial
  begin
          $monitor($time,"clock=%b,resetn=%b,data_in=%b,detect_add=%b,full_0=%b,full_1=%b,full_2=%b,empty_0=%b,empty_1=%b,empty_2=%b,write_enb_reg=%b,read_enb_0=%b,read_enb_1=%b,read_enb_2=%b,write_enb=%b,fifo_full=%b,vld_out_0=%b,vld_out_1=%b,vld_out_2=%b,soft_reset_0=%b,soft_reset_1=%b,soft_reset_2=%b",clock,resetn,data_in,detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,write_enb,fifo_full,vld_out_0,vld_out_1,vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2) ;
  end

endmodule