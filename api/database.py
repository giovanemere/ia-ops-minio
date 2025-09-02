#!/usr/bin/env python3
"""
Database configuration and models for IA-Ops MinIO
"""

import os
import logging
from sqlalchemy import create_engine, Column, Integer, String, DateTime, Text, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime

logger = logging.getLogger(__name__)

# Database configuration
DATABASE_URL = os.getenv('DATABASE_URL', 'postgresql://veritas_user:veritas_password@localhost:5432/veritas_db')

# Create engine
try:
    engine = create_engine(DATABASE_URL, echo=False)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    logger.info(f"Database engine created successfully")
except Exception as e:
    logger.error(f"Failed to create database engine: {e}")
    engine = None
    SessionLocal = None

Base = declarative_base()

class MinIOOperation(Base):
    """Model for MinIO operations logging"""
    __tablename__ = "minio_operations"
    
    id = Column(Integer, primary_key=True, index=True)
    operation_type = Column(String(50), nullable=False)  # list_buckets, list_objects, etc.
    bucket_name = Column(String(255), nullable=True)
    object_name = Column(String(500), nullable=True)
    user_agent = Column(String(255), nullable=True)
    ip_address = Column(String(45), nullable=True)
    timestamp = Column(DateTime, default=datetime.utcnow)
    success = Column(Boolean, default=True)
    error_message = Column(Text, nullable=True)
    response_time_ms = Column(Integer, nullable=True)

class MinIOStats(Base):
    """Model for MinIO statistics"""
    __tablename__ = "minio_stats"
    
    id = Column(Integer, primary_key=True, index=True)
    total_buckets = Column(Integer, default=0)
    total_objects = Column(Integer, default=0)
    total_size_bytes = Column(Integer, default=0)
    timestamp = Column(DateTime, default=datetime.utcnow)
    snapshot_data = Column(Text, nullable=True)  # JSON data

def get_db():
    """Get database session"""
    if SessionLocal is None:
        return None
    db = SessionLocal()
    try:
        return db
    except Exception as e:
        logger.error(f"Failed to create database session: {e}")
        return None

def init_database():
    """Initialize database tables"""
    if engine is None:
        logger.error("Database engine not available")
        return False
    
    try:
        Base.metadata.create_all(bind=engine)
        logger.info("Database tables created successfully")
        return True
    except Exception as e:
        logger.error(f"Failed to create database tables: {e}")
        return False

def log_operation(operation_type, bucket_name=None, object_name=None, 
                 user_agent=None, ip_address=None, success=True, 
                 error_message=None, response_time_ms=None):
    """Log MinIO operation to database"""
    db = get_db()
    if db is None:
        return False
    
    try:
        operation = MinIOOperation(
            operation_type=operation_type,
            bucket_name=bucket_name,
            object_name=object_name,
            user_agent=user_agent,
            ip_address=ip_address,
            success=success,
            error_message=error_message,
            response_time_ms=response_time_ms
        )
        db.add(operation)
        db.commit()
        return True
    except Exception as e:
        logger.error(f"Failed to log operation: {e}")
        db.rollback()
        return False
    finally:
        db.close()

def save_stats(total_buckets, total_objects, total_size_bytes, snapshot_data=None):
    """Save MinIO statistics to database"""
    db = get_db()
    if db is None:
        return False
    
    try:
        stats = MinIOStats(
            total_buckets=total_buckets,
            total_objects=total_objects,
            total_size_bytes=total_size_bytes,
            snapshot_data=snapshot_data
        )
        db.add(stats)
        db.commit()
        return True
    except Exception as e:
        logger.error(f"Failed to save stats: {e}")
        db.rollback()
        return False
    finally:
        db.close()
