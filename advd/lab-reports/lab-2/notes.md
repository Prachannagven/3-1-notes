# Goal
To look at the VTC curve of a resistive NMOS circuit.

# Measurements
## Output Voltages
Input voltage at the gate of the NMOS was varied from 0 to 1.8V.
Output voltage at the drain of the NMOS was measured.

VTC curve was plotted, allowing us to find VOH and VOL begin:
	- $V_{OH}$ = 1.8V = $V_{DD}$
	- $V_{OL}$ = 0.203.279 mV != GND

## Input Voltages
The points at which the gradient was -1 was used for $V_{IH}$ and $V_{IL}$. The derviative of the curve was plotted using Tools > Calculator and using the deriv function. Subsequently, the input values were found:
	- $V_{IH}$ = 0.49974 V
	- $V_{IL}$ = 1.19555 V

When matched against the output values for that:
	- $V_{out}(V_{IH})$ = 1.71774 V
	- $V_{out}(V_{IL}$) = 0.390568 V

## Noise Margins
The noise margins are then:
	- $NM_{L}$ = $V_{IL} - V_{OL} = 1.19555 - 0.391568 = 0.803982$

# Param
