`timescale 1ns/1ns;

module ad7606_drive_tb();

reg clk, rst;

initial begin
    rst = 1;
    # 100;
    @(posedge clk) rst = 0;
end

always begin
    clk = 0;
    # 10;
    clk = 1;
    # 10;
end

ad7606_drive ad7606_drive_u0(
    .i_clk              (clk        ),
    .i_rst              (rst        ),
    /*-------- 鐢ㄦ埛绔彛 --------*/
    .i_user_ctrl        (1          ),       // 鐢ㄦ埛寮?鍏?
    .o_user_data_1      (),
    .o_user_valid_1     (),
    .o_user_data_2      (),
    .o_user_valid_2     (),
    .o_user_data_3      (),
    .o_user_valid_3     (),
    .o_user_data_4      (),
    .o_user_valid_4     (),
    .o_user_data_5      (),
    .o_user_valid_5     (),
    .o_user_data_6      (),
    .o_user_valid_6     (),
    .o_user_data_7      (),
    .o_user_valid_7     (),
    .o_user_data_8      (),
    .o_user_valid_8     (),
    /*-------- ADC绔彛 --------*/
    .o_ad_psb_sel       (),       // 1
    .o_ad_stby          (),       // 1
    .o_ad_convstA       (),       // 1
    .o_ad_convstB       (),       // 1
    .o_ad_reset         (),       // 1
    .o_ad_cs            (),       // 1
    .o_ad_rd            (),       // 1
    .o_ad_osc           (),       // 杩囬噰鏍疯缃俊鍙?
    .o_ad_range         (),       // 1
    .i_ad_busy          (1          ),
    .i_ad_data          (16'h5555   )
);

endmodule
