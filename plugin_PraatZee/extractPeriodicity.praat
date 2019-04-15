form Extract part
    real Part_start 0 (= from beginning)
    real Part_end 0 (= to end)
    boolean Adjust_pitch_ceiling 1
endform

full_name$ = replace$(selected$(), " ", "_", 0)
us_i = index(full_name$, "_")
object_type$ = left$(full_name$, us_i - 1)
object_name$ = right$(full_name$, length(full_name$) - us_i)

if part_start == 0
    part_start = 'full_name$'.xmin
endif
if part_end == 0
    part_end = 'full_name$'.xmax
endif

start_frame = Get frame number from time: part_start
if start_frame <= 0
    start_frame = 1
else
    start_frame = ceiling(start_frame)
endif
t_start_frame = Get time from frame number: start_frame
end_frame = Get frame number from time: part_end
end_frame = floor(end_frame)
if end_frame > 'full_name$'.nx
    end_frame = 'full_name$'.nx
endif
num_frames = end_frame - start_frame + 1
To Matrix
Create Matrix: "'object_name$'_part", part_start, part_end, num_frames, 'full_name$'.dx, t_start_frame, 1, 1, 1, 1, 1, "Matrix_'object_name$'[1, start_frame - 1 + col]"

if object_type$ == "Pitch"
    To Pitch
    if adjust_pitch_ceiling
        selectObject: "Pitch 'object_name$'"
        obj_info$ = Info
        p_ceiling = extractNumber(obj_info$, "Ceiling at:")
        selectObject: "Pitch 'object_name$'_part"
        View & Edit
        editor: selected$()
            Change ceiling: p_ceiling
            Close
        endeditor
    endif
elif object_type$ == "Harmonicity"
    To Harmonicity
endif

removeObject: "Matrix 'object_name$'"
removeObject: "Matrix 'object_name$'_part"
