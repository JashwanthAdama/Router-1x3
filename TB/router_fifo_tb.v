module router_fifo_tb;
reg [7:0]data_in;
reg clock, resetn, write_enb, read_enb, lfd_state, soft_reset;
wire [7:0]data_out;
wire full,empty;
reg[4:0]wrptr,rdptr;
reg[6:0]counter;
integer k;
router_fifo DUT(clock, resetn, write_enb, read_enb, lfd_state,soft_reset,data_in,full, empty,data_out);
initial
begin
clock=0;
forever #5 clock=~clock;
end

task initialize;
   begin
     {write_enb,soft_reset,read_enb,data_in,lfd_state,counter}=0;
      wrptr=0;
      rdptr=0;
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

task Soft_Reset;
    begin
@(negedge clock)
soft_reset=1'b1;
@(negedge clock)
soft_reset=1'b0;
    end
endtask

task write;
reg[7:0]payload_data,parity,header;
reg[5:0]payload_len;
reg[1:0]addr;
begin
@(negedge clock);
payload_len=6'd14;
addr=2'b01;
header={payload_len,addr};
data_in=header;
lfd_state=1'b1;
write_enb=1;

for(k=0;k<payload_len;k=k+1)
begin
@(negedge clock)
lfd_state=0;

payload_data={$random}%256;
data_in=payload_data;
end

@(negedge clock)
parity={$random}%256;
data_in=parity;
end
endtask

task read(input i,j);
begin
@(negedge clock)
write_enb=1'b0;
read_enb=1'b1;
end
endtask

initial
begin
initialize;
Resetn;
Soft_Reset;
write;
read(0,1);
#200 $finish;
end

initial
$monitor("clock=%b,resetn=%b,write_enb=%b,read_enb=%b,data_in=%b,lfd_state=%b,empty=%b,full=%b,data_out=%b",clock,resetn,write_enb,read_enb,data_in,lfd_state,empty,full,data_out);
endmodule