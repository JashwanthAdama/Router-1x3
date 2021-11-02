# Router-1x3 By Jashwanth Chandhra Adama
Router is a device that forwards data packets between computer networks.It is an OSI layer 3 routing device.
It drives an incoming packet to an output channel based on the address field contained in the packet header
It contains five modules inside it.They are
1.FIFO (16x9)
2.Synchronizer
3.FSM
4.Register
5.TOP Module

Specifications of ROUTER 1x3
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ROUTER INPUT PROTOCOL:

1.All input signals are active high except low reset and are synchronized to the falling edge of the
clock. This is because the DUT router is sensitive to the rising edge of the clock. Therefore, in the testbench,
driving input signals on the falling edge ensures setup and hold time. But in the system Verilog/UVM based
testbench, clocking block can be used to drive the signals on the positive edge of the clock itself and thus avoids
metastability.

2.The packet_valid signal is asserted on the same clock edge when the header byte driven onto the input data bus.

3. Since the header byte contains the address, this the router to which output channel the packet should be routed to
(data_out_0, data_out_1, data_out_2).

4. Each subsequent byte of payload after header byte should be driven on the input data bus for every new falling
edge of the clock.

5.After the last payload byte has been driven, on the next falling edge of the clock, the packet_valid signal must be
de-asserted, and the packet parity should be driven. This signals packet completion.

6.The testbench shouldn`t drive any byte when busy signal is detected instead it should hold the last driven values.

7. The `busy` signal when asserted drops any incoming byte of the data.

8. The “err” signal is asserted when a packet parity mismatch is detected.

____________________________________________________________________________________________________________________________________________________


ROUTER OUTPUT PROTOCOL:

1. All output signals are active high and are synchronized to the rising edge of the clock.

2. Each output port data_out_X (data_out_0, data_out_1, data_out_2) is internally buffered by a FIFO of size 16X9.

3.The router asserts the vld_out_X (vld_out_0, vld_out_!, vld_out_2) signal when valid data appears on the
vld_out_X(data_out_0,data_out_1,data_out_2) output bus. This is a signal to the receiver’s client which indicates
the data is available on a particular output data bus.

4.The packet receiver will then wait until it has enough space to hold the bytes of the packet and then respond with
the assertion of the read_enb_X(read_enb_0.read_enb_1,read_enb_2) signal.

5.The read_enb_X(read_enb_0,read_enb_`1 or read_enb_2) input signal can be asserted on the falling clock edge in
which data are read from the data_out_X(data_out_0,data_out_1,data_out_2)bus.

6.The read_enb_X(read_enb_0,read_out_1 or read_out_2) must be asserted within 30 clock cycles of the
vld_out_X(vld_out_0,vld_out_1,vld_out_2) being asserted else time-out occurs, which resets the FIFO.

7.The data_out_X (data_out_0,data_out_1 or data_out_2) bus will be tri-stated(high Z) during a scenario when a
packet’s header byte is lost due to time-out condition .

_______________________________________________________________________________________________________________________________________________

FIFO:

Functionality:

There are 3 FIFOs used in the router design. Each FIFO is of 9 bits wide and 16 bit bytes depth. The FIFO
works on the system clock and is reset with a synchronizer active low reset.The FIFO is also internally reset by an
internal reset signal soft_reset. Soft_reset is an active high signal which is generated by the SYNCHRONIZER block
during time out state of the ROUTER.

If resetn is low then full=0, empty=1 and data_out=0.

The FIFO m/m size is 16X9. The extra bit in the data width is appended in order to detect the header byte. Lfd_state
detects the header byte of a packet.

The 9th bit is 1 for header byte and 0 for the remaining bytes.

Write Operation:
1.Signal data_in is sampled at the rising edge of the edge of the clock when write_enb is high.
2.Write operation only takes place when FIFO is not full in order to avoid over_run condition.

Read operation:
3.The data is read from data_out at rising edge of the clock, when read_enb is high.
4. Read operation only takes place when the FIFO is not empty in order to avoid under run condition.
5.During the read operation when a header byte is read, an internal counter is loaded with the payload
length of the packet plus ‘1’ (parity byte) and starts decrementing every clock till it reached 0. The
counter holds 0 till it is reloaded back with a new packet payload length.
6.During the time out condition, full=0, empty=1.
7.data out is driven to HIGH impedance state under 2 scenarios:
 When the fifo m/m is read completely (header+payload+parity).
 Under the time out condition of the Router.
8.Full- FIFO status which indicates that all the locations inside FIFO have been written.
9.Empty- FIFO status which indicates that all the locations of the FIFO have been read and made empty.
10. Read and write operation can be done simultaneously

___________________________________________________________________________________________________________________________________
ROUTER FSM:


STATE-DECODE_ADDRESS
1. This is the initial reset state.
2.Signal detect_add is asserted in this state which is used to detect an incoming packet. It is also used to latch
the first byte as a header byte.

