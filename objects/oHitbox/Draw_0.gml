draw_self();

if (global.showHitboxBoundaries && atk.hitDelay == 0 && atk.dur > atk.maxDur - atk.hitEnd) draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);