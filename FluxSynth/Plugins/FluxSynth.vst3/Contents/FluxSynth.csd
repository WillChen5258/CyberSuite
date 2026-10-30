<Cabbage>
form caption("Flux Synth") size(700, 315), guiMode("queue"), pluginId("flxs"), colour(28, 28, 32), bundle("FluxSynth.jpg", "FluxSynth.snaps")

image bounds(0, 0, 700, 315), file("FluxSynth.jpg"), channel("background"), alpha(0.45)
label bounds(10, 10, 202, 36), text("Flux Synth"), fontColour(255, 255, 255, 255)

combobox bounds(446, 16, 120, 25), populate("*.snaps"), channel("presetBox"), channelType("string"), automatable(0), value(1)
filebutton bounds(570, 16, 58, 25), text("Save", "Save"), populate("*.snaps"), mode("named snapshot")
filebutton bounds(632, 16, 58, 25), text("Delete", "Delete"), populate("*.snaps"), mode("remove preset") channel("filebutton9")

groupbox bounds(10, 54, 125, 150), text("Modulator"), colour(0, 0, 0, 0), outlineColour(80, 80, 80, 255), fontColour(255, 255, 255, 255)
checkbox bounds(20, 100, 105, 30), text("LFO Mod"), channel("enableLFO"), radioGroup("99"), value(1), colour:1(140, 85, 120, 255), fontColour(255, 255, 255, 255)
checkbox bounds(20, 140, 105, 30), text("Pitch Mod"), channel("enablePitch"), radioGroup("99"), value(0), colour:1(140, 85, 120, 255), fontColour(255, 255, 255, 255)

groupbox bounds(145, 54, 185, 150), text("Filter"), colour(0, 0, 0, 0), outlineColour(80, 80, 80, 255), fontColour(255, 255, 255, 255)
rslider bounds(150, 92, 85, 85), channel("cutoff"), range(1, 20000, 10000, 1, 0.001), text("Cutoff"), fontColour(255, 255, 255, 255), trackerColour(140, 85, 120, 255)
rslider bounds(240, 92, 85, 85), channel("peak"), range(0, 1, 0.15, 1, 0.001), text("Peak"), fontColour(255, 255, 255, 255), trackerColour(140, 85, 120, 255)

groupbox bounds(340, 54, 185, 150), text("LFO"), colour(0, 0, 0, 0), outlineColour(80, 80, 80, 255), fontColour(255, 255, 255, 255)
rslider bounds(345, 92, 85, 85), channel("rate"), range(0, 10, 2, 1, 0.001), text("Rate"), fontColour(255, 255, 255, 255), trackerColour(140, 85, 120, 255)
rslider bounds(435, 92, 85, 85), channel("intensity"), range(0, 1, 0.25, 1, 0.001), text("Intensity"), fontColour(255, 255, 255, 255), trackerColour(140, 85, 120, 255)

groupbox bounds(535, 54, 85, 150), text("Reverb"), colour(0, 0, 0, 0), outlineColour(80, 80, 80, 255), fontColour(255, 255, 255, 255)
rslider bounds(535, 92, 85, 85), channel("reverb"), range(0, 1, 0.20, 1, 0.001), text("Reverb"), fontColour(255, 255, 255, 255), trackerColour(140, 85, 120, 255)

groupbox bounds(630, 54, 60, 150), text("VU Meter"), colour(0, 0, 0, 0), outlineColour(80, 80, 80, 255), fontColour(255, 255, 255, 255)
vmeter bounds(642, 82, 15, 115), channel("vuL"), value(0), outlineColour(0, 0, 0, 255), overlayColour(0, 0, 0, 255), meterColour:0(255, 0, 0, 255), meterColour:1(255, 255, 0, 255), meterColour:2(0, 255, 0, 255), outlineThickness(1)
vmeter bounds(662, 82, 15, 115), channel("vuR"), value(0), outlineColour(0, 0, 0, 255), overlayColour(0, 0, 0, 255), meterColour:0(255, 0, 0, 255), meterColour:1(255, 255, 0, 255), meterColour:2(0, 255, 0, 255), outlineThickness(1)

keyboard bounds(10, 215, 680, 91)
</Cabbage>

<CsoundSynthesizer>

<CsOptions>
-n -d -+rtmidi=NULL -M0 -m0d --midi-key-cps=4 --midi-velocity-amp=5
</CsOptions>

<CsInstruments>

sr = 48000
ksmps = 16
nchnls = 2
0dbfs = 1

gaOutL init 0
gaOutR init 0

instr SimpleSynth, 1

    iFreq = p4
    iAmp = p5

    kEnv madsr .1, .2, .7, .4

    kIntensity chnget "intensity"
    kRate chnget "rate"
    kCutoff chnget "cutoff"
    kPeak chnget "peak"

    kLFO lfo kIntensity, kRate, 5

    if chnget:k("enableLFO") == 1 then

        aVco vco2 iAmp * kEnv, iFreq

        kModCutoff limit kCutoff * (1 + kLFO), 20, 20000
        aLp moogladder aVco, kModCutoff, kPeak

    else

        aVco vco2 iAmp * kEnv, iFreq + (iFreq * kLFO)
        aLp moogladder aVco, kCutoff, kPeak

    endif

    gaOutL += aLp
    gaOutR += aLp

endin

instr 99

    kRevAmt chnget "reverb"

    aRevL, aRevR reverbsc gaOutL, gaOutR, 0.85, 12000

    aOutL = (gaOutL * (1 - kRevAmt)) + (aRevL * kRevAmt)
    aOutR = (gaOutR * (1 - kRevAmt)) + (aRevR * kRevAmt)

    kVuL rms aOutL, 20
    kVuR rms aOutR, 20

    cabbageSetValue "vuL", portk(kVuL * 2, .25), metro(10)
    cabbageSetValue "vuR", portk(kVuR * 2, .25), metro(10)

    outs aOutL, aOutR

    clear gaOutL, gaOutR

endin

</CsInstruments>

<CsScore>
i 99 0 z
f0 z
</CsScore>

</CsoundSynthesizer>