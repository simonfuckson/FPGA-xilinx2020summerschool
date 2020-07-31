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
    
    input i_clk_rx_data_n,          //����ͷDN�������ʱ��
    input i_clk_rx_data_p,          //����ͷDP�������ʱ��
    
    input [1:0]i_rx_data_n,         //����ͷ���ݿ�DN
    input [1:0]i_rx_data_p,         //����ͷ���ݿ�DP
    
    input i_data_n,                 //����ͷN����
    input i_data_p,                 //����ͷP����
    
    inout i_camera_iic_sda,         //K12����ͷ��ʼ��IIC�ӿ�������
    output o_camera_iic_scl,        //K11����ͷ��ʼ��IIC�ӿ�ʱ����
    output o_camera_gpio,           //M11����ͷ�������
    
    output TMDS_Tx_Clk_N,           //HDMI��������DN·ʱ��
    output TMDS_Tx_Clk_P,           //HDMI��������DP·ʱ��
    
    output [2:0]TMDS_Tx_Data_N,     //HDMI�������ݿ�DN
    output [2:0]TMDS_Tx_Data_P      //HDMI�������ݿ�DP
    );
    //ʱ���ź�
    wire clk_100MHz_system;
    wire clk_200MHz;
    wire clk_50MHz; 
    wire clk_10MHz; 
    wire clk_100MHz_out; 
    wire clk_Serial_out; 
    
    
    
    
    
    //HDMI�ź�
    wire [23:0]rgb_data_src;
    wire rgb_hsync_src;
    wire rgb_vsync_src;
    wire rgb_vde_src;
    wire clk_pixel;
    wire clk_serial;
    
    //ϵͳʱ��
    clk_wiz_0 clk_10(.clk_out1(clk_100MHz_system),.clk_out2(clk_200MHz),.clk_out3(clk_50MHz),.clk_out4(clk_10MHz),.clk_in1(i_clk));
    

    //ͼ��MIPI�ź�תRGB
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
    
        //ͼ���� 
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
        
            //HDMI����
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
    
        
    //����ͷIIC��SDA�ߵ���̬�ڵ�
    wire camera_iic_sda_i;
    wire camera_iic_sda_o;
    wire camera_iic_sda_t;
    
    //Tri-state gate
    IOBUF Camera_IIC_SDA_IOBUF
       (.I(camera_iic_sda_o),
        .IO(i_camera_iic_sda),
        .O(camera_iic_sda_i),
        .T(~camera_iic_sda_t));
    
    //����ͷIIC�����ź�
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
    
    //����ͷ����
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
    
    //����ͷIIC����
    Driver_IIC MIPI_Camera_IIC(
        .i_clk(clk_100MHz_system),
        .i_rst(i_rst),
        .i_iic_sda(camera_iic_sda_i),
        .i_iic_write(iic_write),                //IICд�ź�,��������Ч
        .i_iic_read(iic_read),                  //IIC���ź�,��������Ч
        .i_iic_mode(iic_mode),                  //IICģʽ,1����˫��ַλ,0������ַλ,��λ��ַ��Ч
        .i_slave_addr(slave_addr),              //IIC�ӻ���ַ
        .i_reg_addr_h(reg_addr_h),              //�Ĵ�����ַ,��8λ
        .i_reg_addr_l(reg_addr_l),              //�Ĵ�����ַ,��8λ
        .i_data_w(data_w),                      //��Ҫ���������
        .o_data_r(data_r),                      //IIC����������
        .o_iic_busy(iic_busy),                  //IICæ�ź�,�ڹ���ʱæ,�͵�ƽæ
        .o_iic_scl(o_camera_iic_scl),           //IICʱ����
        .o_sda_dir(camera_iic_sda_t),           //IIC�����߷���,1�������
        .o_iic_sda(camera_iic_sda_o)            //IIC������
    );
    
endmodule
