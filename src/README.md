# Data Engineering Scripts

**Người phụ trách:** Người 1 - Data Engineer

## Tổng quan

Thư mục này chứa các script Python để quản lý database và import dữ liệu.

## Các file

### 1. `config.py`
File cấu hình chung cho tất cả các script:
- Database configuration
- File paths
- Column definitions
- Import settings

### 2. `setup_database.py`
Script để tự động setup database và tạo schema.

**Cách sử dụng:**
```bash
python src/setup_database.py
```

**Chức năng:**
- Tạo database `foodpanda_db`
- Tạo bảng `foodpanda_orders` với schema đầy đủ
- Tạo các views: `vw_daily_orders`, `vw_restaurant_stats`, `vw_customer_stats`
- Tạo indexes để tối ưu query

### 3. `check_database.py`
Script để kiểm tra trạng thái database.

**Cách sử dụng:**
```bash
python src/check_database.py
```

**Chức năng:**
- Kiểm tra kết nối database
- Kiểm tra bảng đã tồn tại chưa
- Đếm số dòng trong bảng
- Liệt kê các views đã tạo

### 4. `import_to_sql.py`
Script chính để import dữ liệu từ CSV vào MySQL.

**Cách sử dụng:**
```bash
# Import dữ liệu (replace nếu bảng đã tồn tại)
python src/import_to_sql.py

# Chỉ validate dữ liệu, không import
python src/import_to_sql.py --validate

# Append thêm dữ liệu (không replace)
python src/import_to_sql.py --append
```

**Chức năng:**
- Validate CSV file và cấu trúc dữ liệu
- Xử lý và chuyển đổi date columns
- Làm sạch dữ liệu (trim whitespace, convert types)
- Import vào MySQL với chunking để xử lý file lớn
- Verify import thành công

## Quy trình làm việc

### Bước 1: Setup môi trường
```bash
# Cài đặt dependencies
pip install -r requirements.txt

# Tạo file .env từ template
cp .env.example .env
# Cập nhật thông tin database trong .env
```

### Bước 2: Setup database
```bash
# Tạo database và schema
python src/setup_database.py

# Kiểm tra database đã setup đúng chưa
python src/check_database.py
```

### Bước 3: Import dữ liệu
```bash
# Validate dữ liệu trước
python src/import_to_sql.py --validate

# Import dữ liệu
python src/import_to_sql.py
```

### Bước 4: Sử dụng SQL queries
Xem file `../sql/queries.sql` để có các query mẫu để extract dữ liệu.

## Log files

Tất cả các log được lưu trong thư mục `../logs/`:
- `logs/import.log` - Log từ import_to_sql.py
- `logs/setup.log` - Log từ setup_database.py

## Troubleshooting

### Lỗi kết nối database
- Kiểm tra MySQL service đã chạy chưa
- Kiểm tra thông tin trong file `.env` đúng chưa
- Kiểm tra user có quyền tạo database không

### Lỗi import dữ liệu
- Kiểm tra file CSV có tồn tại không: `data/foodpanda_orders.csv`
- Kiểm tra cấu trúc CSV có đúng với EXPECTED_COLUMNS không
- Xem log file để biết chi tiết lỗi: `logs/import.log`

### Lỗi schema
- Chạy lại `setup_database.py` để tạo lại schema
- Hoặc chạy trực tiếp file SQL: `mysql -u root -p < sql/schema.sql`

## Notes

- Tất cả các script sử dụng `config.py` để lấy cấu hình
- Log files được tự động tạo trong thư mục `logs/`
- Script import hỗ trợ chunking để xử lý file lớn hiệu quả
- Có thể validate dữ liệu trước khi import để kiểm tra chất lượng

