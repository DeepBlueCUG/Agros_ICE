;creat the quality band of the simulated
;Xinkai Liu
;China University of Geoscience
;2018.6.1

function script_ice_sg, frequency

  COMPILE_OPT idl2
  ENVI,/restore_base_save_files
  ENVI_BATCH_INIT, log_file='batch.txt'

  ;  quality_path = 'E:\Data\MODIS\txt\simulate\quality'
  ;  output_name = quality_path + 'simulate_quality_001.txt'

  dimension = size(frequency, /dimension)
  time_range = dimension[1]
  quality = dblarr(1, time_range)
  quality[0] = 1

  sequence = 1;the days that the weather situation lasts
  index = 1;the cloudy data is marked as 0 and the clear data is marked as 1
  for i = 0, time_range - 1 do begin ;given that the DOY 0 is clear

    case index of

      0: begin
        sample = randomu(seed, 1)
        if sample le frequency[index, sequence] / (frequency[1, 1] + frequency[index, sequence]) then begin
          quality[i] = 3
          sequence++
        endif else begin
          quality[i] = 1
          index = 1
          sequence = 2
        endelse
      end

      1: begin
        sample = randomu(seed, 1)
        if sample le frequency[index, sequence - 1] / (frequency[0, 0] + frequency[index, sequence - 1]) then begin
          quality[i] = 1
          sequence++
        endif else begin
          quality[i] = 3
          index = 0
          sequence = 2
        endelse
      end

      else:
    endcase

  endfor

  ;  openw, lun, output_name, /get_lun
  ;
  ;  ;注意在自由读写状态下，数组的读写格式是可以自行设定的
  ;  head = [3, time_range, 1];timesat的头文件要求必须是三年数据，这里取一个时间序列
  ;  printf, lun, head, format = '(4I-5)'
  ;  printf, lun, quality, format='(400F-8.3)';设置format代码的时候需要特别注意，如果
  ;  ;设置的字符宽度不够，那么将输出星号
  ;  printf, lun, quality, format='(400F-8.3)'
  ;  printf, lun, quality, format='(400F-8.3)'
  ;  free_lun, lun
  ;  ;如果不加format='(38f16.8)'，生成的csv默认只能5列。
  ;  ;或者,/get_lun后面加width=500也能增加列数
  ;  close,lun

  return, quality

end