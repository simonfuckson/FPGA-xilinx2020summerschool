module Edge_Check( 
    input clk_Image_Process, 
    input Rst, 
    input RGB_DE, 
    input [7:0]Gray_Data, 
    input [7:0]Gray_Gate, 
    output [2:0]Delay_Num, 
    output [23:0]RGB_Data 
    ); 
    //��Ե���ռ��ʱ�� 
    parameter Edge_Delay_Clk=2; 
    parameter Edge_Delay_Clk_De=3; 
    //��λ�Ĵ����м����� 
    wire [7:0]D0; 
    wire [7:0]D1; 
    wire [7:0]D2; 
    wire [7:0]D3; 
    //�����Ե������ݾ��� 3*3,ÿ�� 8 λ,�� 9*8=72 λ 
    reg [71:0]Matrix_Edge_Check_Data=0; 
    wire [7:0]Matrix_00=Matrix_Edge_Check_Data[71:64]; 
    wire [7:0]Matrix_01=Matrix_Edge_Check_Data[63:56]; 
    wire [7:0]Matrix_02=Matrix_Edge_Check_Data[55:48]; 
    wire [7:0]Matrix_10=Matrix_Edge_Check_Data[47:40]; 
    wire [7:0]Matrix_11=Matrix_Edge_Check_Data[39:32]; 
    wire [7:0]Matrix_12=Matrix_Edge_Check_Data[31:24]; 
    wire [7:0]Matrix_20=Matrix_Edge_Check_Data[23:16]; 
    wire [7:0]Matrix_21=Matrix_Edge_Check_Data[15:8]; 
    wire [7:0]Matrix_22=Matrix_Edge_Check_Data[7:0]; 
    //�����Ե����м�������ݾ��� 
    wire [10:0]Matrix_Cal_X_0=Matrix_00+2*Matrix_01+Matrix_02; 
    wire [10:0]Matrix_Cal_X_1=Matrix_20+2*Matrix_21+Matrix_22; 
    wire [10:0]Matrix_Cal_Y_0=Matrix_00+2*Matrix_10+Matrix_20; 
    wire [10:0]Matrix_Cal_Y_1=Matrix_02+2*Matrix_12+Matrix_22; 
    //�����Ե��������,����ֵ 
    wire [10:0]Matrix_Res_X=(Matrix_Cal_X_1>Matrix_Cal_X_0)?(Matrix_Cal_X_1-Matrix_Cal_X_0):(Matrix_Cal_X_0-Matrix_Cal_X_1); 
    wire [10:0]Matrix_Res_Y=(Matrix_Cal_Y_1>Matrix_Cal_Y_0)?(Matrix_Cal_Y_1-Matrix_Cal_Y_0):(Matrix_Cal_Y_0-Matrix_Cal_Y_1); 
    //������ֵƽ���� 
    wire [15:0]Gate2=Gray_Gate*Gray_Gate; 
    //������ʱ��������ź� 
    wire De_Delay; 
    //�����ֵ����� 
    wire Binary_Data_Out=(Matrix_Res_X*Matrix_Res_X+Matrix_Res_Y*Matrix_Res_Y>Gate2)?Rst&De_Delay:0; 
    //ͼ���������,��ֵ�� 
    assign RGB_Data=Binary_Data_Out?24'hffffff:0; 
    assign Delay_Num=Edge_Delay_Clk; 
    //��Ե������ݾ����ƶ� 
    always@(posedge clk_Image_Process or negedge Rst) 
        begin 
            //�͵�ƽ��λ 
            if(!Rst) 
                Matrix_Edge_Check_Data<=0; 
            else if(RGB_DE) 
                
Matrix_Edge_Check_Data<={Matrix_Edge_Check_Data[47:24],Matrix_Edge_Check_Data[23:0],D1,D3,Gray_Data}; 
        end 
    //������Ч�ź���ʱ 
    Delay_Signal Delay_De( 
        .clk_Signal(clk_Image_Process),       //�źŵ�λʱ�� 
        .Rst(Rst),                            //��λ�ź�,�͵�ƽ��λ 
        .Signal_In(RGB_DE),                   //��Ҫ��ʱ�������ź� 
        .Delay_Num(Edge_Delay_Clk_De),        //��Ҫ��ʱ��ʱ�Ӹ���,������ 8,�ɼ��� 
        .Delay_Signal(De_Delay)               //��ʱ��������ź� 
        ); 
    //����ͼ�����ݲ�����ȫ�洢,�洢�ռ䲻���ԭ��,������λ�Ĵ���,������,����һ�� 
    //��λ�Ĵ������ֵΪ 1088,������һ��ͼ��Ϊ 1280�����������½� 640 ��λ����λ�Ĵ���,���� 4 ��ʹ�ü��� 
    //��λ�Ĵ������ڲ���β�ź����,�ⲿ��β�źŷֱ�Ϊ:����Ϊ�Ҷ�����,���Ϊ��λ���� 
    //��һ�� 
    Shift_Line Image_Line_Buffer00( 
      .D(Gray_Data),                        // input wire [7 : 0] D 
      .CLK(clk_Image_Process&RGB_DE),       // input wire CLK 
      .Q(D0)                                // output wire [7 : 0] Q 
    );   
    Shift_Line Image_Line_Buffer01( 
      .D(D0),                               // input wire [7 : 0] D 
      .CLK(clk_Image_Process&RGB_DE),       // input wire CLK 
      .Q(D1)                                // output wire [7 : 0] Q 
    );   
    //�ڶ��� 
    Shift_Line Image_Line_Buffer10( 
      .D(D1),                               // input wire [7 : 0] D 
      .CLK(clk_Image_Process&RGB_DE),       // input wire CLK 
      .Q(D2)                                // output wire [7 : 0] Q 
    );   
    Shift_Line Image_Line_Buffer11( 
      .D(D2),                               // input wire [7 : 0] D 
      .CLK(clk_Image_Process&RGB_DE),       // input wire CLK 
      .Q(D3)                                // output wire [7 : 0] Q 
    );   
endmodule 