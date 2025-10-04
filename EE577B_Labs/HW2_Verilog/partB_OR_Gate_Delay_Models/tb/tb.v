
`timescale 1ns/1ps

module tb;
	reg A, B;
	wire OUT1, OUT2, OUT3, OUT4, OUT5;
	
	integer fd;

	// DUTs
  	or_block_inter  u1 (.A(A), .B(B), .Y(OUT1));
  	or_nba_inter    u2 (.A(A), .B(B), .Y(OUT2));
  	or_block_intra  u3 (.A(A), .B(B), .Y(OUT3));
  	or_nba_intra    u4 (.A(A), .B(B), .Y(OUT4));
  	or_continuous   u5 (.A(A), .B(B), .Y(OUT5));

	initial begin
	  fd = $fopen("delay.out", "w");
	  //$fdisplay(fd, "Time(ns)  A  B  OUT1  OUT2  OUT3  OUT4  OUT5");
      //$fdisplay(fd, "------------------------------------------------");
	end

	always @(*) begin
	  $fdisplay(fd, "At time %gns, A=%0b, B=%0b, OUT1=%0b, OUT2=%0b, OUT3=%0b, OUT4=%0b, OUT5=%0b",
              $time, A, B, OUT1, OUT2, OUT3, OUT4, OUT5);
	end

	initial begin
	  A = 1; B = 1;
	  #4 A = 1;B = 0;
      #3 A = 0;B = 0;
      #4 A = 0;B = 1;
      #3 A = 0;B = 0;
      #6;

	  $fclose(fd);
      $finish;
    end

endmodule