;The function of interpolation and SG filtering
;Xinkai Liu
;China University of Geoscience
;2018.6.4
;
function simulate_sg_for_git, data, width

  ;Interpolating the empty data to make sure the SG filtering works
  process_data = data
  num_data = size(data, /dimension)
  seed_index = where(data ne -2, count)
  if count ne num_data[1] then begin
    seed_data = dblarr(1, count)
    for j = 0, count - 1 do seed_data[j] = data[seed_index[j]]
    data_index = uindgen(1, num_data[1]) ;输出结果的坐标
    process_data = interpol(seed_data, seed_index, data_index)
  endif

  ;conduct SG filtering 
  under_sg = transpose(process_data)
  sg_computer = savgol(width, width, 0, 2, /double)
  for i = 1, 3 do under_sg = convol(under_sg, sg_computer, invalid = -2)
  sg_result = dblarr(1, num_data[1] - width * 2)
  for i = width, num_data[1] - width - 1 do sg_result[i - width] = under_sg[i]

  return, sg_result

end