STATE-LOAD_FIRST_DATA
1.Signal lfd_state is asserted in this state which is used to load the first data byte to the FIFO.
2.Signal busy is also asserted in this state so that header byte that is already latched doesn’t update to a new
value for the current packet.
3.This state is changed to LAOD_DATA state unconditionally in the next clock cycle.

STATE-LOAD_DATA
1.In this state the signal ld_state is asserted which is used to load the payload data to the FIFO.
2.Signal busy is de asserted in this state, so that ROUTER can receive the new data from input source every
clock cycle,
3.Signal write_enb_reg is asserted in this state in order to write the Packet information(Header+Payload+Parity)
to the selected FIFO.
4.This state transits to LAOD_PARITY state when pkt_valid goes low and to FIFO_FULL_STATE when FIFO
is full.

STATE-LOAD_PARITY
 In this state the last byte is latched which is the parity byte.
 It goes unconditionally to the state CHECK_PARITY_ERROR.
 Signal busy is asserted so that ROUTER doesn’t accepts any new data.
 write_enb_reg is made high for latching the parity byte to FIFO.

STATE-FIFO_FULL_STATE
1. busy signal is made high and write_enb_reg signal is made low.
2.Signal full_state is asserted which detects the FIFO full state.

STATE-LOAD_AFTER_FULL
1.In this state laf_state signal is asserted which is used to latch the data after FIFO_FULL_STATE.
2.Signal busy & write_enb_reg is asserted.
3.It checks for parity_done signal and if it is high, shows that LOAD_PARITY state has been detected and it
goes to the state DECODE_ADDRESS.
4.If low_packet_valid is high it goes to LOAD_PARITY state otherwise it goes back to the LOAD_DATA state.

STATE-WAIT_TILL_EMPTY
1.Busy signal is made high and write_enb_reg signal is made low.

STATE-CHECK_PARITY_ERROR
1.In this state rst_int_reg signal is generated, which is used to reset low_packet_valid signal.
2.This state changes to DECODE_ADDRESS when FIFO is not full and to FIFO_FULL_STATE when FIFO is
full.
3.Busy is asserted in this state.
_____________________________________________________________________________________________________________________________________

SYNCHRONISER

This module provides synchronization between router FSM and router FIFO modules. It provides faithful
communication between the single input port and three output ports.
1. detect_add and data_in signals are used to select a FIFO till a packet routing is over for the selected FIFO.
2.Signal fifo_full signal is asserted based on full_status of fifo_0 or FIFO_1 or FIFO_2.
3.If data_in =2’b00 then fifo_full=full_0
4.If data_in=2’b01 then fifo_full=full_1
5.If data_in=2’b10 then fifo_full=full_2 else fifo_full=0
6.The signal vld_out_x signal is generated based on empty status of the FIFO as shown below :
7.vld_out_0=~empty_0
8.vld_out_1=~empty_1
9.vld_out_2=~empty_2
10.The write_enb_reg signal is used to generate write_enb signal for the write operation of the selected FIFO.
11.There are 3 internal reset signals (soft_reset_0, soft_reset_1, soft_reset_2) for each of the FIFO respectively.
The respective internal reset signals goes high if read_enb_X (read_enb_0,read_out_1,read_out_2) is not asserted
within 30 clock cycles of the vld_out_X(vld_out_0,vld_out_1 or vld_out_2) being asserted respectively.
________________________________________________________________________________________________________________________________

REGISTER

This module implements 4 internal registers in order to hold a header byte, FIFO full state byte, internal parity and
packet parity byte. All the registers in this module are latched on the rising edge of the clock.
1.If resetn is low then the signals (dout,err,parity_done and low_pkt_valid) are low.

2.The signal parity_done is high under the following conditions:
 	 When signal ld_state is high and signals (fifo_full and pkt_valid) are low.
	 When signals laf_state and low_pkt_valid both are high and the previous value of parity_done is low.

3.detect_add signal is used to reset parity_done signal.

4. rst_int_reg signal is used to reset low_pkt_valid signal.

5.Signal low_pkt_valid is high when ld_state is high and pkt_valid is low. Low_packet_valid shows
that pkt_valid for current state has been deasserted.
6.First data byte i.e., header is latched inside an internal register when detect_add and pkt_valid signals
are high. This data is latched to the output dout when lfd_state goes high.
7.Then signal data_in i.e. Payload is latched to dout if ld_state signal is high and fifo_full is low.
8.Signal data_in is latched to an internal register when ld_state and fifo_full are high. This data is latched to
output dout when laf_state goes high.
9.Full_state is used to calculate internal parity.
10.Another internal register is used to store internal parity for parity matching. Internal parity is calculated
 using the bit-wise xor operation between header byte, payload byte and previous parity values as
 shown below:
 parity_reg=parity_reg_previous^header_byte ---- t1 clock cycle
 parity_reg=parity_reg_previous^header_byte ---- t1 clock cycle
 parity_reg=parity_reg_previous^header_byte ---- t1 clock cycle
 parity_reg=parity_reg_previous^header_byte ---- t1 clock cycle
11. Last payload byte
12. The err is calculated only after packet parity is loaded and goes high if the packet parity doesn’t match with
the internal parity.
