-- Создаем свои типы данных
CREATE TYPE user_role AS ENUM ('PASSENGER', 'DRIVER', 'ADMIN');
CREATE TYPE driver_status AS ENUM ('PENDING', 'APPROVED', 'REJECTED');
CREATE TYPE trip_status AS ENUM ('SEARCHING', 'ACCEPTED', 'ARRIVED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED');

-- 1. Таблица пользователей
CREATE TABLE users (
                       id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                       phone VARCHAR(20) UNIQUE NOT NULL,
                       email VARCHAR(255) UNIQUE NOT NULL,
                       password_hash VARCHAR(255) NOT NULL,
                       full_name VARCHAR(100) NOT NULL,
                       role user_role NOT NULL,
                       avatar_url VARCHAR(255),
                       rating DECIMAL(3,2) DEFAULT 5.00,
                       is_blocked BOOLEAN DEFAULT false,
                       created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Таблица сессий (для Refresh токенов)
CREATE TABLE sessions (
                          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                          user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                          refresh_token VARCHAR(512) NOT NULL UNIQUE,
                          device_id VARCHAR(255) NOT NULL,
                          expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
                          created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                          UNIQUE(user_id, device_id)
);

-- 3. Таблица профилей водителей
CREATE TABLE driver_profiles (
                                 user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
                                 car_make VARCHAR(50) NOT NULL,
                                 car_model VARCHAR(50) NOT NULL,
                                 car_color VARCHAR(30) NOT NULL,
                                 license_plate VARCHAR(20) UNIQUE NOT NULL,
                                 status driver_status DEFAULT 'PENDING'
);

-- 4. Таблица поездок
CREATE TABLE trips (
                       id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                       passenger_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
                       driver_id UUID REFERENCES users(id) ON DELETE SET NULL, -- Водителя может еще не быть
                       status trip_status DEFAULT 'SEARCHING',
                       pickup_address TEXT NOT NULL,
                       dest_address TEXT NOT NULL,
                       pickup_lat DOUBLE PRECISION NOT NULL,
                       pickup_lng DOUBLE PRECISION NOT NULL,
                       dest_lat DOUBLE PRECISION NOT NULL,
                       dest_lng DOUBLE PRECISION NOT NULL,
                       price_kzt INTEGER NOT NULL,
                       created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                       accepted_at TIMESTAMP WITH TIME ZONE,
                       finished_at TIMESTAMP WITH TIME ZONE
);

-- 5. Таблица отзывов
CREATE TABLE reviews (
                         id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                         trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
                         reviewer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                         target_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                         score INTEGER NOT NULL CHECK (score >= 1 AND score <= 5),
                         comment TEXT,
                         created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Создаем индексы для быстрого поиска
CREATE INDEX idx_sessions_refresh_token ON sessions(refresh_token);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_trips_passenger_id ON trips(passenger_id);
CREATE INDEX idx_trips_driver_id ON trips(driver_id);
CREATE INDEX idx_trips_status ON trips(status);

--
-- DROP TABLE IF EXISTS reviews;
-- DROP TABLE IF EXISTS trips;
-- DROP TABLE IF EXISTS driver_profiles;
-- DROP TABLE IF EXISTS users;
--
-- -- Удаляем типы данных
-- DROP TYPE IF EXISTS trip_status;
-- DROP TYPE IF EXISTS driver_status;
-- DROP TYPE IF EXISTS user_role;