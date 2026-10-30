<Cabbage>
form caption("Echo Space") size(630, 185), guiMode("queue"), pluginId("ecsp"), colour(35, 30, 45), bundle("EchoSpace.jpg", "EchoSpace.snaps")

image bounds(0, 0, 630, 185), file("EchoSpace.jpg"), channel("background"), alpha(0.45)
label bounds(10, 12, 221, 36), text("Echo Space"), fontColour(255, 255, 255, 255) channel("label4")

combobox bounds(236, 18, 148, 25), populate("*.snaps"), channel("presetBox"), channelType("string"), automatable(0), value(1)
filebutton bounds(388, 18, 58, 25), text("Save", "Save"), populate("*.snaps"), mode("named snapshot")
filebutton bounds(450, 18, 58, 25), text("Delete", "Delete"), populate("*.snaps"), mode("remove preset") channel("filebutton10")

rslider bounds(24, 70, 90, 90), channel("delayTime"), range(0.01, 1, 0.25, 1, 0.001), text("Delay"), trackerColour(110, 95, 135, 255)
rslider bounds(125, 70, 90, 90), channel("feedback"), range(0, 0.85, 0.35, 1, 0.001), text("Feedback"), trackerColour(110, 95, 135, 255)
rslider bounds(225, 70, 90, 90), channel("reverb"), range(0, 1, 0.35, 1, 0.001), text("Reverb"), trackerColour(110, 95, 135, 255)
rslider bounds(325, 70, 90, 90), channel("damp"), range(1000, 12000, 6000, 0.5, 0.001), text("Damp"), trackerColour(110, 95, 135, 255)
rslider bounds(425, 70, 90, 90), channel("mix"), range(0, 1, 0.5, 1, 0.001), text("Mix"), trackerColour(110, 95, 135, 255)

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

    ;aL, aR diskin2 "BassLoop.wav", 1, 0, 1

    kDelayTime chnget "delayTime"
    kFeedback chnget "feedback"
    kReverb chnget "reverb"
    kDamp chnget "damp"
    kMix chnget "mix"

    kDelayTime portk kDelayTime, 0.02

    aBufferL delayr 1.1
    aDelayL deltap3 kDelayTime
    delayw aL + (aDelayL * kFeedback)

    aBufferR delayr 1.1
    aDelayR deltap3 kDelayTime
    delayw aR + (aDelayR * kFeedback)

    aRevL, aRevR reverbsc aDelayL, aDelayR, kReverb, kDamp

    aWetL = aDelayL + aRevL
    aWetR = aDelayR + aRevR

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