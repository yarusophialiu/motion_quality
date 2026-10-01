This folder only contains look-up table generation scripts. 
The unity project lives in the Unity cloud (contact Akshay or Gyuri for further info)


cvvdp --test pano_v30_fps050_720p_lossless.mp4 --ref pano_v30_fps167_720p_lossless.mp4 --display asus_pg279q --flow-cache flow_cache --temp-resample 167 --spem
cvvdp --test pano_v30_fps050_720p_lossless.mp4 --ref pano_v30_fps167_720p_lossless.mp4 --display asus_pg279q --temp-resample 167 


theta：代表物体在视场FOV(0-30)中的角位移，即物体“应该”在多少度的地方