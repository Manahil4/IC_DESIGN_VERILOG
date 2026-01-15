interface counter_if #(parameter N=8) (input logic clk);

    logic rst_n;
    logic en;
    logic up_dn;
    logic [N-1:0] count;

    // Modports
    modport DUT (
        input clk, rst_n, en, up_dn,
        output count
    );

    modport DRV (
        input clk,
        output rst_n, en, up_dn
    );

    modport MON (
        input clk, rst_n, en, up_dn, count
    );

endinterface
