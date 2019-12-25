# Agros_ICE
 ICE去云算法的示例代码
&emsp;&emsp;我们开源的仓库旨在说明论文Daily 250m MODIS NDVI Timeseries Reconstruction using Iterative Continuum Extraction and Savitzky-Golay Filter中所涉及的迭代包络线去云算法原理。目前仓库包含两个节点，第一个节点包括ICE_SG算法的原理脚本；第二个节点演示模拟实验的过程。


&emsp;&emsp;需要说明的是，我们采用的实验数据为MOD09GQ和MOD09GA，数据的预处理（重投影、裁剪、镶嵌、波段合成等）以及样本的选取等其他操作可在MRT、ENVI、ArcGIS等软件完成，相关代码可从其他开源渠道获得，我们在此感谢相关开源代码的作者对我们完成试验提供的帮助。并且我们提出的算法对高时间分辨率NDVI时间序列是普遍有效的，使用者可以根据需要设计自己的数据处理方式。


&emsp;&emsp;我们提供了示例文件以辅助理解代码，其中2016_Heilongjiang_dadou_raw_000.txt为时间序列NDVI数据，由MOD09GQ数据计算获得；simulate_true.txt是模拟实验使用的平滑曲线，由matlab timesat获得; weather.txt为simulate_weather_distribution_for_git读取MOD09GQ质量波段和MOD09GA云波段获取的天气分布


&emsp;&emsp;This open source repository aims to illustrate the NDVI timeseries reconstruction method in the paper Daily 250m MODIS NDVI Timeseries Reconstruction using Iterative Continuum Extraction and Savitzky-Golay Filter. The first branch includes the principle script of ICE_SG algorithm; the second branch demonstrates the process of simulation experiment.
