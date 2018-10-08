
# Audio Digitzier

Created by Nate Lundie and Anna Burkhart (ngl8@case.edu, alb171@case.edu)

## Implementation Details

The waveforms in this lab are examined using the Audio Codec ADCs, which required a 18.432MHz reference
clock. On our part, the Audio Codecs were implemented in the WM8731AudioCodecModule module and the
AudioStreamSpectrumAnalyzer modules. We then generated the Audio Clock PLL which was similar to the
implementation used in Lab6 and LCD Clock PLL. This section of the lab also used the Generator section's
LCD Interface State Machine with some slight modifications for the Analyzer to function correctly. Finally, the
Analyzer was implemented using the Audio Stream Digitizer FFT Framer State Machine, which was
responsible for recognizing when the control signals were enabled and recording how long each transfer took.


