"""
Script để setup database tự động
Người phụ trách: Người 1 - Data Engineer

Cách sử dụng:
python src/setup_database.py
"""

import os
import sys
from sqlalchemy import create_engine, text
from config import DB_CONFIG, SQL_SCHEMA_FILE
import logging

# Setup logging
os.makedirs('logs', exist_ok=True)
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/setup.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


def read_sql_file(file_path):
    """Đọc file SQL và trả về danh sách các câu lệnh"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Tách các câu lệnh SQL (loại bỏ comment và empty lines)
        statements = []
        current_statement = []
        
        for line in content.split('\n'):
            line = line.strip()
            # Bỏ qua comment và empty lines
            if line and not line.startswith('--'):
                current_statement.append(line)
                # Nếu kết thúc bằng ; thì đó là một statement hoàn chỉnh
                if line.endswith(';'):
                    statements.append(' '.join(current_statement))
                    current_statement = []
        
        return statements
    except FileNotFoundError:
        logger.error(f"File không tồn tại: {file_path}")
        return []


def setup_database():
    """Setup database và tạo schema"""
    try:
        # Tạo connection string (không có database name để tạo database)
        connection_string = f"mysql+pymysql://{DB_CONFIG['user']}:{DB_CONFIG['password']}@{DB_CONFIG['host']}:{DB_CONFIG['port']}"
        
        logger.info("Đang kết nối đến MySQL server...")
        engine = create_engine(connection_string, echo=False)
        
        # Test connection
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        logger.info("✓ Kết nối MySQL server thành công")
        
        # Đọc và thực thi schema.sql
        logger.info(f"Đang đọc file schema: {SQL_SCHEMA_FILE}")
        statements = read_sql_file(SQL_SCHEMA_FILE)
        
        if not statements:
            logger.error("Không tìm thấy câu lệnh SQL nào trong file schema")
            return False
        
        logger.info(f"Tìm thấy {len(statements)} câu lệnh SQL")
        
        # Thực thi từng câu lệnh
        with engine.connect() as conn:
            for i, statement in enumerate(statements, 1):
                try:
                    logger.info(f"Đang thực thi câu lệnh {i}/{len(statements)}...")
                    conn.execute(text(statement))
                    conn.commit()
                    logger.info(f"✓ Câu lệnh {i} thành công")
                except Exception as e:
                    logger.warning(f"⚠ Câu lệnh {i} có lỗi: {str(e)}")
                    # Tiếp tục với câu lệnh tiếp theo
        
        logger.info("✓ Setup database hoàn tất!")
        
        # Kiểm tra database đã được tạo
        with engine.connect() as conn:
            result = conn.execute(text(f"""
                SELECT COUNT(*) 
                FROM information_schema.tables 
                WHERE table_schema = '{DB_CONFIG['database']}'
            """))
            table_count = result.scalar()
            logger.info(f"✓ Database '{DB_CONFIG['database']}' có {table_count} bảng")
        
        return True
        
    except Exception as e:
        logger.error(f"✗ Lỗi khi setup database: {str(e)}", exc_info=True)
        return False


if __name__ == "__main__":
    success = setup_database()
    sys.exit(0 if success else 1)

