//Init global player variables
global.debugPlayer = true;

function playerToDummy() {
	if (instance_exists(oPlayer)) {with (oPlayer) { toDummy(); }}
}

function playerToGrounded() {
	if (instance_exists(oPlayer)) { with (oPlayer) {toGrounded(); }}
}