<Cabbage>
form caption("Crush Sampler") size(830, 316), guiMode("queue"), colour(30, 30, 30), pluginId("crsm"), bundle("CrushSampler.jpg", "CrushSampler.snaps")

image bounds(0, 0, 830, 316), file("CrushSampler.jpg"), channel("background"), alpha(0.45)
label bounds(-2, 22, 219, 31), text("Crush Sampler"), fontColour(255, 255, 255, 255) channel("label4")

combobox bounds(222, 10, 120, 25), populate("*.snaps"), channel("presetBox"), channelType("string"), automatable(0), value(1)
filebutton bounds(222, 44, 58, 25), text("Save", "Save"), populate("*.snaps"), mode("named snapshot")
filebutton bounds(284, 44, 58, 25), text("Delete", "Delete"), populate("*.snaps"), mode("remove preset")

soundfiler bounds(350, 10, 390, 110), channel("soundfiler1")

groupbox bounds(350, 129, 390, 88), text("Effects"), colour(0, 0, 0, 0), outlineColour(80, 80, 80, 255), fontColour(255, 255, 255, 255) channel("groupbox14")
rslider bounds(363, 149, 65, 65), channel("drive"), range(0, 1, 0.35, 1, 0.001), text("Drive"), trackerColour(145, 140, 150, 255)
rslider bounds(437, 149, 65, 65), channel("tone"), range(200, 12000, 6500, 0.5, 1), text("Tone"), trackerColour(145, 140, 150, 255)
rslider bounds(513, 149, 65, 65), channel("crush"), range(0, 1, 0.15, 1, 0.001), text("Crush"), trackerColour(145, 140, 150, 255)
rslider bounds(587, 149, 65, 65), channel("delay"), range(0, 0.7, 0, 1, 0.001), text("Delay"), trackerColour(145, 140, 150, 255)
rslider bounds(663, 149, 65, 65), channel("mix"), range(0, 1, 0.65, 1, 0.001), text("Mix"), trackerColour(145, 140, 150, 255)

groupbox bounds(748, 10, 72, 207), text("VU Meter"), colour(0, 0, 0, 0), outlineColour(80, 80, 80, 255), fontColour(255, 255, 255, 255)
vmeter bounds(766, 35, 15, 177), channel("vuL"), value(0), outlineColour(0, 0, 0, 255), overlayColour(0, 0, 0, 255), meterColour:0(255, 0, 0, 255), meterColour:1(255, 255, 0, 255), meterColour:2(0, 255, 0, 255), outlineThickness(1)
vmeter bounds(786, 35, 15, 177), channel("vuR"), value(0), outlineColour(0, 0, 0, 255), overlayColour(0, 0, 0, 255), meterColour:0(255, 0, 0, 255), meterColour:1(255, 255, 0, 255), meterColour:2(0, 255, 0, 255), outlineThickness(1)

keyboard bounds(10, 228, 810, 78)
</Cabbage>

<CsoundSynthesizer>

<CsOptions>
-n -d -+rtmidi=NULL -M0 -m0d --midi-key=4 --midi-velocity-amp=5
</CsOptions>

<CsInstruments>

sr = 48000
ksmps = 16
nchnls = 2
0dbfs = 1

gaOutL init 0
gaOutR init 0

instr SampleSlot

    iSlotNumber = p4
    iX = p5
    iY = p6

    SImageCode sprintf "bounds(%d, %d, 76, 62), channel(\"sampleSlot%d\"), outlineThickness(3), corners(10), outlineColour(\"white\")", iX, iY, iSlotNumber
    SButtonCode sprintf "bounds(%d, %d, 46, 22), text(\"Play\"), channel(\"sampleSlotPlay%d\")", iX+16, iY+34, iSlotNumber
    SLabelCode sprintf "bounds(%d, %d, 46, 18), text(\"%d\"), fontColour(\"white\"), channel(\"sampleSlotLabel%d\")", iX+16, iY+10, iSlotNumber, iSlotNumber

    cabbageCreate "image", SImageCode
    cabbageCreate "button", SButtonCode
    cabbageCreate "label", SLabelCode

    SFileChannel sprintf "sampleSlot%d_file", iSlotNumber
    SChannel sprintf "sampleSlot%d", iSlotNumber
    SLabelChannel sprintf "sampleSlotLabel%d", iSlotNumber
    SPlayChannel sprintf "sampleSlotPlay%d", iSlotNumber

    kBounds[] cabbageGet SChannel, "bounds"
    kX chnget "MOUSE_X"
    kY chnget "MOUSE_Y"

    kMouseDownImage, kImageTrig cabbageGetValue SChannel
    kMouseDownLabel, kLabelTrig cabbageGetValue SLabelChannel

    if kLabelTrig == 1 || kImageTrig == 1 then
        cabbageSet 1, "soundfiler1", "file", chnget:S(SFileChannel)
    endif

    SFile, kFileChanged cabbageGet "LAST_FILE_DROPPED"

    if kFileChanged == 1 then
        if kX > kBounds[0] && kX < kBounds[0]+kBounds[2] && kY > kBounds[1] && kY < kBounds[1]+kBounds[3] then
            cabbageSet kFileChanged, "soundfiler1", "file", SFile
            chnset SFile, SFileChannel
        endif
    endif

    kButton, kButtonTrig cabbageGetValue SPlayChannel

    if kButtonTrig == 1 then
        SSampleFile chnget SFileChannel
        cabbageSet 1, "soundfiler1", "file", SSampleFile
        event "i", 1, 0, -1, 60+iSlotNumber-1
    endif

endin

instr 1

    SFileChannel sprintf "sampleSlot%d_file", (p4-60)+1
    SSampleFile chnget SFileChannel

    iDuration filelen SSampleFile

    if iDuration <= 0 then
        turnoff
    endif

    if p3 < 0 then
        p3 = iDuration
    endif

    aL, aR diskin2 SSampleFile, 1, 0, 0

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

    gaOutL += aOutL
    gaOutR += aOutR

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

i"SampleSlot" 0 z 1 10 80
i"SampleSlot" 0 z 2 95 80
i"SampleSlot" 0 z 3 180 80
i"SampleSlot" 0 z 4 265 80

i"SampleSlot" 0 z 5 10 155
i"SampleSlot" 0 z 6 95 155
i"SampleSlot" 0 z 7 180 155
i"SampleSlot" 0 z 8 265 155

i 99 0 z

f0 z

</CsScore>

</CsoundSynthesizer>