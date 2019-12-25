;traverse the quality band of MOD09GQ and cloud flags of MOD09GA to cmpute the the weather distribution shown in Figure2
;Xinkai Liu
;China University of Geoscience
;2018.7.7
;

pro simulate_weather_distribution_for_git

  COMPILE_OPT IDL2;
  ENVI,/restore_base_save_files
  ENVI_BATCH_INIT, log_file='batch.txt'

  cloud_name =  'J:\Data\MODIS\process\simulate\ice_for_git\2016_Heilongjiang_cloud.tif'
  quality_name =  'J:\Data\MODIS\process\simulate\ice_for_git\2016_Heilongjiang_QC.tif'
  reuslt_name = 'J:\Data\MODIS\process\simulate\ice_for_git\weather.txt'

  ;readin the data
  envi_open_file, cloud_name, r_fid = fids_c
  envi_open_file, quality_name, r_fid=fids_q
  ENVI_FILE_QUERY, fids_c, dims=dims, ns=ns, nl=nl, nb=nb, interleave=interleave,data_type=data_type,offset=offset
  x_axis = dims[2] - dims[1]+1
  y_axis = dims[4] - dims[3]+1
  pointer_clear = fltarr(x_axis, y_axis)
  pointer_cloudy = fltarr(x_axis, y_axis)
  

  weather = dblarr(2, nb)
  for i = 0, nb - 1 do begin
    cloud_data = ENVI_GET_DATA(fid = fids_c, dims = dims, pos = i)
    quality_data = ENVI_GET_DATA(fid = fids_q, dims = dims, pos = i)

    for j = 0, x_axis - 1 do begin
      for k = 0, y_axis - 1 do begin

        ;recoding the quality and cloud bands
        quality_value = quality_data[j, k]

        if (quality_value and 1) eq 1 then begin
          quality_grade = 2
        endif else if (quality_value and 2) eq 1 then begin
          quality_grade = 2
        endif else if (quality_value and 3) eq 1 then begin
          quality_grade = 2
        endif else if quality_value eq 0 then begin
          quality_grade = 0
        endif else begin
          quality_grade = 1
        endelse


        cloud_value = cloud_data[j, k]
        if (cloud_value and 4) eq 4 then begin
          cloud_grade = 2
        endif else if (cloud_value and 1) eq 1 then begin
          cloud_grade = 3
        endif else if (cloud_value and 2) eq 1 then begin
          cloud_grade = 3
        endif else if (cloud_value and 3) eq 1 then begin
          cloud_grade = 3
        endif else if cloud_value eq 0 then begin
          cloud_grade = 0
        endif else begin
          cloud_grade = 1
        endelse

        ;weighting the different data condition, then the data will classfied into "clear" and "cloudy" data 
        if (quality_grade eq 1) and (cloud_grade eq 1) then begin
          weight = 1
        endif else if (quality_grade eq 1) and (cloud_grade eq 2) then begin
          weight = 2
        endif else if (quality_grade eq 0) and (cloud_grade eq 0) then begin
          weight = 0
        endif else begin
          weight = 3
        end

        if weight eq 0 then continue
        if weight eq 1 then begin

          pointer_clear[j, k]++

          if pointer_cloudy[j, k] ne 0 then begin
            weather[1, pointer_cloudy[j, k] - 1]++
            pointer_cloudy[j, k] = 0
          endif

        endif else begin

          pointer_cloudy[j, k]++

          if pointer_clear[j, k] ne 0 then begin
            weather[0, pointer_clear[j, k] - 1]++
            pointer_clear[j, k] = 0
          endif

        endelse

        if (i eq nb - 1) && (pointer_clear[j, k] ne 0) then weather[0, pointer_clear[j, k] - 1]++ ;执行最后一次统计
        if (i eq nb - 1) && (pointer_cloudy[j, k] ne 0) then weather[0, pointer_cloudy[j, k] - 1]++

      endfor
    endfor

  endfor

  num_clear = 0
  num_cloudy = 0
  for i = 0, nb - 1 do begin
    num_clear = num_clear + weather[0, i] * (i + 1)
    num_cloudy = num_cloudy + weather[1, i] * (i + 1)
  endfor
  num_all = num_clear + num_cloudy
  frequency_clear = dblarr(1, nb)
  frequency_cloudy = dblarr(1, nb)
  for i = 0, nb - 1 do begin
    frequency_clear[i] = weather[0, i] * (i + 1) / num_all
    frequency_cloudy[i] = weather[1, i] * (i + 1) / num_all
  endfor

  index = 0
  for i = 0, nb - 1 do if (frequency_clear[i] ne 0) || (frequency_cloudy[i] ne 0) then index = i
  out_clear = dblarr(1, index + 1)
  out_cloudy = dblarr(1, index + 1)
  for i = 0, index - 1 do begin
    out_clear[i] = frequency_clear[i]
    out_cloudy[i] = frequency_cloudy[i]
  endfor

  ;plot
  w = WINDOW(WINDOW_TITLE = "weather")
  p1 = PLOT(out_clear, "+b2D-", name = 'clear', /current);设置window关键字，使绘图窗口成为当前窗口，才能执行下面的关闭操作
  p2 = PLOT(out_cloudy, "+r2D-", name = 'cloudy', /overplot);设置window关键字，在窗口上重新绘制
  l = legend(target = [p1, p2], position = [100, 1.2], font_size = 8, /data)
  w.Close

  openw, lun, reuslt_name, /get_lun

  ;write out the distribution
  printf, lun, frequency_clear, format='(400F-8.3)'
  printf, lun, frequency_cloudy, format='(400F-8.3)'
  free_lun, lun

  close,lun

  envi_batch_exit

end