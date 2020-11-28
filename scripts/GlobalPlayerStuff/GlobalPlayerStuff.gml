//Init global player variables
global.debugPlayer = true;
global.currencyAmount = 0;

function playerToDummy() {
	if (instance_exists(oPlayer)) {with (oPlayer) { toDummy(); }}
}

function playerToGrounded() {
	if (instance_exists(oPlayer)) { with (oPlayer) {toGrounded(); }}
}