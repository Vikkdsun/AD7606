module ad7606_drive#(
    parameter           P_RANGE = 0     
)(
    input               i_clk           ,
    input               i_rst           ,
    /*-------- 鐢ㄦ埛绔彛 --------*/
    input               i_user_ctrl     ,       // 鐢ㄦ埛寮�鍏�
    output [15:0]       o_user_data_1   ,
    output              o_user_valid_1  ,
    output [15:0]       o_user_data_2   ,
    output              o_user_valid_2  ,
    output [15:0]       o_user_data_3   ,
    output              o_user_valid_3  ,
    output [15:0]       o_user_data_4   ,
    output              o_user_valid_4  ,
    output [15:0]       o_user_data_5   ,
    output              o_user_valid_5  ,
    output [15:0]       o_user_data_6   ,
    output              o_user_valid_6  ,
    output [15:0]       o_user_data_7   ,
    output              o_user_valid_7  ,
    output [15:0]       o_user_data_8   ,
    output              o_user_valid_8  ,
    /*-------- ADC绔彛 --------*/
    output              o_ad_psb_sel    ,       // 1
    output              o_ad_stby       ,       // 1
    output              o_ad_convstA    ,       // 1
    output              o_ad_convstB    ,       // 1
    output              o_ad_reset      ,       // 1
    output              o_ad_cs         ,       // 1
    output              o_ad_rd         ,       // 1
    output [2:0]        o_ad_osc        ,       // 杩囬噰鏍疯缃俊鍙�
    output              o_ad_range      ,       // 1
    input               i_ad_busy       ,
    input  [15:0]       i_ad_data       
);

// 瀵勫瓨鍣�
reg                     ro_ad_psb_sel                                           ;
reg                     ro_ad_stby                                              ;
reg                     ro_ad_convstA                                           ;
reg                     ro_ad_convstB                                           ;
reg                     ro_ad_reset                                             ;
reg                     ro_ad_cs                                                ;
reg                     ro_ad_rd                                                ;
reg                     ro_ad_osc                                               ;

reg [15:0]              ro_user_data_1                                          ;
reg                     ro_user_valid_1                                         ;
reg [15:0]              ro_user_data_2                                          ;
reg                     ro_user_valid_2                                         ;
reg [15:0]              ro_user_data_3                                          ;
reg                     ro_user_valid_3                                         ;
reg [15:0]              ro_user_data_4                                          ;
reg                     ro_user_valid_4                                         ;
reg [15:0]              ro_user_data_5                                          ;
reg                     ro_user_valid_5                                         ;
reg [15:0]              ro_user_data_6                                          ;
reg                     ro_user_valid_6                                         ;
reg [15:0]              ro_user_data_7                                          ;
reg                     ro_user_valid_7                                         ;
reg [15:0]              ro_user_data_8                                          ;
reg                     ro_user_valid_8                                         ;

assign                  o_ad_range     = P_RANGE                                ;
assign                  o_ad_psb_sel   = ro_ad_psb_sel                          ;
assign                  o_ad_stby      = ro_ad_stby                             ;
assign                  o_ad_convstA   = ro_ad_convstA                          ;
assign                  o_ad_convstB   = ro_ad_convstB                          ;
assign                  o_ad_reset     = ro_ad_reset                            ;
assign                  o_ad_cs        = ro_ad_cs                               ;
assign                  o_ad_rd        = ro_ad_rd                               ;
assign                  o_ad_osc       = ro_ad_osc                              ;
assign                  o_user_data_1  = ro_user_data_1                         ;
assign                  o_user_valid_1 = ro_user_valid_1                        ;
assign                  o_user_data_2  = ro_user_data_2                         ;
assign                  o_user_valid_2 = ro_user_valid_2                        ;
assign                  o_user_data_3  = ro_user_data_3                         ;
assign                  o_user_valid_3 = ro_user_valid_3                        ;
assign                  o_user_data_4  = ro_user_data_4                         ;
assign                  o_user_valid_4 = ro_user_valid_4                        ;
assign                  o_user_data_5  = ro_user_data_5                         ;
assign                  o_user_valid_5 = ro_user_valid_5                        ;
assign                  o_user_data_6  = ro_user_data_6                         ;
assign                  o_user_valid_6 = ro_user_valid_6                        ;
assign                  o_user_data_7  = ro_user_data_7                         ;
assign                  o_user_valid_7 = ro_user_valid_7                        ;
assign                  o_user_data_8  = ro_user_data_8                         ;
assign                  o_user_valid_8 = ro_user_valid_8                        ;


