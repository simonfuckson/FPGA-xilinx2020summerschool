`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/25 09:56:56
// Design Name: 
// Module Name: Camera_Demo
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


module Camera_Demo(
    input i_clk,
    input i_rst,
    
    input i_clk_rx_data_n,          //摄像头DN数据输出时钟
    input i_clk_rx_data_p,          //摄像头DP数据输出时钟
    
    input [1:0]i_rx_data_n,         //摄像头数据口DN
    input [1:0]i_rx_data_p,         //摄像头数据口DP
    
    input i_data_n,                 //摄像头N数据
    input i_data_p,                 //摄像头P数据
    
    inout i_camera_iic_sda,         //K12摄像头初始化IIC接口数据线
    output o_camera_iic_scl,        //K11摄像头初始化IIC接口时钟线
    output o_camera_gpio,           //M11摄像头输出引脚
    
    output TMDS_Tx_Clk_N,           //HDMI发送数据DN路时钟
    output TMDS_Tx_Clk_P,           //HDMI发送数据DP路时钟
    
    output [2:0]TMDS_Tx_Data_N,     //HDMI发送数据口DN
    output [2:0]TMDS_Tx_Data_P      //HDMI发送数据口DP
    );
    //时钟信号
    wire clk_100MHz_system;
    wire clk_200MHz;
    wire clk_50MHz; 
    wire clk_10MHz; 
    wire clk_100MHz_out; 
    wire clk_Serial_out; 
    
    
    
    
    
    //HDMI信号
    wire [23:0]rgb_data_src;
    wire rgb_hsync_src;
    wire rgb_vsync_src;
    wire rgb_vde_src;
    wire clk_pixel;
    wire clk_serial;
    
    //系统时钟
    clk_wiz_0 clk_10(.clk_out1(clk_100MHz_system),.clk_out2(clk_200MHz),.clk_out3(clk_50MHz),.clk_out4(clk_10MHz),.clk_in1(i_clk));
    

    //图像MIPI信号转RGB
    Driver_MIPI MIPI_Trans_Driver(
        .i_clk_200MHz(clk_200MHz),
        .i_clk_rx_data_n(i_clk_rx_data_n),
        .i_clk_rx_data_p(i_clk_rx_data_p),
        .i_rx_data_n(i_rx_data_n),
        .i_rx_data_p(i_rx_data_p),
        .i_data_n(i_data_n),
        .i_data_p(i_data_p),
        .o_camera_gpio(o_camera_gpio),
        .o_rgb_data(rgb_data_src),
        .o_rgb_hsync(rgb_hsync_src),
        .o_rgb_vsync(rgb_vsync_src),
        .o_rgb_vde(rgb_vde_src),
        .o_set_x(),
        .o_set_y(),
        .o_clk_pixel(clk_100MHz_out)
    );
    
    wire [23:0]RGB_Data; 
    wire RGB_HSync; 
    wire RGB_VSync; 
    wire RGB_VDE; 
    
        //图像处理 
    Image_Process Image_Process_Edge( 
        .clk_Image_Process(clk_100MHz_out), 
        .Rst(1), 
        .RGB_Data_Src(rgb_data_src), 
        .RGB_HSync_Src(rgb_hsync_src), 
        .RGB_VSync_Src(rgb_vsync_src), 
        .RGB_VDE_Src(rgb_vde_src), 
        .RGB_Data(RGB_Data), 
        .RGB_HSync(RGB_HSync), 
        .RGB_VSync(RGB_VSync), 
        .RGB_VDE(RGB_VDE) 
        ); 
        
            //HDMI驱动
    rgb2dvi_0 Mini_HDMI_Driver(
      .TMDS_Clk_p(TMDS_Tx_Clk_P),     // output wire TMDS_Clk_p
      .TMDS_Clk_n(TMDS_Tx_Clk_N),     // output wire TMDS_Clk_n
      .TMDS_Data_p(TMDS_Tx_Data_P),      // output wire [2 : 0] TMDS_Data_p
      .TMDS_Data_n(TMDS_Tx_Data_N),      // output wire [2 : 0] TMDS_Data_n
      .aRst_n(1),                   // input wire aRst_n
      .vid_pData(RGB_Data),         // input wire [23 : 0] vid_pData
      .vid_pVDE(RGB_VDE),           // input wire vid_pVDE
      .vid_pHSync(RGB_HSync),       // input wire vid_pHSync
      .vid_pVSync(RGB_VSync),       // input wire vid_pVSync
      .PixelClk(clk_100MHz_out)
    );
    
        
    //摄像头IIC的SDA线的三态节点
    wire camera_iic_sda_i;
    wire camera_iic_sda_o;
    wire camera_iic_sda_t;
    
    //Tri-state gate
    IOBUF Camera_IIC_SDA_IOBUF
       (.I(camera_iic_sda_o),
        .IO(i_camera_iic_sda),
        .O(camera_iic_sda_i),
        .T(~camera_iic_sda_t));
    
    //摄像头IIC驱动信号
    wire iic_busy;
    wire iic_mode;
    wire [7:0]slave_addr;
    wire [7:0]reg_addr_h;
    wire [7:0]reg_addr_l;
    wire [7:0]data_w;
    wire [7:0]data_r;
    wire iic_write;
    wire iic_read;
    wire ov5647_ack;
    
    //摄像头驱动
    OV5647_Init MIPI_Camera_Driver(
        .i_clk(clk_100MHz_system),
        .i_rst(i_rst),
        .i_iic_busy(iic_busy),
        .o_iic_mode(iic_mode),          
        .o_slave_addr(slave_addr),    
        .o_reg_addr_h(reg_addr_h),   
        .o_reg_addr_l(reg_addr_l),   
        .o_data_w(data_w),      
        .o_iic_write(iic_write),
        .o_ack(ov5647_ack)                 
    );
    
    //摄像头IIC驱动
    Driver_IIC MIPI_Camera_IIC(
        .i_clk(clk_100MHz_system),
        .i_rst(i_rst),
        .i_iic_sda(camera_iic_sda_i),
        .i_iic_write(iic_write),                //IIC写信号,上升沿有效
        .i_iic_read(iic_read),                  //IIC读信号,上升沿有效
        .i_iic_mode(iic_mode),                  //IIC模式,1代表双地址位,0代表单地址位,低位地址有效
        .i_slave_addr(slave_addr),              //IIC从机地址
        .i_reg_addr_h(reg_addr_h),              //寄存器地址,高8位
        .i_reg_addr_l(reg_addr_l),              //寄存器地址,低8位
        .i_data_w(data_w),                      //需要传输的数据
        .o_data_r(data_r),                      //IIC读到的数据
        .o_iic_busy(iic_busy),                  //IIC忙信号,在工作时忙,低电平忙
        .o_iic_scl(o_camera_iic_scl),           //IIC时钟线
        .o_sda_dir(camera_iic_sda_t),           //IIC数据线方向,1代表输出
        .o_iic_sda(camera_iic_sda_o)            //IIC数据线
    );
    
endmodule
