"""
Script để kiểm tra trạng thái database
Người phụ trách: Người 1 - Data Engineer

Cách sử dụng:
python src/check_database.py
"""

import sys
from sqlalchemy import create_engine, text
from config import DB_CONFIG, TABLE_ORDERS
import logging

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler()]
)
logger = logging.getLogger(__name__)


def check_database():
    """Kiểm tra trạng thái database"""
    try:
        # Tạo connection string
        connection_string = f"mysql+pymysql://{DB_CONFIG['user']}:{DB_CONFIG['password']}@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}"
        
        logger.info(f"Đang kết nối đến database: {DB_CONFIG['database']}@{DB_CONFIG['host']}")
        engine = create_engine(connection_string, echo=False)
        
        with engine.connect() as conn:
            # Kiểm tra connection
            conn.execute(text("SELECT 1"))
            logger.info("✓ Kết nối database thành công")
            
            # Kiểm tra bảng tồn tại
            result = conn.execute(text(f"""
                SELECT COUNT(*) 
                FROM information_schema.tables 
                WHERE table_schema = '{DB_CONFIG['database']}' 
                AND table_name = '{TABLE_ORDERS}'
            """))
            
            if result.scalar() > 0:
                logger.info(f"✓ Bảng '{TABLE_ORDERS}' đã tồn tại")
                
                # Đếm số dòng
                count_result = conn.execute(text(f"SELECT COUNT(*) FROM {TABLE_ORDERS}"))
                row_count = count_result.scalar()
                logger.info(f"✓ Số dòng trong bảng: {row_count:,}")
                
                # Kiểm tra views
                views_result = conn.execute(text(f"""
                    SELECT table_name 
                    FROM information_schema.views 
                    WHERE table_schema = '{DB_CONFIG['database']}'
                """))
                views = [row[0] for row in views_result]
                if views:
                    logger.info(f"✓ Có {len(views)} views: {', '.join(views)}")
                else:
                    logger.warning("⚠ Chưa có views nào")
                
            else:
                logger.warning(f"⚠ Bảng '{TABLE_ORDERS}' chưa tồn tại")
                logger.info("Chạy: python src/setup_database.py để tạo database")
                return False
        
        logger.info("✓ Kiểm tra database hoàn tất!")
        return True
        
    except Exception as e:
        logger.error(f"✗ Lỗi khi kiểm tra database: {str(e)}")
        logger.info("Kiểm tra lại thông tin kết nối trong file .env")
        return False


if __name__ == "__main__":
    success = check_database()
    sys.exit(0 if success else 1)

