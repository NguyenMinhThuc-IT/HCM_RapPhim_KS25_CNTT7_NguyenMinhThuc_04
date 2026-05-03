CREATE DATABASE CINEMA;

USE CINEMA;

-- 1. Bảng movies
CREATE TABLE movies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    duration_minutes INT NOT NULL,
    age_restriction INT DEFAULT 0, -- Mặc định giới hạn độ tuổi là 0
    CONSTRAINT chk_age CHECK (age_restriction IN (0, 13, 16, 18))
);

-- 2. Bảng rooms
CREATE TABLE rooms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    max_seats INT NOT NULL,
    status ENUM('active', 'maintenance') DEFAULT 'active' -- Mặc định trạng thái là active
);

-- 3. Bảng showtimes
CREATE TABLE showtimes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    movie_id INT,
    room_id INT,
    show_time DATETIME NOT NULL,
    ticket_price DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_movie FOREIGN KEY (movie_id) REFERENCES movies(id),
    CONSTRAINT fk_room FOREIGN KEY (room_id) REFERENCES rooms(id),
    CONSTRAINT chk_price CHECK (ticket_price >= 0) -- Giá vé không được nhỏ hơn 0
);

-- 4. Bảng bookings
CREATE TABLE bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    showtime_id INT,
    customer_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    booking_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_showtime FOREIGN KEY (showtime_id) REFERENCES showtimes(id)
);

-- Đảm bảo đang sử dụng database CINERMA
USE CINEMA;

-- 1. Thêm 4 bộ phim đang hot, có một phim giới hạn 18 tuổi
INSERT INTO movies (title, duration_minutes, age_restriction) VALUES
('Avengers: Endgame', 181, 13),
('Doraemon: Nobita và Bản giao hưởng Địa cầu', 115, 0),
('Lật Mặt 7: Một Điều Ước', 138, 13),
('Deadpool & Wolverine', 127, 18); -- Phim giới hạn 18 tuổi

-- 2. Thêm 3 phòng chiếu, có 1 phòng đang bảo trì
INSERT INTO rooms (name, max_seats, status) VALUES
('Phòng Chiếu 01', 100, 'active'),
('Phòng Chiếu 02', 150, 'active'),
('Phòng Chiếu VIP', 50, 'maintenance'); -- Phòng đang bảo trì

-- 3. Thêm 5 Lịch chiếu (đảm bảo không xếp vào phòng đang bảo trì - ID 3)
-- Lưu ý: movie_id 1-4, room_id 1-2
INSERT INTO showtimes (movie_id, room_id, show_time, ticket_price) VALUES
(1, 1, '2024-05-01 18:00:00', 95000),
(2, 2, '2024-05-01 09:00:00', 75000),
(3, 1, '2024-05-01 21:00:00', 95000),
(4, 2, '2024-05-01 23:00:00', 110000),
(1, 2, '2024-05-02 14:00:00', 85000);

-- 4. Thêm 10 vé đặt rải rác cho các lịch chiếu khác nhau
INSERT INTO bookings (showtime_id, customer_name, phone) VALUES
(1, 'Nguyễn Văn A', '0901234567'),
(1, 'Trần Thị B', '0912345678'),
(2, 'Lê Văn C', '0923456789'),
(3, 'Phạm Minh D', '0934567890'),
(3, 'Hoàng Anh E', '0945678901'),
(4, 'Đặng Văn F', '0956789012'),
(4, 'Vũ Thị G', '0967890123'),
(5, 'Bùi Văn H', '0978901234'),
(5, 'Ngô Thị I', '0989012345'),
(2, 'Đỗ Minh J', '0990123456');

-- Đảm bảo đang ở trong database CINERMA
USE CINEMA;

-- 1. Phòng chiếu số 1 bị hỏng điều hòa, chuyển trạng thái sang bảo trì
SET SQL_SAFE_UPDATES = 0;
UPDATE rooms 
SET status = 'maintenance' 
WHERE id = 1;
SET SQL_SAFE_UPDATES = 1;

-- 2. Chuyển tất cả lịch chiếu từ phòng 1 sang phòng 2
SET SQL_SAFE_UPDATES = 0;
UPDATE showtimes 
SET room_id = 2 
WHERE room_id = 1;
SET SQL_SAFE_UPDATES = 1;

-- 3. Hủy toàn bộ vé của khách hàng có số điện thoại 0987654321
SET SQL_SAFE_UPDATES = 0;
DELETE FROM bookings 
WHERE phone = '0987654321';
SET SQL_SAFE_UPDATES = 1;

-- Xóa các lượt đặt vé liên quan đến các suất chiếu của phim này trước
SET SQL_SAFE_UPDATES = 0;
DELETE FROM bookings 
WHERE showtime_id IN (SELECT id FROM showtimes WHERE movie_id = 3);
SET SQL_SAFE_UPDATES = 1;

-- Xóa các lịch chiếu của phim này
SET SQL_SAFE_UPDATES = 0;
DELETE FROM showtimes 
WHERE movie_id = 3;
SET SQL_SAFE_UPDATES = 1;

-- Cuối cùng mới xóa bộ phim khỏi bảng movies
SET SQL_SAFE_UPDATES = 0;
DELETE FROM movies 
WHERE id = 3;
SET SQL_SAFE_UPDATES = 1;