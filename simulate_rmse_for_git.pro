;computing RMSE
;Xinkai Liu
;China University of Geoscience
;2018.6.4
;
function simulate_rmse_for_git, data, simulate_data

  data_dimension = size(data, /dimension)
  rmse = dblarr(1, data_dimension[0])
  sum = 0
  for i = 0, data_dimension[0] - 1 do begin
    difference = data[i, *] - simulate_data
    square = difference * difference
    mse = mean(square)
    rmse[i] = sqrt(mse)
  endfor

  return, rmse

end