// 鐘舵�佹満
localparam              P_ST_IDLE       =   0                                   ,
                        P_ST_RESET      =   1                                   ,
                        P_ST_CONVST     =   2                                   ,
                        P_ST_BUSY       =   3                                   ,
                        P_ST_READ       =   4                                   ,
                        P_ST_WAIT       =   5                                   ;

reg [7:0]               r_st_current                                            ;
reg [7:0]               r_st_next                                               ;

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_st_current <= P_ST_IDLE;
    else
        r_st_current <= r_st_next;
end

always@(*)
begin
    case(r_st_current)
        P_ST_IDLE   : r_st_next = ri_user_ctrl  ? P_ST_RESET    : P_ST_IDLE     ;
        P_ST_RESET  : r_st_next = r_st_cnt == 2 ? P_ST_CONVST   : P_ST_RESET    ;
        P_ST_CONVST : r_st_next = P_ST_BUSY     ;
        P_ST_BUSY   : r_st_next = r_st_cnt >= 10 & !ri_ad_busy  ? P_ST_READ     : P_ST_BUSY     ;
        P_ST_READ   : r_st_next = r_st_cnt == 16 -1             ? P_ST_WAIT     : P_ST_READ     ;
        P_ST_WAIT   : r_st_next = r_st_cnt == 60                ? P_ST_CONVST   : P_ST_WAIT     ;       // ( (5 - 3.45)us - (18 x 20)ns ) / 20ns = 60
        default     : r_st_next = P_ST_IDLE     ; 
    endcase
end

reg [15:0]              r_st_cnt                                                ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_st_cnt <= 'd0;
    else if (r_st_current != r_st_next || r_st_current == P_ST_IDLE)
        r_st_cnt <= 'd0;
    else
        r_st_cnt <= r_st_cnt + 1;
end

// 閿佸瓨杈撳叆
reg                     ri_ad_busy                                              ;
reg                     ri_user_ctrl                                            ;

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        ri_ad_busy   <= 'd0;
        ri_user_ctrl <= 'd0;
    end else begin
        ri_ad_busy   <= 'd0  ;
        ri_user_ctrl <= i_user_ctrl;
    end
end

// 鏍规嵁鐘舵�佽緭鍑�
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_ad_psb_sel <= 'd0;
    else
        ro_ad_psb_sel <= 'd0;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_ad_stby <= 'd0;
    else
        ro_ad_stby <= 'd0;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_ad_convstA <= 'd1;
    else if (r_st_current == P_ST_CONVST)
        ro_ad_convstA <= 'd0;
    else 
        ro_ad_convstA <= 'd1;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_ad_convstB <= 'd1;
    else if (r_st_current == P_ST_CONVST)
        ro_ad_convstB <= 'd0;
    else 
        ro_ad_convstB <= 'd1;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_ad_reset <= 'd0;
    else if (r_st_current == P_ST_RESET && r_st_cnt == 2)
        ro_ad_reset <= 'd0;
    else if (ri_user_ctrl && r_st_current == P_ST_IDLE)
        ro_ad_reset <= 'd1;
    else 
        ro_ad_reset <= ro_ad_reset;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_ad_cs <= 'd1;
    else if (r_st_current != P_ST_READ)
        ro_ad_cs <= 'd1;
    else if (r_st_current == P_ST_READ)
        ro_ad_cs <= 'd0;
    else 
        ro_ad_cs <= ro_ad_cs;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_ad_rd <= 'd1;
    else if (r_st_current != P_ST_READ)
        ro_ad_rd <= 'd1;
    else if (r_st_current == P_ST_READ)
        ro_ad_rd <= ~ro_ad_rd;
    else 
        ro_ad_rd <= ro_ad_rd;
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        ro_ad_osc <= 'd0;
    else 
        ro_ad_osc <= 'd0;
