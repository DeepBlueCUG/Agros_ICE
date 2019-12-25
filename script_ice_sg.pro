;The script of ICE-SG algorithm, this script is intended to show how the proposed ICE-SG method works
;Xinkai Liu
;China University of Geoscience
;2018.6.6

pro script_ice_sg

  COMPILE_OPT idl2
  ENVI,/restore_base_save_files
  ENVI_BATCH_INIT, log_file='batch.txt'

  sg_width = 12 ;the window size of SG filtering
  rawdata_path = 'H:\IDL_Workspace\for_figures\raw\2016_Heilongjiang_dadou_raw_000.txt'
  
  ;our txt files is set convenient for matlab timesat, users may define their own format of the txt files
  tmp = ''
  openr, lun, rawdata_path, /get_lun
  skip_lun, lun, 1, /line 
  readf, lun, tmp
  find_data = strsplit(tmp, ' ', /extract)
  num_data = size(find_data, /dimension)
  raw_data = dblarr(1, num_data)
  for j = 0, num_data[0] - 1 do  raw_data[j] = double(find_data[j])
  free_lun, lun

  ice = ice_for_git(raw_data, 3, 25)
  ice_sg = simulate_sg_for_git(ice, sg_width)

  ENVI_BATCH_EXIT

end
