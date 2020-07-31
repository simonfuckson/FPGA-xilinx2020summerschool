module Delay_Signal( 
    input clk_Signal,               //�źŵ�λʱ�� 
    input Rst,                      //��λ�ź�,�͵�ƽ��λ 
    input Signal_In,                //��Ҫ��ʱ�������ź� 
    input [4:0]Delay_Num,          //��Ҫ��ʱ��ʱ�Ӹ���,������ 8,�ɼ��� 
    output Delay_Signal             //��ʱ��������ź� 
    ); 
    //�źŻ��� 
    reg[31:0]Signal_Buffer=0; 
    //��λ��ֵ 
    assign Delay_Signal=Signal_Buffer[Delay_Num]; 
    //�ź���λ 
    always@(posedge clk_Signal or negedge Rst) 
        begin 
            //�͵�ƽ��λ 
            if(!Rst) 
                Signal_Buffer<=0; 
            else 
                begin 
                    //�ź���λ 
                    Signal_Buffer<={Signal_Buffer[30:0],Signal_In};                         
                end 
        end 
endmodule 