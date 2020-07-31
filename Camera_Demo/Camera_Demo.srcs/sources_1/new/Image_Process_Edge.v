`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/30 08:42:07
// Design Name: 
// Module Name: Image_Process_Edge
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Image_Process( 
    input clk_Image_Process, 
    input Rst, 
    input [23:0]RGB_Data_Src, 
    input RGB_HSync_Src, 
    input RGB_VSync_Src, 
    input RGB_VDE_Src, 
    output [23:0]RGB_Data, 
    output RGB_HSync, 
    output RGB_VSync, 
    output RGB_VDE 
    ); 
    //RGB ���ݻҶȻ��ľ��� 
    parameter RGB2Gray_Accuracy_N=8; 
    //��,��,������Ч�ź���ʱ���� 
    wire [4:0]Delay_Num; 
    //�Ҷ����� 
    wire [7:0]Gray_Data; 
    //�����ͼ������ 
    wire [23:0]RGB_Data_Out; 
    //ͼ��������� 
    assign RGB_Data=RGB_Data_Out; 
    //ͼ������:���Ե��� 
    Edge_Check Edge_Check0( 
        .clk_Image_Process(clk_Image_Process), 
        .Rst(Rst), 
        .RGB_DE(RGB_VDE_Src), 
        .Gray_Data(Gray_Data), 
        .Gray_Gate(50), 
        .Delay_Num(Delay_Num), 
        .RGB_Data(RGB_Data_Out) 
        ); 
    //ͼ��ҶȻ� 
    RGB_To_Gray RGB2Gray( 
        .RGB_Data_R(RGB_Data_Src[23:16]),              //�������� R 
        .RGB_Data_G(RGB_Data_Src[15:8]),               //�������� G 
        .RGB_Data_B(RGB_Data_Src[7:0]),                //�������� B 
        .Accuracy_Num(RGB2Gray_Accuracy_N),            //�ҶȻ�����λ�� 
        .Gray_Data(Gray_Data)                          //����Ҷ����� 
        ); 
    //���ź���ʱ 
    Delay_Signal Delay_HSync( 
        .clk_Signal(clk_Image_Process),       //�źŵ�λʱ�� 
        .Rst(Rst),                            //��λ�ź�,�͵�ƽ��λ 
        .Signal_In(RGB_HSync_Src),            //��Ҫ��ʱ�������ź� 
        .Delay_Num(Delay_Num),                //��Ҫ��ʱ��ʱ�Ӹ���,������ 8,�ɼ��� 
        .Delay_Signal(RGB_HSync)              //��ʱ��������ź� 
        ); 
    //���ź���ʱ 
    Delay_Signal Delay_VSync( 
        .clk_Signal(clk_Image_Process),       //�źŵ�λʱ�� 
        .Rst(Rst),                            //��λ�ź�,�͵�ƽ��λ 
        .Signal_In(RGB_VSync_Src),            //��Ҫ��ʱ�������ź� 
        .Delay_Num(Delay_Num),                //��Ҫ��ʱ��ʱ�Ӹ���,������ 8,�ɼ��� 
        .Delay_Signal(RGB_VSync)              //��ʱ��������ź� 
        ); 
    //������Ч�ź���ʱ 
    Delay_Signal Delay_De( 
        .clk_Signal(clk_Image_Process),       //�źŵ�λʱ�� 
        .Rst(Rst),                            //��λ�ź�,�͵�ƽ��λ 
        .Signal_In(RGB_VDE_Src),              //��Ҫ��ʱ�������ź� 
        .Delay_Num(Delay_Num),                //��Ҫ��ʱ��ʱ�Ӹ���,������ 8,�ɼ��� 
        .Delay_Signal(RGB_VDE)                //��ʱ��������ź� 
        ); 
endmodule 
