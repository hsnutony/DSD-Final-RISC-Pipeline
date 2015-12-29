module risc (
	input clk,
	input rst_n,
	input preload,
	input [10:0] ipl_addr,
	input im_datain,
	input [10:0] dpl_addr,
	input [31:0] dpl_datain,
	output dm_dataout
);

// signals from processor
wire [10:0] ipc_addr;
wire dpc_wen;
wire dpc_oen;
wire [10:0] dpc_addr;
wire [31:0] dpc_datain;

// signals for instruction memory IM
wire im_cen;
wire im_wen;
wire im_oen;
wire [10:0] im_addr;
wire [31:0] im_datain;
wire [31:0] im_dataout;

assign im_cen = 0;
assign im_wen = ~preload;
assign im_oen = preload;
assign im_addr = (preload)?ipl_addr:ipc_addr;


// signals for data memory DM
wire dm_cen;
wire dm_wen;
wire dm_oen;
wire [10:0] dm_addr;
wire [31:0] dm_datain;
wire [31:0] dm_dataout;

assign dm_cen = 0;
assign dm_wen = (preload)?(~preload):dpc_wen;
assign dm_oen = preload | dpc_oen;
assign dm_addr = (preload)?dpl_addr:dpc_addr;
assign dm_datain = (preload)?dpl_datain:dpc_datain;

pipeline process1(
	.clk(clk),
	.rst_n(rst_n),
	.instruction(im_dataout),
	.loaddata(dm_dataout),
	.ipc_addr(ipc_addr),
	.dpc_wen(dpc_wen),
	.dpc_oen(dpc_oen),
	.dpc_addr(dpc_addr),
	.dpc_datain(dpc_datain)
	
);

RAM2Kx32 ins_ram(
	.Q(im_dataout),
	.CLK(clk),
	.CEN(im_cen),
	.WEN(im_wen),
	.A(im_addr),    
	.D(im_datain),
	.OEN(im_oen)
);

RAM2Kx32 data_ram(
	.Q(dm_dataout),
	.CLK(clk),
	.CEN(dm_cen),
	.WEN(dm_wen),
	.A(dm_addr),
	.D(dm_datain),
	.OEN(dm_oen)
);
