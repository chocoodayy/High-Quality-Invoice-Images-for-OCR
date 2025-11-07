# Hướng Dẫn Database Setup

**Người phụ trách:** Người 1 - Data Engineer

## Cài đặt MySQL

1. Cài đặt MySQL Server (nếu chưa có)
   - Ubuntu/Debian: `sudo apt-get install mysql-server`
   - macOS: `brew install mysql`
   - Windows: Download từ [MySQL website](https://dev.mysql.com/downloads/mysql/)

2. Khởi động MySQL service:
   ```bash
   sudo systemctl start mysql  # Linux
   brew services start mysql   # macOS
   ```

## Thiết lập Database

### Bước 1: Cấu hình kết nối

Tạo file `.env` trong thư mục gốc từ `.env.example`:

```bash
cp .env.example .env
```

Cập nhật thông tin trong file `.env`:
```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password_here
DB_NAME=foodpanda_db
DB_PORT=3306
```

### Bước 2: Tạo database và schema (Tự động)

**Cách 1: Sử dụng script Python (Khuyến nghị)**
```bash
# Cài đặt dependencies
pip install -r requirements.txt

# Setup database tự động
python src/setup_database.py
```

**Cách 2: Sử dụng MySQL command line**
```bash
mysql -u root -p < sql/schema.sql
```

Hoặc chạy từng lệnh trong MySQL:
```sql
CREATE DATABASE IF NOT EXISTS foodpanda_db;
USE foodpanda_db;
-- Sau đó copy nội dung từ schema.sql
```

### Bước 3: Kiểm tra database

```bash
python src/check_database.py
```

### Bước 4: Import dữ liệu

```bash
# Import dữ liệu từ CSV
python src/import_to_sql.py

# Hoặc chỉ validate dữ liệu (không import)
python src/import_to_sql.py --validate

# Hoặc append thêm dữ liệu (không replace)
python src/import_to_sql.py --append
```

## Sử dụng SQL Queries

File `queries.sql` chứa các query mẫu để extract dữ liệu phục vụ phân tích:

- Tổng hợp đơn hàng theo ngày
- Top nhà hàng theo doanh thu
- Top khách hàng chi tiêu nhiều nhất
- Thống kê theo thành phố, phương thức thanh toán
- Phân tích churned customers
- Và nhiều query khác...

Chạy các query:

```bash
mysql -u root -p foodpanda_db < sql/queries.sql
```

Hoặc mở MySQL và copy từng query để chạy.

## Views đã tạo

- `vw_daily_orders`: Tổng hợp đơn hàng theo ngày
- `vw_restaurant_stats`: Thống kê theo nhà hàng
- `vw_customer_stats`: Thống kê theo khách hàng

Sử dụng views:

```sql
SELECT * FROM vw_daily_orders LIMIT 10;
SELECT * FROM vw_restaurant_stats LIMIT 10;
SELECT * FROM vw_customer_stats LIMIT 10;
```

