from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("DevSparkApp") \
    .master("local[*]") \
    .getOrCreate()

df = spark.read.csv("customers.csv", header=True, inferSchema=True)
df.show()