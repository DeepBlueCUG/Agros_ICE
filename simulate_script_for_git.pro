;The script of the simulated experiment
;Xinkai Liu
;China University of Geoscience
;2018.10.8
pro simulate_script_for_git

  COMPILE_OPT idl2
  ENVI,/restore_base_save_files
  ENVI_BATCH_INIT, log_file='batch.txt'
  ;we set different noise situation, and the experiments under every situation should be repeated(set as 30 times) 
  repetition = 1 
  sg_width = 12 ;window size of the SG filter
  
  ;computing the weather distribution
  ;frequency = simulate_weather_distribution_for_git
  frequency = simulate_readin_distribution_for_git()
  
  ;read in the head of the simulate_true.txt
  simulate_true_file = 'J:\Data\MODIS\process\simulate\ice_for_git\simulate_true.txt' ;time_range的问题还是以模拟真值的时间范围（也就是波段数）确定
  read = ''
  openr, lun, simulate_true_file, /get_lun
  readf, lun, read
  find_data = strsplit(read, ' ', /extract)
  time_range = double(find_data[1])
  free_lun, lun
  
  
  ;the box of armes
  rmse_arr = dblarr(21, 21, 6)

  x = 0
  y = 0
  for i = 0.0, 0.21, 0.01 do begin
    for j = 0.0, 0.21, 0.01 do begin

      rmse = dblarr(6, repetition)

      for k = 1, repetition do begin

        quality = Simulate_quality_for_git(frequency)

        random_factor = i ;random noise
        suppress_factor = j ;weather noise
        simulate = simulate_creat_observed_for_git(quality, random_factor, suppress_factor)

        simulate_true = simulate[0, *]
        simulate_observed = simulate[1, *]

        ;reset the dimension of the data
        output_true = dblarr(1, time_range - sg_width * 2)
        for m = sg_width, time_range[0] - sg_width - 1 do output_true[m - sg_width] = simulate_true[m]

        output_quality = dblarr(1, time_range - sg_width * 2)
        for m = sg_width, time_range[0] - sg_width - 1 do output_quality[m - sg_width] = quality[m]

;        observed_sg = simulate_sg(simulate_observed, sg_width)
;        output_observed = dblarr(1, time_range - sg_width * 2)
;        for m = sg_width, time_range[0] - sg_width - 1 do output_observed[m - sg_width] = simulate_observed[m]

        ice_denoise = ice_for_git(simulate_observed, 3, 25)
        ice_sg = simulate_sg_for_git(ice_denoise, sg_width)
        ice = dblarr(1, time_range - sg_width * 2)
        for m = sg_width, time_range[0] - sg_width - 1 do ice[m - sg_width] = ice_denoise[m]

