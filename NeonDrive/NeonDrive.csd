<Cabbage>
form caption("Neon Drive") size(630, 185), guiMode("queue"), pluginId("nndr"), colour(40, 5, 15), bundle("NeonDrive.jpg", "NeonDrive.snaps")

image bounds(0, 0, 630, 185), file("NeonDrive.jpg"), channel("background"), alpha(0.45)
label bounds(10, 12, 221, 36), text("Neon Drive"), fontColour(255, 255, 255, 255) channel("label4")

combobox bounds(236, 18, 148, 25), populate("*.snaps"), channel("presetBox"), channelType("string"), automatable(0), value(1)
filebutton bounds(388, 18, 58, 25), text("Save", "Save"), populate("*.snaps"), mode("named snapshot")
filebutton bounds(450, 18, 58, 25), text("Delete", "Delete"), populate("*.snaps"), mode("remove preset") channel("filebutton10")

rslider bounds(24, 70, 90, 90), channel("drive"), range(0, 1, 0.35, 1, 0.001), text("Drive"), trackerColour(135, 65, 80, 255)
rslider bounds(125, 70, 90, 90), channel("tone"), range(200, 12000, 6500, 0.5, 1), text("Tone"), trackerColour(135, 65, 80, 255)
rslider bounds(225, 70, 90, 90), channel("crush"), range(0, 1, 0.15, 1, 0.001), text("Crush"), trackerColour(135, 65, 80, 255)
rslider bounds(325, 70, 90, 90), channel("delay"), range(0, 0.7, 0.18, 1, 0.001), text("Delay"), trackerColour(135, 65, 80, 255)
rslider bounds(425, 70, 90, 90), channel("mix"), range(0, 1, 0.65, 1, 0.001), text("Mix"), trackerColour(135, 65, 80, 255)

label bounds(524, 21, 80, 20), text("VU Meter"), fontColour(255, 255, 255, 255) channel("label18")
vmeter bounds(546, 50, 15, 120), channel("vuL"), value(0), outlineColour(0, 0, 0, 255), overlayColour(0, 0, 0, 255), meterColour:0(255, 0, 0, 255), meterColour:1(255, 255, 0, 255), meterColour:2(0, 255, 0, 255), outlineThickness(1)
vmeter bounds(566, 50, 15, 120), channel("vuR"), value(0), outlineColour(0, 0, 0, 255), overlayColour(0, 0, 0, 255), meterColour:0(255, 0, 0, 255), meterColour:1(255, 255, 0, 255), meterColour:2(0, 255, 0, 255), outlineThickness(1)
</Cabbage>

<CsoundSynthesizer>

<CsOptions>
-d -n
</CsOptions>

<CsInstruments>

sr = 48000
ksmps = 16
nchnls = 2
0dbfs = 1

instr 1

    aL inch 1
    aR inch 2

    ;aL, aR diskin2 "DrumLoop.wav", 1, 0, 1

    kDrive chnget "drive"
    kTone chnget "tone"
    kCrush chnget "crush"
    kDelay chnget "delay"
    kMix chnget "mix"

    aSatL = tanh(aL * (1 + kDrive * 12))
    aSatR = tanh(aR * (1 + kDrive * 12))

    aFiltL moogladder aSatL, kTone, .15
    aFiltR moogladder aSatR, kTone, .15

    aCrushL = int(aFiltL * (2 + kCrush * 30)) / (2 + kCrush * 30)
    aCrushR = int(aFiltR * (2 + kCrush * 30)) / (2 + kCrush * 30)

    aFxL ntrpol aFiltL, aCrushL, kCrush
    aFxR ntrpol aFiltR, aCrushR, kCrush

    aDelayL vdelay aFxL * .35, kDelay * 1000, 1000
    aDelayR vdelay aFxR * .35, kDelay * 1000, 1000

    aWetL = aFxL + aDelayL
    aWetR = aFxR + aDelayR

    aOutL ntrpol aL, aWetL, kMix
    aOutR ntrpol aR, aWetR, kMix

    kVuL rms aOutL, 20
    kVuR rms aOutR, 20

    cabbageSetValue "vuL", portk(kVuL, .25), metro(10)
    cabbageSetValue "vuR", portk(kVuR, .25), metro(10)

    outs aOutL, aOutR

endin

</CsInstruments>

<CsScore>
i 1 0 [3600*24*7]
</CsScore>

</CsoundSynthesizer>