extends Node


const START = 1
const MAX = 25
const STEP = 1

var expansion = START


# EXPANSAO
func expand():
	expansion += STEP

	$Player.scale.x = expansion
	$Player.scale.y = expansion

	if (expansion >= MAX):
		invert()

# Transicao
func invert():
	if $Screen/Negate.visible:
		$Screen/Negate.hide()
	else:
		$Screen/Negate.show()

	expand_to(START)
