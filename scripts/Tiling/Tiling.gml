global.tileset = sObjectTileset;

//function drawTiles()
//{
//	var arr = global.roomTiles;
//	var size = array_length(arr);
//	for (var i = 0; i < size; ++i)
//	{
//		var spr = array_get(arr[i], 2);
//		var xx = array_get(arr[i], 0);
//		var yy = array_get(arr[i], 1);
//	    draw_sprite(global.tileset, spr, xx, yy);
//	}
//}

// GM efficient Auto-tile sprite script
// Original script by Taylor Lopez
// See the original script on Git Hub: https://github.com/iAmMortos/autotile

function autotile(tile)
{
	with(tile)
	{
	    var u = 0;  // up
	    var r = 0;  // right
	    var d = 0;  // down
	    var l = 0;  // left
	    var ul = 0; // up-left
	    var ur = 0; // up-right
	    var dr = 0; // down-right
	    var dl = 0; // down-left
    
	    // Check adjacent side existence
	    if (position_meeting(x,              y - blockSize, tile))  u = 1;
	    if (position_meeting(x + blockSize,  y,              tile))  r = 2;
	    if (position_meeting(x,              y + blockSize, tile))  d = 4;
	    if (position_meeting(x - blockSize,  y,              tile))  l = 8;
    
	    // Check corner existence
	    if (position_meeting(x - blockSize, y - blockSize,  tile))  ul = 1;
	    if (position_meeting(x + blockSize, y - blockSize,  tile))  ur = 2;
	    if (position_meeting(x + blockSize, y + blockSize,  tile))  dr = 4;
	    if (position_meeting(x - blockSize, y + blockSize,  tile))  dl = 8;
    
	    var edges = u + r + d + l;
	    var corners = 0;

	    if (u && l) corners += ul;    
	    if (u && r) corners += ur;
	    if (d && r) corners += dr;
	    if (d && l) corners += dl;
    
	    switch(edges)
	    {
	        case 0: index = 0; break;
	        case 1: index = 1; break;
	        case 2: index = 2; break;
	        case 3:
	            switch(corners)
	            {
	                case 0: index = 3; break;
	                case 2: index = 4; break;
	            }
	        break;
	        case 4: index = 5; break;
	        case 5: index = 6; break;
	        case 6:
	            switch(corners)
	            {
	                case 0: index = 7; break;
	                case 4: index = 8; break;
	            }
	        break;
	        case 7:
	            switch(corners)
	            {
	                case 0: index = 9; break;
	                case 2: index = 10; break;
	                case 4: index = 11; break;
	                case 6: index = 12; break;
	            }
	        break;
	        case 8: index = 13; break;
	        case 9:
	            switch(corners)
	            {
	                case 0: index = 14; break;
	                case 1: index = 15; break;
	            }
	        break;
	        case 10: index = 16; break;
	        case 11:
	            switch(corners)
	            {
	                case 0: index = 17; break;
	                case 1: index = 18; break;
	                case 2: index = 19; break;
	                case 3: index = 20; break;
	            }
	        break;
	        case 12:
	            switch(corners)
	            {
	                case 0: index = 21; break;
	                case 8: index = 22; break;
	            }
	        break;
	        case 13:
	            switch(corners)
	            {
	                case 0: index = 23; break;
	                case 1: index = 24; break;
	                case 8: index = 25; break;
	                case 9: index = 26; break;
	            }
	        break;
	        case 14:
	            switch(corners)
	            {
	                case 0: index = 27; break;
	                case 4: index = 28; break;
	                case 8: index = 29; break;
	                case 12: index = 30; break;
	            }
	        break;
	        case 15:
	            switch(corners)
	            {
	                case 0: index = 31; break;
	                case 1: index = 32; break;
	                case 2: index = 33; break;
	                case 3: index = 34; break;
	                case 4: index = 35; break;
	                case 5: index = 36; break;
	                case 6: index = 37; break;
	                case 7: index = 38; break;
	                case 8: index = 39; break;
	                case 9: index = 40; break;
	                case 10: index = 41; break;
	                case 11: index = 42; break;
	                case 12: index = 43; break;
	                case 13: index = 44; break;
	                case 14: index = 45; break;
	                case 15: index = 46; break;
	            }
	        break;
	    }
	}
}