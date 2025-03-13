# Global.R - 处理数据和加载数据
library(sf)
library(raster)
library(terra)
library(RColorBrewer)  # 需要用于调色板
library(leaflet)  # 需要用于 addRasterImage()

# 加载数据
lw_points <- st_read("lw_points.shp")
river <- st_read("RiverIsonzo.shp")
bridges <- st_read("BridgesIsonzo.shp")
nearest_distance <- st_read("NearestDistance.shp")  

# 投影转换
lw_points <- st_transform(lw_points, crs = 4326)
river <- st_transform(river, crs = 4326)
bridges <- st_transform(bridges, crs = 4326)
nearest_distance <- st_transform(nearest_distance, crs = 4326)

# 动态生成颜色调色板
num_lw_points <- length(unique(lw_points$LW_Type))
pal_lw_points <- colorFactor(palette = colorRampPalette(brewer.pal(12, "Paired"))(num_clusters), 
                            domain = lw_points$LW_Type)

# 加载聚类数据
clusters <- st_read("IsonzoClusters.shp")
clusters <- st_transform(clusters, crs = 4326)
# 动态生成颜色调色板
num_clusters <- length(unique(clusters$CLUSTER_ID))
pal_clusters <- colorFactor(palette = colorRampPalette(brewer.pal(12, "Paired"))(num_clusters), 
                            domain = clusters$CLUSTER_ID)

# 读取热图数据，并确保投影匹配
heatmap <- rast("Heatmap.tif")  # 读取 SpatRaster
heatmap <- project(heatmap, crs(river))  # 重新投影
heatmap <- raster(heatmap)  # **转换为 RasterLayer**

# 定义颜色调色板
pal_heatmap <- colorNumeric(palette = "inferno", domain = values(heatmap), na.color = "transparent")

# `addRasterImage()` 应该在 `Server.R` 里，而不是 `Global.R`
# 这里只是定义数据，不要直接调用 addRasterImage()