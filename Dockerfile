FROM julia:latest
MAINTAINER Hai Au

# Đặt thư mục làm việc trong container
WORKDIR /app
# Sao chép các file từ máy chủ vào container
COPY . /app

RUN julia -e 'using Pkg; \
              Pkg.add("Dash"); \
              Pkg.add("Sockets"); \
              Pkg.add("CSV"); \
              Pkg.add("DataFrames"); \
              Pkg.add("Dates"); \
              Pkg.add("PlotlyJS"); \
              Pkg.add("Statistics"); \
              Pkg.add("Missings")'
EXPOSE 8050

# Xác định lệnh mặc định khi container khởi chạy
CMD ["julia", "app.jl"]