end

// 鍒ゆ柇鏄鍑犻�氶亾
reg [7:0]               r_ad_channel                                            ;
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst)
        r_ad_channel <= 'd0;
    else if (r_st_cnt == 0 && r_ad_channel == 8)
        r_ad_channel <= 'd0;
    else if (r_st_current == P_ST_READ && ro_ad_rd)
        r_ad_channel <= r_ad_channel + 1;
    else
        r_ad_channel <= r_ad_channel;
end

// 骞惰杈撳嚭
always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        ro_user_data_1  <= 'd0;
        ro_user_valid_1 <= 'd0;
    end else if (r_ad_channel == 1 && ro_ad_rd) begin
        ro_user_data_1  <= i_ad_data;
        ro_user_valid_1 <= 'd1;
    end else begin
        ro_user_data_1  <= 'd0;
        ro_user_valid_1 <= 'd0;
    end
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        ro_user_data_2  <= 'd0;
        ro_user_valid_2 <= 'd0;
    end else if (r_ad_channel == 2 && ro_ad_rd) begin
        ro_user_data_2  <= i_ad_data;
        ro_user_valid_2 <= 'd1;
    end else begin
        ro_user_data_2  <= 'd0;
        ro_user_valid_2 <= 'd0;
    end
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        ro_user_data_3  <= 'd0;
        ro_user_valid_3 <= 'd0;
    end else if (r_ad_channel == 3 && ro_ad_rd) begin
        ro_user_data_3  <= i_ad_data;
        ro_user_valid_3 <= 'd1;
    end else begin
        ro_user_data_3  <= 'd0;
        ro_user_valid_3 <= 'd0;
    end
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        ro_user_data_4  <= 'd0;
        ro_user_valid_4 <= 'd0;
    end else if (r_ad_channel == 4 && ro_ad_rd) begin
        ro_user_data_4  <= i_ad_data;
        ro_user_valid_4 <= 'd1;
    end else begin
        ro_user_data_4  <= 'd0;
        ro_user_valid_4 <= 'd0;
    end
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        ro_user_data_5  <= 'd0;
        ro_user_valid_5 <= 'd0;
    end else if (r_ad_channel == 5 && ro_ad_rd) begin
        ro_user_data_5  <= i_ad_data;
        ro_user_valid_5 <= 'd1;
    end else begin
        ro_user_data_5  <= 'd0;
        ro_user_valid_5 <= 'd0;
    end
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        ro_user_data_6  <= 'd0;
        ro_user_valid_6 <= 'd0;
    end else if (r_ad_channel == 6 && ro_ad_rd) begin
        ro_user_data_6  <= i_ad_data;
        ro_user_valid_6 <= 'd1;
    end else begin
        ro_user_data_6  <= 'd0;
        ro_user_valid_6 <= 'd0;
    end
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        ro_user_data_7  <= 'd0;
        ro_user_valid_7 <= 'd0;
    end else if (r_ad_channel == 7 && ro_ad_rd) begin
        ro_user_data_7  <= i_ad_data;
        ro_user_valid_7 <= 'd1;
    end else begin
        ro_user_data_7  <= 'd0;
        ro_user_valid_7 <= 'd0;
    end
end

always@(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        ro_user_data_8  <= 'd0;
        ro_user_valid_8 <= 'd0;
    end else if (r_ad_channel == 8 && ro_ad_rd) begin
        ro_user_data_8  <= i_ad_data;
        ro_user_valid_8 <= 'd1;
    end else begin
        ro_user_data_8  <= 'd0;
        ro_user_valid_8 <= 'd0;
    end
end

endmodule
