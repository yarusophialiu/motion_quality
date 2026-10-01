import scipy.io as sio

# 1. 加载 .mat 文件
mat_data = sio.loadmat('experiment_fps_jod/analysis/scaled_results.mat')

# 2. 查看文件中包含哪些变量名（Key）
print("Keys in mat file:", mat_data.keys())

# 3. 提取具体的变量值
# 注意：mat_data 是一个字典，通常包含 '__header__', '__version__', '__globals__' 等元数据
# 真正的数值存储在你定义的变量名下（例如 'scaled_scores'）
for key in mat_data.keys():
    if not key.startswith('__'):
        values = mat_data[key]
        print(f"\n变量名: {key}")
        print(f"数据类型: {type(values)}")
        print(f"数据维度 (Shape): {values.shape}")
        print("数值内容:")
        print(values)