Experiment 1 conditions (a)–(c) are the circle stimulus with predictable 
sinusoidal horizontal motion, with peak velocities of 15, 30, and 45 deg/s respectively, 
and the experiment uses 23 refresh rates from 50 Hz to 165 Hz in steps of 5 Hz.

generate the dataset videos (Exp1 only, conditions a–c), using circle1.png, with lossless encoding.

Dataset definition (Exp1, conditions a–c)
Conditions
(a) predictable sinusoid, peak velocity 15 deg/s
(b) predictable sinusoid, peak velocity 30 deg/s
(c) predictable sinusoid, peak velocity 45 deg/s 
Frame rates (Hz / fps)
    {50, 55, 60, …, 165} (step 5) 
Motion (per Fig. 6-left, “sinusoid motion”)
Let horizontal position in visual degrees be:
    𝜃(𝑡)=𝐴sin⁡(2𝜋𝑓0𝑡)θ(t)=Asin(2πf0t)
    v_\max = 2\pi f_0 A \quad\Rightarrow\quad f_0=\frac{v_\max}{2\pi A}

The paper states 108 cm viewing distance (~30° FOV) for the setup.
 $2π f_0$ 是为了将“周数”（频率）转换为“弧度"
 f0 (cycles per second).
 2𝜋𝑓0 is the angular frequency 𝜔
 vmax​=2πf0​
 f0​=vmax / 2πA​​

 频率 $f_0$ 代表物体在单位时间内完成的完整循环次数（周数/秒，单位为 Hz）
 如果 $f_0 = 1$ Hz，意味着 1 秒钟完成 1 次循环。
 如果 $f_0 = 5$ Hz，意味着 1 秒钟完成 5 次循环
 为了简化表达，物理学中定义 角频率 $\omega = 2\pi f_0$ 
 $f_0$ (频率)：每秒转了多少圈。$\omega$ (角频率)：每秒转了多少弧度。

第 6.1.1 节关于“实验 2”的描述中提到，对于可预测运动，水平位移遵循正弦函数，其振幅为 17° 。
此外，在第 4.1.2 节描述不可预测运动的公式1时，也使用了 17° 作为系数来定义物体的水平位置

dataset_exp1_abc/
  condition_a_v15/
    fps_050/ circle_v15_fps050_lossless.mkv
    ...
    fps_165/ circle_v15_fps165_lossless.mkv
  condition_b_v30/
    ...
  condition_c_v45/
    ...
