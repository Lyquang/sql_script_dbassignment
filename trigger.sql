use db_assignment;
-- viet 5 trigger cho cac rang buoc ngu nghia
-- 1 . Mỗi phòng ban phải có một quản lý có ít nhất 6 năm kinh nghiệm làm việc trong công ty.
DROP TRIGGER IF EXISTS exp_over_6years_onINSERT;
DELIMITER $$
CREATE TRIGGER exp_over_6years_onINSERT
BEFORE INSERT ON phongban
FOR EACH ROW
BEGIN
    DECLARE emp_exp INT;
    SELECT TIMESTAMPDIFF(YEAR, MIN(startdate), CURDATE())
    INTO emp_exp
    FROM lscongviec
    WHERE msnv = NEW.nv_quanly;
    IF emp_exp IS NULL OR emp_exp < 6 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nhân viên quản lý chưa có ít nhất 6 năm kinh nghiệm tại công ty!';
    END IF;
END$$
DELIMITER ;
DROP TRIGGER IF EXISTS exp_over_6years_onUPDATE;
DELIMITER $$
CREATE TRIGGER exp_over_6years_onUPDATE
BEFORE UPDATE ON phongban
FOR EACH ROW
BEGIN
    DECLARE emp_exp INT;
    SELECT TIMESTAMPDIFF(YEAR, MIN(startdate), CURDATE())
    INTO emp_exp
    FROM lscongviec
    WHERE msnv = NEW.nv_quanly;
    IF emp_exp IS NULL OR emp_exp < 6 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nhân viên quản lý chưa có ít nhất 6 năm kinh nghiệm tại công ty!';
    END IF;
END$$

DELIMITER ;
-- (22/11) Khi thêm một nhân viên mới vào 1 phòng ban thì cập nhật số lượng nhân viên trong phòng ban đó
DROP TRIGGER IF EXISTS update_soluong_nhanvien_insert_nhanvien;
DELIMITER $$
CREATE TRIGGER update_soluong_nhanvien_insert_nhanvien
AFTER INSERT
ON nhanvien
FOR EACH ROW
BEGIN
    UPDATE phongban
    SET soluongnhanvien = (SELECT COUNT(*)
                           FROM nhanvien
                           WHERE mspb = NEW.mspb)
    WHERE mspb = NEW.mspb;
END $$
DELIMITER ;
-- ---------------------------------
-- Khi thay doi ma phong ban o bang nhan _vien
DROP TRIGGER IF EXISTS update_soluong_nhanvien_update_mspb;
DELIMITER $$
CREATE TRIGGER update_soluong_nhanvien_update_mspb
AFTER UPDATE
ON nhanvien
FOR EACH ROW
BEGIN
    -- Cập nhật số lượng nhân viên của phòng ban cũ
    UPDATE phongban
    SET soluongnhanvien = (SELECT COUNT(*)
                           FROM nhanvien
                           WHERE mspb = OLD.mspb)
    WHERE mspb = OLD.mspb;

    -- Cập nhật số lượng nhân viên của phòng ban mới
    UPDATE phongban
    SET soluongnhanvien = (SELECT COUNT(*)
                           FROM nhanvien
                           WHERE mspb = NEW.mspb)
    WHERE mspb = NEW.mspb;
END $$
DELIMITER ;

-- -------------------------------------------------
DROP TRIGGER IF EXISTS update_soluong_nhanvien_khixoa;
DELIMITER $$
CREATE TRIGGER update_soluong_nhanvien_khixoa
AFTER DELETE
ON nhanvien
FOR EACH ROW
BEGIN
    UPDATE phongban
    SET soluongnhanvien = (SELECT COUNT(*)
                           FROM nhanvien
                           WHERE mspb = OLD.mspb)
    WHERE mspb = OLD.mspb;
END $$
DELIMITER ;

