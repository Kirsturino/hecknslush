//This is a system used to handle calling vector draw calls from step events
vectorCalls = {}
vectorIndex = 0;

function shapeTick()
{
	var names = variable_struct_get_names(vectorCalls);
	var  size = array_length(names);
	
	for (var i = 0; i < size; ++i)
	{
	    var structVar = variable_struct_get(vectorCalls, names[i]);
		
		if (structVar.dur == 0)
		{
			variable_struct_remove(vectorCalls, names[i]);
		} else
		{
			structVar.dur = approach(structVar.dur, 0, 1);
			structVar.size += structVar.sizeChange * delta;
		}
	}
}

function drawShapes()
{
	var names = variable_struct_get_names(vectorCalls);
	var  size = array_length(names);
	
	for (var i = 0; i < size; ++i)
	{
	    var structVar = variable_struct_get(vectorCalls, names[i]);
		
		structVar.drawShape();
	}
}