module router_fsm_tb();
    reg clock,resetn,pkt_valid,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid;
    reg [1:0]data_in;
    wire write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy;
    parameter CYCLE =10;

router_fsm DUT(clock,resetn,pkt_valid,data_in,fifo_full,fifo_empty_0,fifo_empty_1,
fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid,write_enb_reg,
detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);

   initial
       begin
              clock=0;
          forever 
              #(CYCLE/2)  clock=~clock;
       end

task Resetn;
       begin
           @(negedge clock)
           resetn=1'b0;
           @(negedge clock)
           resetn=1'b1;
      end
endtask

task initialize;
      begin
          pkt_valid = 1'b0;
          data_in = 2'b00;
          fifo_full = 1'b0;
          fifo_empty_0 = 1'b0;
          fifo_empty_1 = 1'b0;
          fifo_empty_2 = 1'b0;
          soft_reset_0 = 1'b0;
          soft_reset_1 = 1'b0;
          soft_reset_2 = 1'b0;
          parity_done = 1'b0;
          low_packet_valid = 1'b1;
      end
endtask
  
//path-DA/LFD/LD/LP/CPE/DA 
task t1();         
      begin
         @(negedge clock)   
         pkt_valid = 1'b1;
         data_in = 2'b01;
         fifo_empty_1 = 1'b1;
         @(negedge clock)   
         @(negedge clock)   
         fifo_full = 1'b0;
         pkt_valid = 1'b0;
         @(negedge clock)    
         @(negedge clock)    
         fifo_full = 1'b0;    
      end
endtask

//path-DA/LFD/LD/FFS/LAF/LP/CPE/DA 
task t2();             
     begin
         @(negedge clock)
         pkt_valid = 1'b1;
         data_in = 2'b00;
         fifo_empty_0 = 1'b1;
         @(negedge clock)
         @(negedge clock)
         fifo_full = 1'b1;
         @(negedge clock)
         @(negedge clock)
         fifo_full = 1'b0;
         @(negedge clock)
         @(negedge clock)
         parity_done = 1'b0;
         low_packet_valid = 1'b1;
         @(negedge clock)
         @(negedge clock)
         fifo_full = 1'b0;
      end
endtask

//path-DA/LFD/LD/FFS/LD/LP/CPE/DA
task t3();                     
     begin
         @(negedge clock)
         pkt_valid = 1'b1;
         data_in = 2'b10;
         fifo_empty_2 = 1'b1;
         @(negedge clock)
         @(negedge clock)
         fifo_full = 1'b1;
         @(negedge clock)
         @(negedge clock)
         fifo_full = 1'b0;
         @(negedge clock)
         @(negedge clock)
         parity_done = 1'b0;
         low_packet_valid = 1'b0;
         @(negedge clock)
         @(negedge clock)
         fifo_full = 1'b0;
         pkt_valid = 1'b0;
         @(negedge clock)
         @(negedge clock)
         fifo_full = 1'b0; 
      end
endtask

//path-DA/LFD/LD/LP/CPE/FFS/LAF/LP/DA
task t4();                      
      begin
         @(negedge clock)
         pkt_valid = 1'b1;
         data_in = 2'b01;
         fifo_empty_1 = 1'b1;
         @(negedge clock)
         @(negedge clock)
         fifo_full = 1'b0;
         pkt_valid = 1'b0;
         @(negedge clock)
         @(negedge clock)
         fifo_full = 1'b0;
         @(negedge clock)
         @(negedge clock)
         fifo_full = 1'b1;
         @(negedge clock)
         @(negedge clock)
         fifo_full = 1'b0;
         @(negedge clock)
         @(negedge clock)
         parity_done = 1'b1;
     end
endtask

initial
   begin
       initialize;
       Resetn;
        t1;
        #40;
        t2;
        #40;
        t3;
        #40;
        t4;
        #1000 $finish;
    end
initial
$monitor("clock=%b,resetn=%b,pkt_valid=%b,data_in=%b,fifo_full=%b,fifo_empty_0=%b,fifo_empty_1=%b,fifo_empty_2=%b,soft_reset_0=%b,soft_reset_1=%b,soft_reset_2=%b,parity_done=%b,low_packet_valid=%b,write_enb_reg=%b,detect_add=%b,ld_state=%b,laf_state=%b,lfd_state=%b,full_state=%b,rst_int_reg=%b,busy=%b",clock,resetn,pkt_valid,data_in,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid,write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);
endmodule