;        bise_denoise = samplestest_do_bise(simulate_observed, 25, 0.4, 0.3)
;        bise_sg = simulate_sg(bise_denoise, sg_width)
;        bise = dblarr(1, time_range - sg_width * 2)
;        for m = sg_width, time_range[0] - sg_width - 1 do bise[m - sg_width] = bise_denoise[m]
;
;        mbise_denoise = samplestest_do_bisepro(simulate_observed)
;        mbise_sg = simulate_sg(mbise_denoise, sg_width)
;        mbise = dblarr(1, time_range - sg_width * 2)
;        for m = sg_width, time_range[0] - sg_width - 1 do mbise[m - sg_width] = mbise_denoise[m]
;
;        qaqc_denoise = samplestest_do_interpolation(simulate_observed, quality)
;        qaqc_sg = simulate_sg(qaqc_denoise, sg_width)
;        qaqc = dblarr(1, time_range - sg_width * 2)
;        for m = sg_width, time_range[0] - sg_width - 1 do qaqc[m - sg_width] = qaqc_denoise[m]
;
;        mvc_denoise = samplestest_do_mvc(simulate_observed, 25)
;        mvc_sg = simulate_sg(mvc_denoise, sg_width)
;        mvc = dblarr(1, time_range - sg_width * 2)
;        for m = sg_width, time_range[0] - sg_width - 1 do mvc[m - sg_width] = mvc_denoise[m]


        ;        ;验证用，绘制降噪和滤波的效果图
        ;        num_output_data = time_range[0] - sg_width * 2
        ;        ice_data = []
        ;        bise_data = []
        ;        mbise_data = []
        ;        mvc_data = []
        ;        bad_data = []
        ;        for m = 0, num_output_data[0] - 1 do if ice[m] ne -2 then ice_data = [[ice_data], [ice[m], m]]
        ;        for m = 0, num_output_data[0] - 1 do if bise[m] ne -2 then bise_data = [[bise_data], [bise[m], m]]
        ;        for m = 0, num_output_data[0] - 1 do if mbise[m] ne -2 then mbise_data = [[mbise_data], [mbise[m], m]]
        ;        for m = 0, num_output_data[0] - 1 do if mvc[m] ne -2 then mvc_data = [[mvc_data], [mvc[m], m]]
        ;        for m = 0, num_output_data[0] - 1 do if output_quality[m] eq 3 then bad_data = [[bad_data], [output_observed[m], m]]
        ;
        ;        w = WINDOW(WINDOW_TITLE = 'test_denoised')
        ;        p1 = PLOT(output_observed, linestyle = '', symbol = '+', name = 'Simulate Observed', $
        ;          color = 'deep_sky_blue', thick = 2, /current);设置window关键字，使绘图窗口成为当前窗口，才能执行下面的关闭操作
        ;        p2 = PLOT(bad_data[1, *], bad_data[0, *], linestyle = '', symbol = 'o', name = 'Bad Data', $
        ;          color = 'r', thick = 2, /overplot)
        ;        p3 = PLOT(ice_data[1, *], ice_data[0, *], name = 'ICE', linestyle = '-', color = 'b', thick = 2, /overplot)
        ;        p4 = PLOT(bise_data[1, *], bise_data[0, *], linestyle = '-', name = 'BISE', color = 'orange', thick = 2, /overplot)
        ;        p5 = PLOT(qaqc, name = 'QAQC', linestyle = '-', color = 'g', thick = 2, /overplot)
        ;        p6 = PLOT(mvc_data[1, *], mvc_data[0, *], linestyle = '-', name = 'MVC', color = 'r', thick = 2, /overplot)
        ;        p7 = PLOT(output_true, name = 'Simulate True', linestyle = '-', color = 'brown', thick = 2, /overplot)
        ;
        ;        l = legend(target = [p1, p2, p3, p4, p5, p6, p7], position = [0, 0.5], /data)
        ;        wait, 0.3
        ;        w.Close
        ;
        ;        w = WINDOW(WINDOW_TITLE = 'test_sg')
        ;        p1 = PLOT(output_observed, linestyle = '', symbol = '+', name = 'Simulate Observed', $
        ;          color = 'deep_sky_blue', thick = 2, /current);设置window关键字，使绘图窗口成为当前窗口，才能执行下面的关闭操作
        ;        p2 = PLOT(bad_data[1, *], bad_data[0, *], linestyle = '', symbol = 'o', name = 'Bad Data', $
        ;          color = 'r', thick = 2, /overplot)
        ;        p3 = PLOT(ice_sg, name = 'ICE_SG', linestyle = '-', color = 'b', thick = 2, /overplot)
        ;        p4 = PLOT(bise_sg, linestyle = '-', name = 'BISE_SG', color = 'orange', thick = 2, /overplot)
        ;        p5 = PLOT(qaqc_sg, name = 'QAQC_SG', linestyle = '-', color = 'g', thick = 2, /overplot)
        ;        p6 = PLOT(mvc_sg, linestyle = '-', name = 'MVC_SG', color = 'r', thick = 2, /overplot)
        ;        p8 = PLOT(observed_sg, name = 'Observed_SG', linestyle = '-', color = 'purple', thick = 2, /overplot)
        ;        p7 = PLOT(output_true, name = 'Simulate True', linestyle = '-', color = 'brown', thick = 2, /overplot)
        ;
        ;        l = legend(target = [p1, p2, p3, p4, p5, p6, p7], position = [0, 0.5], /data)
        ;        wait, 0.3
        ;        w.Close

        ;data = [observed_sg, ice_sg, bise_sg, mbise_sg, qaqc_sg, mvc_sg]
        ;data_dimension = size(data, /dimension)
        data = ice_sg
        data_dimension = size(data, /dimension)

        for m = 0, data_dimension[0] - 1 do rmse[m, k - 1] = simulate_rmse_for_git(data[m, *], simulate_true)

        a = where(quality eq 3, count)
        print, string(count) + string(i) + string(j)



        ;        if k eq 1 then begin
        ;
        ;          quality_name = denoised_path + 'Quality_SG_' + string(i, format = '(f-5.2)') + '_' + string(j, format = '(f-5.2)') + '.txt'
        ;          observed_name = denoised_path + 'Observed_SG_' + string(i, format = '(f-5.2)') + '_' + string(j, format = '(f-5.2)') + '.txt'
        ;          envelope_name = denoised_path + 'Envelpoe_SG_' + string(i, format = '(f-5.2)') + '_' + string(j, format = '(f-5.2)') + '.txt'
        ;          bise_name = denoised_path + 'Bise_SG_' + string(i, format = '(f-5.2)') + '_' + string(j, format = '(f-5.2)') + '.txt'
        ;          interpolation_name = denoised_path + 'Interpolation_SG_' + string(i, format = '(f-5.2)') + '_' + string(j, format = '(f-5.2)') + '.txt'
        ;          mvc_name = denoised_path + 'Mvc_SG_' + string(i, format = '(f-5.2)') + '_' + string(j, format = '(f-5.2)') + '.txt'
        ;          name_list = [quality_name, observed_name, envelope_name, bise_name, interpolation_name, mvc_name]
        ;          num_name = size(name_list, /dimension)
        ;
        ;          ;写入文件头
        ;          for i = 0, num_name[0] - 1 do begin
        ;            openw, lun, name_list[i], /get_lun
        ;            head = [repetition, time_range, 1];timesat的头文件要求必须是三年数据，这里取一个时间序列
        ;            printf, lun, head, format = '(4I-5)'
        ;            free_lun, lun
        ;          endfor
        ;
        ;        endif
        ;
        ;        for m = 0, num_name[0] - 1 do begin
        ;          openu, lun, name_list[m], /get_lun ;openw是创建新文件，而openu的方法使以更新模式打开已经存在的文件
        ;          printf, lun, data[m, *], format='(400F-8.3)'
        ;          free_lun, lun
        ;        endfor

      endfor

      for k = 0, 5 do rmse_arr[x, y, k] = mean(rmse[k, *])
      y++
    endfor
    y = 0
    x++
  endfor

  ;不画图了，直接输出各种滤波结果的文本文件

  ;  ;绘制三维均方根误差分布图
  ;  x_aixs = dblarr(21, 21);x轴
  ;  i = 0
  ;  for v = 0.0, 0.21, 0.01 do begin
  ;    for j = 0, 20 do x_aixs[i, j] = v
  ;    i++
  ;  endfor
  ;  y_aixs = dblarr(21, 21);x轴
  ;  i = 0
  ;  for v = 0.0, 0.21, 0.01 do begin
  ;    for j = 0, 20 do y_aixs[j, i] = v
  ;    i++
  ;  endfor
  ;  graph_path = 'E:\Data\MODIS\txt\test\'
  ;  graph_name = graph_path + 'RMSE_Distribution.jpg'
  ;  w = WINDOW(WINDOW_TITLE = 'test_sg')
  ;  p1 = surface(rmse_arr[*, *, 0], x_aixs, y_aixs, xtitle = 'v2', ytitle = 'v1', ztitle = 'RMSE', $
  ;    name = 'Observed SG', color = 'red', /current)
  ;  p2 = surface(rmse_arr[*, *, 1], x_aixs, y_aixs, name = 'ICE SG', color = 'blue', /current, overplot = 1)
  ;  p3 = surface(rmse_arr[*, *, 2], x_aixs, y_aixs, name = 'BISE SG', color = 'yellow', /current, overplot = 1)
  ;  p4 = surface(rmse_arr[*, *, 3], x_aixs, y_aixs, name = 'BISE Pro SG', color = 'purple', /current, overplot = 1)
  ;  p5 = surface(rmse_arr[*, *, 4], x_aixs, y_aixs, name = 'Interpolation SG', color = 'green', /current, overplot = 1)
  ;  p6 = surface(rmse_arr[*, *, 5], x_aixs, y_aixs, name = 'MVC', color = 'deep_sky_blue', /current, overplot = 1)
  ;  w.safe, graph_name
  ;  w.Close

  ;滤波数据写入文件，供matlab进行绘制
  output_path = 'J:\Data\MODIS\process\simulate\ice_for_git\'
  data_name = 'ice_sg'
  ;data_name = ['observed_sg', 'ice_sg', 'bise_sg', 'mbise_sg', 'qaqc_sg', 'mvc_sg']
  output_name = output_path + data_name + '.txt'
  openw, lun, output_name, /get_lun
  for j = 0, 20 do begin
    printf, lun, rmse_arr[j, *, i], format='(400F-8.3)' ;x is random noise and y is weather noise
  endfor
  free_lun, lun
  close, /all ;


  ENVI_BATCH_EXIT

end