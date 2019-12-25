;The function of creating simulated observed data
;Xinkai Liu
;China University of Geoscience
;2018.5.22

function simulate_creat_observed_for_git, quality, random_factor, suppress_factor

  COMPILE_OPT idl2
  ENVI,/restore_base_save_files
  ENVI_BATCH_INIT, log_file='batch.txt'
  
  ;the path of the simulated true data, wich could be generated by softwares like matlab
  simulate_data = 'J:\Data\MODIS\process\simulate\ice_for_git\simulate_true.txt'
  ;  graph_path = 'E:\Data\MODIS\txt\test\Simulate\'
  ;  output_path = 'E:\Data\MODIS\txt\test\Simulate\'

  year = '2016'
  province = 'Heilongjiang'

  ;read in the simulated truth
  read = ''
  openr, lun, simulate_data, /get_lun
  skip_lun, lun, 1, /line
  readf, lun, read
  find_data = strsplit(read, ' ', /extract)
  num_data = size(find_data, /dimension)
  simulate_true = dblarr(1, num_data) 
  for i = 0, num_data[0] - 1 do  simulate_true[i] = double(find_data[i]) ;
  free_lun, lun

  time_range = size(quality, /dimension)
  simulate_observed = simulate_true

  ;add cloudy noise
  cloud_index = where(quality eq 3, count)
  cloud_noise = abs(randomn(seed, count, /double) * 0.1) 
  seed = !NULL
  for i = 0, count - 1 do simulate_observed[cloud_index[i]] = cloud_noise[i]

  ;add random noise
  unmarked_index = where(quality ne 3, count)
  random_noise = randomu(seed, count) * (random_factor * 2) - random_factor
  seed = !NULL
  suppress_noise = randomu(seed, count) * suppress_factor
  seed = !NULL
  unmarked_noise = random_noise - suppress_noise
  for i = 0, count - 1 do simulate_observed[unmarked_index[i]] = simulate_observed[unmarked_index[i]] + unmarked_noise[i]

  simulate = [simulate_true, simulate_observed]

  close, /all

  return, simulate

  ENVI_BATCH_EXIT

end