interface vga_if;
    logic [10:0] vcount;
    logic [10:0] hcount;
    logic        vsync;
    logic        hsync;
    logic        vblnk;
    logic        hblnk;
    logic [11:0] rgb;

    modport in (
        input vcount, 
        input hcount, 
        input vsync, 
        input hsync, 
        input vblnk, 
        input hblnk, 
        input rgb
    );

    modport out (
        output vcount, 
        output hcount, 
        output vsync, 
        output hsync, 
        output vblnk, 
        output hblnk, 
        output rgb
    );
endinterface