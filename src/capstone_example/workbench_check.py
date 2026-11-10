import sys
import pandas as pd
import matplotlib

print("Python:", sys.version)
print("Intérprete:", sys.executable)
print("pandas:", pd.__version__)
print("matplotlib:", matplotlib.__version__)

df = pd.DataFrame({"x": [1, 2, 3], "y": [2, 4, 6]})
print(df.describe())