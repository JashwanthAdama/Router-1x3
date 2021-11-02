module router_fifo (clock, resetn, write_enb, read_enb, lfd_state,soft_reset,data_in,full, empty,data_out);
   input clock, resetn, write_enb, read_enb, lfd_state, soft_reset; 
   input [7:0]data_in; 
   output  full, empty; 
   output reg [7:0]data_out;

   parameter DEPTH=16; 
   parameter WIDTH=9; 

   reg [WIDTH-1:0]mem[DEPTH-1:0];
   reg [6:0]counter;
   reg [4:0]rdptr,wrptr;
   reg lfd_temp;

   integer i,j;

assign full=((wrptr[3:0]==rdptr[3:0]) && (wrptr[4]!=rdptr[4]))?1'b1:1'b0;
assign empty=(wrptr==rdptr)?1'b1:1'b0;

always@(posedge clock)
     begin
        if(!resetn)
            lfd_temp<=1'b0;
        else
            lfd_temp<=lfd_state;
     end

//Write block
always@(posedge clock)                              
       begin
                if(!resetn)
                      begin
			     for(i=0;i<16;i=i+1)
			     mem[i]<=0;                             // wrptr<=0;
                      end
                 else if(soft_reset)
                      begin
			     for(j=0;j<16;j=j+1)
			     mem[i]<=0;
                             //data_out<=8'dz;
                            // wrptr<=0;
                      end
                 else if( write_enb && (!full))   
                      begin
                             {mem[wrptr[3:0]][8],mem[wrptr[3:0]][7:0]}<={lfd_temp,data_in};
                            // wrptr<=wrptr+1;
                      end
                
         end
  //read block
always@(posedge clock)                                    
       begin
                if(!resetn)
                      begin
			     data_out<=0;
                            // rdptr<=0;
                      end
                else if(soft_reset)
                      begin
                              data_out<=8'bz;
                             // rdptr<=0;
                      end	   
                     
                else if( read_enb && !empty)
                      begin   
                                  data_out<=mem[rdptr[3:0]];		
                                 // rdptr<=rdptr+1;
                      end              
               else if(counter==0)      //(read_enb==1) && (empty==1) 
                       begin      
                                    data_out<=8'dz;
                       end  
         end        
//counter      
always@(posedge clock)                                                   
       begin
                if(!resetn)
                      begin
			     counter<=0;
                      end
                else if(soft_reset)
                      begin
			     counter<=0;   
                      end
               else if(read_enb && !empty)
                      begin
                           if(mem[rdptr[3:0]][8])
                               counter<=mem[rdptr[3:0]][7:2]+1'b1;
                           else if(counter!==0)
                               counter<=counter-1'b1;
                      end
                          else
                               counter<=0;
                          
        end
 //pointer logic
always@(posedge clock)            
  begin
         if(!resetn)
           begin
               wrptr<=0;
               rdptr<=0;
           end
         else if(soft_reset)
              begin
                  wrptr<=0;
                  rdptr<=0; 
              end
        else
            begin
                if(write_enb && !full)
                    wrptr<=wrptr+1;
                if(read_enb && !empty)
                    rdptr<=rdptr+1;
            end
    end
endmodule