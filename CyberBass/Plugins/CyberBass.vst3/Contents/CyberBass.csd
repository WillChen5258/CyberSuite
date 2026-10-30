<Cabbage>
form caption("Cyber Bass") size(640, 360), guiMode("queue"), colour(25, 25, 25), pluginId("cybs"), bundle("CyberBass.jpg", "CyberBass.snaps")

image bounds(0, 0, 640, 360), file("CyberBass.jpg"), channel("background"), alpha(0.45)
label bounds(10, 6, 215, 36), text("Cyber Bass"), fontColour(255, 255, 255, 255) channel("label4")

combobox bounds(510, 52, 120, 25), populate("*.snaps"), channel("presetBox"), channelType("string"), automatable(0), value(1)
filebutton bounds(510, 82, 58, 25), text("Save", "Save"), populate("*.snaps"), mode("named snapshot")
filebutton bounds(572, 82, 58, 25), text("Delete", "Delete"), populate("*.snaps"), mode("remove preset") channel("filebutton9")

groupbox bounds(10, 52, 240, 95), text("Tone"), colour(0, 0, 0, 0), outlineColour(80, 80, 80, 255), fontColour(255, 255, 255, 255)
rslider bounds(20, 72, 70, 70), channel("drive"), range(0, 1, 0.35, 1, 0.001), text("Drive"), fontColour(255, 255, 255, 255), trackerColour(90, 110, 95, 255)
rslider bounds(94, 72, 70, 70), channel("sub"), range(0, 1, 0.5, 1, 0.001), text("Sub"), fontColour(255, 255, 255, 255), trackerColour(90, 110, 95, 255)
rslider bounds(170, 72, 70, 70), channel("level"), range(0, 1, 0.7, 1, 0.001), text("Level"), fontColour(255, 255, 255, 255), trackerColour(90, 110, 95, 255)

groupbox bounds(260, 52, 240, 95), text("Filter"), colour(0, 0, 0, 0), outlineColour(80, 80, 80, 255), fontColour(255, 255, 255, 255)
rslider bounds(274, 72, 70, 70), channel("cutoff"), range(80, 8000, 800, 0.5, 0.001), text("Cutoff"), fontColour(255, 255, 255, 255), trackerColour(90, 110, 95, 255)
rslider bounds(350, 72, 70, 70), channel("res"), range(0, 0.9, 0.2, 1, 0.001), text("Resonance"), fontColour(255, 255, 255, 255), trackerColour(90, 110, 95, 255)
rslider bounds(424, 72, 70, 70), channel("filterEnv"), range(0, 4000, 1000, 0.5, 0.001), text("Envelope"), fontColour(255, 255, 255, 255), trackerColour(90, 110, 95, 255)

groupbox bounds(10, 154, 490, 95), text("Envelope"), colour(0, 0, 0, 0), outlineColour(80, 80, 80, 255), fontColour(255, 255, 255, 255)
rslider bounds(66, 174, 70, 70), channel("attack"), range(0.001, 0.5, 0.01, 0.5, 0.001), text("Attack"), fontColour(255, 255, 255, 255), trackerColour(90, 110, 95, 255)
rslider bounds(170, 174, 70, 70), channel("decay"), range(0.01, 1, 0.25, 0.5, 0.001), text("Decay"), fontColour(255, 255, 255, 255), trackerColour(90, 110, 95, 255)
rslider bounds(274, 174, 70, 70), channel("sustain"), range(0, 1, 0.55, 1, 0.001), text("Sustain"), fontColour(255, 255, 255, 255), trackerColour(90, 110, 95, 255)
rslider bounds(378, 174, 70, 70), channel("release"), range(0.01, 1.5, 0.25, 0.5, 0.001), text("Release"), fontColour(255, 255, 255, 255), trackerColour(90, 110, 95, 255)

groupbox bounds(510, 112, 120, 137), text("VU Meter"), colour(0, 0, 0, 0), outlineColour(80, 80, 80, 255), fontColour(255, 255, 255, 255)
vmeter bounds(552, 138, 15, 105), channel("vuL"), value(0), outlineColour(0, 0, 0, 255), overlayColour(0, 0, 0, 255), meterColour:0(255, 0, 0, 255), meterColour:1(255, 255, 0, 255), meterColour:2(0, 255, 0, 255), outlineThickness(1)
vmeter bounds(572, 138, 15, 105), channel("vuR"), value(0), outlineColour(0, 0, 0, 255), overlayColour(0, 0, 0, 255), meterColour:0(255, 0, 0, 255), meterColour:1(255, 255, 0, 255), meterColour:2(0, 255, 0, 255), outlineThickness(1)

keyboard bounds(10, 260, 620, 89) channel("keyboard7")
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

instr 1

    iFreq = p4
    iAmp = p5

    kDrive chnget "drive"
    kSub chnget "sub"
    kLevel chnget "level"
    kCutoff chnget "cutoff"
    kRes chnget "res"
    kFilterEnv chnget "filterEnv"

    iAtt chnget "attack"
    iDec chnget "decay"
    iSus chnget "sustain"
    iRel chnget "release"

    kAmpEnv linsegr 0, iAtt, 1, iDec, iSus, iRel, 0
    kFiltEnv linsegr 0, .005, 1, .18, 0, .12, 0

    aSquare vco2 iAmp, iFreq, 10
    aSub vco2 iAmp, iFreq * .5, 10

    aBass = (aSquare * (1 - kSub)) + (aSub * kSub)

    aDrive = tanh(aBass * (1 + kDrive * 50))

    kFinalCutoff = kCutoff + (kFiltEnv * kFilterEnv)
    kFinalCutoff limit kFinalCutoff, 40, 12000

    aFilt moogladder aDrive, kFinalCutoff, kRes

    aOut = aFilt * kAmpEnv * kLevel

    gaOutL += aOut
    gaOutR += aOut

endin

instr 99

    kVuL rms gaOutL, 20
    kVuR rms gaOutR, 20

    cabbageSetValue "vuL", portk(kVuL * 2, .25), metro(10)
    cabbageSetValue "vuR", portk(kVuR * 2, .25), metro(10)

    outs gaOutL, gaOutR

    clear gaOutL, gaOutR

endin

</CsInstruments>

<CsScore>
i 99 0 z
f0 z
</CsScore>

</CsoundSynthesizer>