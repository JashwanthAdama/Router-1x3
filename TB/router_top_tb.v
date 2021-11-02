module router_top_tb();
    reg clock,resetn,pkt_valid,read_enb_0,read_enb_1,read_enb_2;
    reg [7:0]data_in;
    wire vld_out_0,vld_out_1,vld_out_2,err,busy;
    wire [7:0]data_out_0,data_out_1,data_out_2;
    
    integer i;
  router_top DUT(clock,resetn,data_in,pkt_valid,read_enb_0,read_enb_1,read_enb_2,data_out_0,
                  data_out_1,data_out_2,vld_out_0,vld_out_1,vld_out_2,err,busy);
initial
       begin
           clock=0;
           forever 
           #5 clock=~clock;
       end

task initialize;
        begin
              data_in=8'd0;
              pkt_valid=1'b0;
              read_enb_0=1'b0;
              read_enb_1=1'b0;
              read_enb_2=1'b0;
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


task pkt_gen_14;
  reg[7:0]payload_data,parity,header;
  reg[5:0]payload_len;
  reg[1:0]addr;
begin
@(negedge clock);
  wait(~busy)

@(negedge clock);
payload_len=6'd14;
addr=2'b00;    //valid packet
header={payload_len,addr};
parity=8'd0;
data_in=header;
pkt_valid=1'b1;
parity=parity^data_in;

@(negedge clock);
wait(~busy)
for(i=0;i<payload_len;i=i+1)
begin
@(negedge clock);
wait(~busy)
payload_data={$random}%256;
data_in=payload_data;
parity=parity^data_in;
end
@(negedge clock);
wait(~busy)
pkt_valid=1'b0;
data_in=parity;
end
endtask

task pkt_gen_16;
  reg[7:0]payload_data,parity,header;
  reg[5:0]payload_len;
  reg[1:0]addr;
begin
@(negedge clock);
  wait(~busy)

@(negedge clock);
payload_len=6'd16;
addr=2'b01;    //valid packet
header={payload_len,addr};
parity=8'd0;
data_in=header;
pkt_valid=1'b1;
parity=parity^data_in;

@(negedge clock);
wait(~busy)
for(i=0;i<payload_len;i=i+1)
begin
@(negedge clock);
wait(~busy)
payload_data={$random}%256;
data_in=payload_data;
parity=parity^data_in;
end
@(negedge clock);
wait(~busy)
pkt_valid=1'b0;
data_in=parity;
end
endtask

initial
    begin
       initialize;
       Resetn;
       pkt_gen_14;
       repeat(2)
       @(negedge clock);
       read_enb_0=1'b1;
       wait(~vld_out_0)
       @(negedge clock)
       read_enb_0=1'b0;
       

       pkt_gen_16;
       repeat(2)
       @(negedge clock)
       read_enb_1=1'b1;
       wait(~vld_out_1)
       @(negedge clock)
       read_enb_1=1'b0;

       #100 $finish;
       end
initial
$monitor("clock=%b,resetn=%b,read_enb_0=%b,read_enb_1=%b,read_enb_2=%b,pkt_valid=%b,data_in=%b,data_out_0=%b,data_out_1=%b,data_out_2=%b,vld_out_0=%b,vld_out_1=%b,vld_out_2=%b,err=%b,busy=%b",clock,resetn,read_enb_0,read_enb_1,read_enb_2,pkt_valid,data_in,data_out_0,data_out_1,data_out_2,vld_out_0,vld_out_1,vld_out_2,err,busy);
endmodule
      