# =====================================================================
# SDC (Synopsys Design Constraints) File - 最终修正版
# =====================================================================

# ---------------------------------------------------------------------
# I. 时钟定义 (Clock Definitions)
# ---------------------------------------------------------------------
# 1. 定义系统主时钟 (clk) - 50 MHz
create_clock -name sys_clk -period 20.000 [get_ports clk]
# 2. 定义以太网接收时钟 (eth_rxc) - 125 MHz
create_clock -name eth_rxc -period 8.000 [get_ports eth_rx_clk]

# ---------------------------------------------------------------------
# II. 时钟关系定义 (Clock Groups)
# ---------------------------------------------------------------------
# 将主时钟和以太网接收时钟设置为异步关系
set_clock_groups -asynchronous -group [get_clocks sys_clk] -group [get_clocks eth_rxc]

# ---------------------------------------------------------------------
# III. 输入/输出延迟约束 (Input/Output Delays)
# ---------------------------------------------------------------------

# 1. 以太网接收接口约束 (相对于 eth_rxc)
# 这部分保持不变，因为您的接收是正常的
set_input_delay -clock [get_clocks eth_rxc] -max 3.5 [get_ports {eth_rxd[*] eth_rxv}]
set_input_delay -clock [get_clocks eth_rxc] -min 1.0 [get_ports {eth_rxd[*] eth_rxv}]


# 2. 以太网发送接口约束 (相对于 sys_clk)
# 【核心修改】
# 我们改变约束模型：不再创建衍生时钟，而是将所有输出都约束到其真正的源头——内部的稳定时钟。
# 假设您的125MHz发送时钟是由PLL从sys_clk生成的。
# 我们告诉工具，eth_txc 这个输出时钟相对于 sys_clk 的延迟范围。
# 这会强制布局布线器控制 eth_txc 的走线延迟。
# -max 10 表示eth_txc的输出延迟最大为10ns
# -min 5  表示eth_txc的输出延迟最小为5ns
set_output_delay -clock [get_clocks sys_clk] -max 10.0 [get_ports eth_txc]
set_output_delay -clock [get_clocks sys_clk] -min 5.0 [get_ports eth_txc]

# 然后，我们将数据输出(eth_txd, eth_txv)也约束到同一个源时钟 sys_clk。
# 这样，工具就会尽力让 eth_txd/eth_txv 和 eth_txc 之间的延迟关系保持一致。
# 这里的延迟值也需要根据PHY数据手册和PCB情况进行微调。
set_output_delay -clock [get_clocks sys_clk] -max 10.0 [get_ports {eth_txd[*] eth_txv}]
set_output_delay -clock [get_clocks sys_clk] -min 5.0 [get_ports {eth_txd[*] eth_txv}]


# ---------------------------------------------------------------------
# IV. 时序例外 (Timing Exceptions)
# ---------------------------------------------------------------------
set_false_path -from [get_ports rst_n]
set_false_path -from [get_ports {sw[*]}]
set_false_path -from [get_ports key1]
set_false_path -from [get_ports key2]
set_false_path -to [get_ports {led[*]}]
set_false_path -to [get_ports {smg_p[*]}]
set_false_path -to [get_ports {smg_d[*]}]