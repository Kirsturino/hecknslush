draw_sprite(global.tileset, index, x, y);
draw_sprite(global.tileset, index, x, y - blockSize/4*3);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(x, y, index);

draw_set_valign(fa_top);