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
    //RGB 数据灰度化的精度 
    parameter RGB2Gray_Accuracy_N=8; 
    //行,场,数据有效信号延时个数 
    wire [4:0]Delay_Num; 
    //灰度数据 
    wire [7:0]Gray_Data; 
    //输出的图像数据 
    wire [23:0]RGB_Data_Out; 
    //图像数据输出 
    assign RGB_Data=RGB_Data_Out; 
    //图像处理部分:如边缘检测 
    Edge_Check Edge_Check0( 
        .clk_Image_Process(clk_Image_Process), 
        .Rst(Rst), 
        .RGB_DE(RGB_VDE_Src), 
        .Gray_Data(Gray_Data), 
        .Gray_Gate(50), 
        .Delay_Num(Delay_Num), 
        .RGB_Data(RGB_Data_Out) 
        ); 
    //图像灰度化 
    RGB_To_Gray RGB2Gray( 
        .RGB_Data_R(RGB_Data_Src[23:16]),              //像素数据 R 
        .RGB_Data_G(RGB_Data_Src[15:8]),               //像素数据 G 
        .RGB_Data_B(RGB_Data_Src[7:0]),                //像素数据 B 
        .Accuracy_Num(RGB2Gray_Accuracy_N),            //灰度化精度位数 
        .Gray_Data(Gray_Data)                          //输出灰度数据 
        ); 
    //行信号延时 
    Delay_Signal Delay_HSync( 
        .clk_Signal(clk_Image_Process),       //信号单位时钟 
        .Rst(Rst),                            //复位信号,低电平复位 
        .Signal_In(RGB_HSync_Src),            //需要延时的输入信号 
        .Delay_Num(Delay_Num),                //需要延时的时钟个数,不超过 8,可级联 
        .Delay_Signal(RGB_HSync)              //延时后输出的信号 
        ); 
    //场信号延时 
    Delay_Signal Delay_VSync( 
        .clk_Signal(clk_Image_Process),       //信号单位时钟 
        .Rst(Rst),                            //复位信号,低电平复位 
        .Signal_In(RGB_VSync_Src),            //需要延时的输入信号 
        .Delay_Num(Delay_Num),                //需要延时的时钟个数,不超过 8,可级联 
        .Delay_Signal(RGB_VSync)              //延时后输出的信号 
        ); 
    //数据有效信号延时 
    Delay_Signal Delay_De( 
        .clk_Signal(clk_Image_Process),       //信号单位时钟 
        .Rst(Rst),                            //复位信号,低电平复位 
        .Signal_In(RGB_VDE_Src),              //需要延时的输入信号 
        .Delay_Num(Delay_Num),                //需要延时的时钟个数,不超过 8,可级联 
        .Delay_Signal(RGB_VDE)                //延时后输出的信号 
        ); 
endmodule 
