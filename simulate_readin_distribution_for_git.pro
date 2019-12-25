;read the weather distribution into the simulated experiment
;Xinkai Liu
;China University of Geoscience
;2018.7.9
;
function simulate_readin_distribution_for_git

  reuslt_name = 'J:\Data\MODIS\process\simulate\ice_for_git\weather.txt'

  tmp = ''
  nLines = file_lines(reuslt_name)

  openr, lun, reuslt_name, /get_lun
  readf, lun, tmp
  finddata = strsplit(tmp, ' ', /extract)
  sizedata = size(finddata, /dimension)
  ;      sizedata = fix(sizedata / 3)
  tmpdata = dblarr(1, sizedata)
  ;      for j = 0, sizedata[0] - 1 do  tmpdata[j] = double(finddata[j + sizedata[0]])
  frequency_clear = dblarr(1, sizedata)
  for j = 0, sizedata[0] - 1 do  frequency_clear[j] = double(finddata[j])
  readf, lun, tmp
  finddata = strsplit(tmp, ' ', /extract)
  sizedata = size(finddata, /dimension)
  ;      sizedata = fix(sizedata / 3)
  tmpdata = dblarr(1, sizedata)
  ;      for j = 0, sizedata[0] - 1 do  tmpdata[j] = double(finddata[j + sizedata[0]])
  frequency_cloudy = dblarr(1, sizedata)
  for j = 0, sizedata[0] - 1 do  frequency_cloudy[j] = double(finddata[j])
  free_lun, lun

  ;  index = 0
  ;  for i = 0, sizedata[0] - 1 do if (frequency_clear[i] ne 0) || (frequency_cloudy[i] ne 0) then index = i
  ;  out_clear = dblarr(1, index + 2)
  ;  out_cloudy = dblarr(1, index + 2)
  ;  for i = 1, index + 1 do begin
  ;    out_clear[i] = frequency_clear[i - 1]
  ;    out_cloudy[i] = frequency_cloudy[i - 1]
  ;  endfor

  frequency = [frequency_cloudy, frequency_clear]
  return, frequency

end