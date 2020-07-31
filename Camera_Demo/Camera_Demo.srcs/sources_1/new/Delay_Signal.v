module Delay_Signal( 
    input clk_Signal,               //信号单位时钟 
    input Rst,                      //复位信号,低电平复位 
    input Signal_In,                //需要延时的输入信号 
    input [4:0]Delay_Num,          //需要延时的时钟个数,不超过 8,可级联 
    output Delay_Signal             //延时后输出的信号 
    ); 
    //信号缓存 
    reg[31:0]Signal_Buffer=0; 
    //移位赋值 
    assign Delay_Signal=Signal_Buffer[Delay_Num]; 
    //信号移位 
    always@(posedge clk_Signal or negedge Rst) 
        begin 
            //低电平复位 
            if(!Rst) 
                Signal_Buffer<=0; 
            else 
                begin 
                    //信号移位 
                    Signal_Buffer<={Signal_Buffer[30:0],Signal_In};                         
                end 
        end 
endmodule 