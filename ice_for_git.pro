;The principle of ICE algorithm
;Xinkai Liu
;China University of Geoscience
;2018.05.11

;********************
;explain
;raw_data: The raw NDVI timeseries of a certain pixel
;iteration_times: The times of tieration
;search_window: window size of the algorithm
function ice_for_git, raw_data, iteration_times, search_window

  COMPILE_OPT idl2
  ENVI,/restore_base_save_files
  ENVI_BATCH_INIT, log_file='batch.txt'

  size_data = size(raw_data, /dimensions)
  result = dblarr(2, size_data[1])
  result[0, *] = raw_data
  store_window = search_window


  result[1, 0] = 1
  for current_iteration = 1, iteration_times do begin

    i = 0
    j = 0
    while j le size_data[1] - 1 do begin
      if j eq i then j = i + 1
      ;The points which has been spotted as the envelpoe nodes (marked with "1") and the obvious outlier will be skipped
      if (result[1, j] eq 1) || (result[0, j] gt 1) || (result[0, j] lt -1) then begin 
        j++
        continue
      endif
      if j eq size_data[1] - 1 then begin
        result[1, size_data[1] - 1] = 1
        break
      endif else begin
        a = (result[0, j] - result[0, i]) / (j - i)
        b = result[0, j] - a * j
      endelse
      
      ;Estimating whether the window size of the last search should be changed
      if i le size_data [1]- 1 - search_window then begin

        window_check = 0
        for m = j + 1, i + search_window do begin
          if (result[1, m] eq 1) || (result[0, m] gt 1) || (result[0, m] lt -1) then continue
          on_judg = a * m + b
          window_check++
          if on_judg lt result[0, m] then break
        endfor

        if m eq i + search_window + 1 then begin
          result[1, j] = 1
          i = j
        endif else begin
          j++
          if (j eq i + search_window) && (window_check eq 0) then begin
            for f = i + search_window, i + 1, -1 do begin
              if result[1, f] eq 1 then begin
                i = f
                j = i
              endif
            endfor
          endif
        endelse

      endif else begin

        if i lt size_data[1] - 1 then begin 
          search_window = size_data[1] - 1 - i
          j = i + 1;

        endif

      endelse

    endwhile

    if search_window ne store_window then search_window = store_window

    currt_contin = where(result[1, *] eq 1, count)
    count_currt_contin = count ;当前包络线节点数

  endfor

  ;checking the outliers

  ;second-order difference computing
  step_out = 0
  count_abnormal = 0

  while step_out eq 0 do begin

    check = result[1, *]
    check_envelope = where(check eq 1, count)
    temp_envelope = dblarr(2, count)
    for i = 0, count - 1 do begin
      temp_envelope[0, i] = result[0, check_envelope[i]]
      temp_envelope[1, i] = check_envelope[i]
    endfor

    ;plot for test
;    windows = window(window_title = 'test_denoised')
;    p1 = plot(temp_envelope[1, *], temp_envelope[0, *], linestyle = '', symbol = '+', name = 'envelpoe points', $
;      color = 'deep_sky_blue', thick = 2, /current)
;    p2 = plot(temp_envelope[1, *], temp_envelope[0, *], linestyle = '-', name = 'before repair', $
;      color = 'blue', thick = 2, /overplot);设置window关键字，使绘图窗口成为当前窗口，才能执行下面的关闭操作

    ;identifying the positions of the outlier marked by the second-order difference compution and removing these outliers from the envelope node list
    first_difference = dblarr(1, count - 1)
    for i = 1, count - 1 do begin
      difference = temp_envelope[0, i] - temp_envelope[0, i - 1]
      if difference ge 0 then first_difference[i - 1] = 1 else first_difference[i - 1] = -1
    endfor
    num_first_difference = size(first_difference, /dimension)
    second_difference = dblarr(1, num_first_difference[1] - 1)
    for i = 1, num_first_difference[1] - 1 do begin
      second_difference[i - 1] = first_difference[i] - first_difference[i - 1]
    endfor
    ;  extremum1 = where(second_difference eq 2, count)
    ;  extremum2 = where(second_difference eq -2, count)
    ;  extremum = [extremum1, extremum2]
    ;  extremum_index = extremum + 1

    extremum = where(second_difference eq 2, count)
    extremum_index = extremum + 1

    for i = 0, count - 1 do begin
      index = extremum_index[i]
      for_judge_l = temp_envelope[0, index] / temp_envelope[0, index - 1]
      for_judge_r = temp_envelope[0, index] / temp_envelope[0, index + 1]
      ;    average = (temp_envelope[0, index - 1] + temp_envelope[0, index + 1]) / 2
      ;    for_judge = temp_envelope[0, index] / average
      if (for_judge_l le 0.6) or (for_judge_r le 0.6) then begin
        result[1, temp_envelope[1, index]] = 0
        count_abnormal++
      endif
    endfor

    if count_abnormal eq 0 then step_out = 1
    count_abnormal = 0

    ;plot_for test
;    check2 = result[1, *]
;    check_envelope2 = where(check2 eq 1, count);检测包络线节点数
;    temp_envelope2 = dblarr(2, count)
;    for i = 0, count - 1 do begin
;      temp_envelope2[0, i] = result[0, check_envelope2[i]]
;      temp_envelope2[1, i] = check_envelope2[i]
;    endfor
;    p3 = PLOT(temp_envelope2[1, *], temp_envelope2[0, *], linestyle = '-', name = 'After Repair', $
;      color = 'red', thick = 2, /overplot);设置window关键字，使绘图窗口成为当前窗口，才能执行下面的关闭操作
;    l = legend(target = [p1, p2, p3], position = [100, 1.2], font_size = 8, /data)
;    windows.Close

  endwhile


  ;Valid values are reserved, invalid values are evaluated as empty. The final ICE-SG data returned is a one-dimensional array
  continuum = dblarr(1, size_data[1])
  for i = 0, size_data[1] - 1 do begin
    if result[1, i] eq 1 then  continuum[i] = result[0, i] else continuum[i] = -2
  endfor

  return, continuum

end

