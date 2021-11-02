module router_reg_tb();
   reg clock,resetn,pkt_valid,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg;
   reg [7:0] data_in;
   wire err,parity_done,low_packet_valid;
   wire [7:0] dout;
   integer k;

router_reg DUT(clock,resetn,pkt_valid,data_in,fifo_full,detect_add,ld_state,laf_state,
               full_state,lfd_state,rst_int_reg,err,parity_done,low_packet_valid,dout);

initial
       begin
           clock=0;
           forever 
           #5 clock=~clock;
       end

task initialize;
        begin
          pkt_valid=1'b0;
          data_in=2'b00;
          fifo_full=1'b0;
          detect_add=1'b0;
          ld_state=1'b0;
          laf_state=1'b0;
          full_state=1'b0;
          lfd_state=1'b0;
          rst_int_reg=1'b0;
       end
endtask

task Resetn;
       begin
           @(negedge clock)
           resetn=1'b0;
           @(negedge clock)
           resetn=1'b1;
      end
endtask

task goodpkt_gen;
reg[7:0]payload_data,parity,header;
reg[5:0]payload_len;
reg[1:0]addr;
begin
@(negedge clock);
payload_len=6'd14;
addr=2'b01;
parity=8'b00000000;
detect_add=1'b1;
pkt_valid=1'b1;
header={payload_len,addr};
data_in=header;
parity=parity^data_in;

@(negedge clock)
detect_add=1'b0;
lfd_state=1'b1;
for(k=0;k<payload_len;k=k+1)
begin
@(negedge clock)
lfd_state=0;
ld_state=1'b1;

payload_data={$random}%256;
data_in=payload_data;
parity=parity^data_in;
end

@(negedge clock)
pkt_valid=1'b0;
data_in=parity;

@(negedge clock)
ld_state=1'b0;
end
endtask

task badpkt_gen;
reg[7:0]payload_data,parity,header;
reg[5:0]payload_len;
reg[1:0]addr;
begin
@(negedge clock);
payload_len=6'd14;
addr=2'b01;
parity=8'b00000000;
detect_add=1'b1;
pkt_valid=1'b1;
header={payload_len,addr};
data_in=header;
parity=parity^data_in;

@(negedge clock)
detect_add=1'b0;
lfd_state=1'b1;
for(k=0;k<payload_len;k=k+1)
begin
@(negedge clock)
lfd_state=1'b0;
ld_state=1'b1;

payload_data={$random}%256;
data_in=payload_data;
parity=parity^data_in;
end

@(negedge clock)
pkt_valid=1'b0;
data_in=~parity;

@(negedge clock)
ld_state=1'b0;
end
endtask

initial
    begin
       initialize;
       Resetn;
       goodpkt_gen;
       #170;
       
       badpkt_gen;
       #1000 $finish;
    end

initial
   $monitor("clock=%b,resetn=%b,pkt_valid=%b,data_in=%b,fifo_full=%b,detect_add=%b,ld_state=%b,laf_state=%b,full_state=%b,lfd_state=%b,rst_int_reg=%b,err=%b,parity_done=%b,low_packet_valid=%b,dout=%b,internal_parity=%b,packet_parity_byte=%b",clock,resetn,pkt_valid,data_in,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg,err,parity_done,low_packet_valid,dout,DUT.internal_parity,DUT.packet_parity_byte);
endmodule