`timescale 1ns/1ps

module tb;
	reg clk, rst, en, d;
    wire q_alpha, q_beta, q_gamma, q_delta;

    //instantiating DUTs
    dff_alpha u_alpha (.clk(clk), .rst(rst), .en(en), .d(d), .q(q_alpha));
    dff_beta  u_beta  (.clk(clk), .rst(rst), .en(en), .d(d), .q(q_beta));
    dff_gamma u_gamma (.clk(clk), .rst(rst), .en(en), .d(d), .q(q_gamma));
    dff_delta u_delta (.clk(clk), .rst(rst), .en(en), .d(d), .q(q_delta));

    initial begin
      clk = 1'b1;
      forever #5 clk = ~clk;
    end

    initial begin
      $dumpfile("tb.vcd");
      $dumpvars(0, tb);
      $display(" time  clk rst en d  |  q_alpha q_beta q_gamma q_delta");
      $monitor("%4t   %b   %b  %b %b  |   %b  %b  %b  %b",
             $time, clk, rst, en, d,   q_alpha, q_beta, q_gamma, q_delta);
    end 

    //dff out files
    integer f_alpha, f_beta, f_gamma, f_delta;
    initial begin
      f_alpha = $fopen("dff_alpha.out","w");
      f_beta  = $fopen("dff_beta.out" ,"w");
      f_gamma = $fopen("dff_gamma.out","w");
      f_delta = $fopen("dff_delta.out","w");
    end

    task log_all;
      begin
        if (f_alpha) $fwrite(f_alpha,"At time %0t ns, clk=%b, rst=%b, en=%b, d=%b, q=%b\n",$time,clk,rst,en,d,q_alpha);
        if (f_beta ) $fwrite(f_beta, "At time %0t ns, clk=%b, rst=%b, en=%b, d=%b, q=%b\n",$time,clk,rst,en,d,q_beta);
        if (f_gamma) $fwrite(f_gamma, "At time %0t ns, clk=%b, rst=%b, en=%b, d=%b, q=%b\n",$time,clk,rst,en,d,q_gamma);
        if (f_delta) $fwrite(f_delta, "At time %0t ns, clk=%b, rst=%b, en=%b, d=%b, q=%b\n",$time,clk,rst,en,d,q_delta);
      end
    endtask
    always @ (q_alpha or q_beta or q_gamma or q_delta or clk or rst or en or d) log_all;
    
    //assert reset for 5-clock cycles -- wait for n falling edges of the clock
    task wait_for_negedges; input integer n; integer k;
       begin for (k=0;k<n;k=k+1) @(negedge clk); end
    endtask

    //apply a combination of en and d for a given number of cycles
    task drive_combo; input en_i, d_i; input integer cycles; integer j;
       begin 
       #2.5
         en=en_i; 
         d=d_i; 
         for (j=0;j<cycles;j=j+1) 
          @(negedge clk); 
       end
    endtask

    integer i;
    initial begin
      en=1'b0; d=1'b0;

    // active HIGH reset (alpha/beta)
    rst = 1'b1;              // assert high
    wait_for_negedges(5);

    // active LOW reset phase (gamma/delta)
    rst = 1'b0;              // assert low
    wait_for_negedges(5);

    // alpha: rst=0 
    rst = 1'b0; 
    @(negedge clk);

    en = 1'b1; d = 1'b1;    
    @(negedge clk);    
    // hold
    @(negedge clk);

    // gamma and delta : rst=1
    rst = 1'b1;
    @(negedge clk);

    en = 1'b1; d = 1'b1;
    @(negedge clk);          
    @(negedge clk);

    // rst=1 (alpha & beta deasserted, gamma & delta asserted)
    for (i=0;i<2;i=i+1) begin
      drive_combo(1'b0,1'b0,2);
      drive_combo(1'b0,1'b1,2);
      drive_combo(1'b1,1'b0,2);
      drive_combo(1'b1,1'b1,2);
    end

    // before/after negedge
    en = 1'b1; d = 1'b0;
    @(posedge clk); #4 d = 1'b1;  // 1 ns before negedge → captured
    @(negedge clk);
    #1 d = 1'b0;                  // 1 ns after negedge → next capture
    @(negedge clk);

    // explicit synchronous resets
    // alpha (sync-HIGH)
    rst = 1'b1; @(negedge clk);   // alpha resets here
    rst = 1'b0; @(negedge clk);   // release for alpha

    // gamma (sync-LOW)
    rst = 1'b0; @(negedge clk);   // gamma resets here
    rst = 1'b1; @(negedge clk);   // release for gamma

    // beta (async-HIGH)
    en = 1'b0; d = 1'b1; rst = 1'b0;
    @(posedge clk); #2 rst = 1'b1; #2 rst = 1'b0; @(negedge clk);

    // delta (async-LOW)
    en = 1'b1; d = 1'b1; rst = 1'b1;
    @(posedge clk); #2 rst = 1'b0; #2 rst = 1'b1; @(negedge clk);

    #20;
    f_alpha = 0; f_beta = 0; f_gamma = 0; f_delta = 0;
    $fclose(f_alpha); $fclose(f_beta); $fclose(f_gamma); $fclose(f_delta);
    $finish;
  end

endmodule