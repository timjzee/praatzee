form Insert silence
    real Insertion_time 0.5
    real Silence_duration 0.05
    real Overlap 0.01
    real Noise_amount 0.005
    boolean Use_breath_file 0
    sentence Breath_file_path /Users/tim/OneDrive/prosodie_project/breath_files/L1_F.wav
endform

full_name$ = selected$()
object_type$ = extractWord$(full_name$, "")
object_name$ = extractLine$(full_name$, " ")
Copy: "dummy"
full_name_us$ = object_type$ + "_dummy"
object_end = 'full_name_us$'.xmax
object_start = 'full_name_us$'.xmin
removeObject: object_type$ + " dummy"
selectObject: full_name$

procedure addSilenceSound
    selectObject: "Sound " + object_name$
    .sampling_freq = Get sampling frequency
    .num_chan = Get number of channels
    if insertion_time > object_start and insertion_time > object_start
        .new_sil_dur = silence_duration + overlap
    else
        .new_sil_dur = silence_duration + overlap / 2
    endif
    if insertion_time > object_start
        Extract part for overlap: object_start, insertion_time, overlap
        Rename: object_name$ + "_part1"
    endif
    if use_breath_file == 0
        Create Sound from formula: object_name$ + "_part2", .num_chan, 0, .new_sil_dur, .sampling_freq, "randomGauss(0,'noise_amount')"
    else
        Read from file: breath_file_path$
        breath_name$ = selected$("Sound")
        if .num_chan == 1
            Convert to mono
            removeObject: "Sound " + breath_name$
            selectObject: "Sound " + breath_name$ + "_mono"
            Rename: breath_name$
        elsif .num_chan == 2
            Convert to stereo
            removeObject: "Sound " + breath_name$
            selectObject: "Sound " + breath_name$ + "_stereo"
            Rename: breath_name$
        endif
        breath_dur = Get total duration
        new_breath_ratio = .new_sil_dur / breath_dur
        Lengthen (overlap-add): 75, 600, new_breath_ratio
        Rename: object_name$ + "_part2"
        breath_sampling_freq = Get sampling frequency
        if breath_sampling_freq != .sampling_freq
            Resample: .sampling_freq, 50
            removeObject: "Sound " + object_name$ + "_part2"
            selectObject: "Sound " + object_name$ + "_part2" + "_" + string$(.sampling_freq)
            Rename: object_name$ + "_part2"
        endif
        removeObject: "Sound " + breath_name$
    endif
    if insertion_time < object_end
        selectObject: "Sound " + object_name$
        Extract part for overlap: insertion_time, object_end, overlap
        Rename: object_name$ + "_part3"
    endif
    selectObject: "Sound " + object_name$ + "_part2"
    if insertion_time > object_start
        plusObject: "Sound " + object_name$ + "_part1"
    endif
    if insertion_time < object_end
        plusObject: "Sound " + object_name$ + "_part3"
    endif
    Concatenate with overlap: overlap
    Rename: object_name$ + "_sil"
    if insertion_time > object_start
        removeObject: "Sound " + object_name$ + "_part1"
    endif
    removeObject: "Sound " + object_name$ + "_part2"
    if insertion_time < object_end
        removeObject: "Sound " + object_name$ + "_part3"
    endif
	selectObject: "Sound " + object_name$ + "_sil"
endproc

procedure addSilenceTG
    selectObject: "TextGrid " + object_name$
    .num_tiers = Get number of tiers
    .tier_names$ = ""
    for t from 1 to .num_tiers
        .tier_name$ = Get tier name: t
        if t == 1
            .tier_names$ = .tier_names$ + .tier_name$
        else
            .tier_names$ = .tier_names$ + " " + .tier_name$
        endif
    endfor
    if insertion_time > object_start
        Extract part: object_start, insertion_time, "no"
        Rename: object_name$ + "_part1"
    endif
    Create TextGrid: 0, silence_duration, .tier_names$, ""
    Rename: object_name$ + "_part2"
    if insertion_time < object_end
        selectObject: "TextGrid " + object_name$
        Extract part: insertion_time, object_end, "no"
    endif
    Rename: object_name$ + "_part3"
    selectObject: "TextGrid " + object_name$ + "_part2"
    if insertion_time > object_start
        plusObject: "TextGrid " + object_name$ + "_part1"
    endif
    if insertion_time < object_end
        plusObject: "TextGrid " + object_name$ + "_part3"
    endif
    Concatenate
    Rename: object_name$ + "_sil"
    if insertion_time > object_start
        removeObject: "TextGrid " + object_name$ + "_part1"
    endif
    removeObject: "TextGrid " + object_name$ + "_part2"
    if insertion_time < object_end
        removeObject: "TextGrid " + object_name$ + "_part3"
    endif
    selectObject: "TextGrid " + object_name$ + "_sil"
endproc

procedure addSilencePP
    .num_points = Get number of points
    .insertion_point = Get high index: insertion_time
    Create empty PointProcess: object_name$ + "_sil", object_start, object_end + silence_duration
    for p from 1 to .num_points
        selectObject: "PointProcess " + object_name$
        .p_time = Get time from index: p
        selectObject: "PointProcess " + object_name$ + "_sil"
        if p >= .insertion_point
            Add point: .p_time + silence_duration
        else
            Add point: .p_time
        endif
    endfor
    selectObject: "PointProcess " + object_name$ + "_sil"
endproc

procedure addSilencePT
    .num_points = Get number of points
    .insertion_point = Get high index from time: insertion_time
    Create PitchTier: object_name$ + "_sil", object_start, object_end + silence_duration
    for p from 1 to .num_points
        selectObject: "PitchTier " + object_name$
        .p_time = Get time from index: p
        .p_value = Get value at index: p
        selectObject: "PitchTier " + object_name$ + "_sil"
        if p >= .insertion_point
            Add point: .p_time + silence_duration, .p_value
        else
            Add point: .p_time, .p_value
        endif
    endfor
    selectObject: "PitchTier " + object_name$ + "_sil"
endproc

if object_type$ == "Sound"
    @addSilenceSound
elif object_type$ == "TextGrid"
    @addSilenceTG
elif object_type$ == "PointProcess"
    @addSilencePP
elif object_type$ == "PitchTier"
    @addSilencePT
elif object_type$ == "Manipulation"
    Extract original sound
    @addSilenceSound
    selectObject: full_name$
    Extract pulses
    @addSilencePP
    selectObject: full_name$
    Extract pitch tier
    @addSilencePT
    selectObject: "Sound " + object_name$ + "_sil"
    To Manipulation: 0.01, 75, 600
    plusObject: "PitchTier " + object_name$ + "_sil"
    Replace pitch tier
    selectObject: full_name$ + "_sil"
    plusObject: "PointProcess " + object_name$ + "_sil"
    Replace pulses
    selectObject: full_name$ + "_sil"
    removeObject: "Sound " + object_name$
    removeObject: "Sound " + object_name$ + "_sil"
    removeObject: "PitchTier " + object_name$
    removeObject: "PitchTier " + object_name$ + "_sil"
    removeObject: "PointProcess " + object_name$
    removeObject: "PointProcess " + object_name$ + "_sil"
endif
