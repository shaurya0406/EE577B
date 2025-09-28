/////////////////////////////////////////////////////////////////
//       testbench: tb.v
/////////////////////////////////////////////////////////////////
`timescale 1ns/10ps
module tb;
	reg TCLK, TRST, TMS;
	wire[3:0] STATE;
	tap_controller tap_cntrl(TCLK, TRST, TMS, STATE);
	initial TCLK=0;
	always #1 TCLK =~TCLK;
	integer tap_controller_output;
	
	initial begin
		tap_controller_output = $fopen("tap_controller.out","w");
		$fmonitor(tap_controller_output,"At time %g ns ,TMS=%b ,STATE=%b",$time,TMS,STATE);
		TRST=1'b1;
		//TMS=1'b0;
		#2 TRST=1'b0;
		repeat(35)begin
			#2 TMS<=$random;
		end
		#2 TRST=1'b1;
		#2 TRST=1'b0;
		
		$fclose(tap_controller_output);
		#20 $finish;
	end
endmodule
		
	 


	
	
	
	



