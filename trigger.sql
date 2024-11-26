use db_assignment;

select * from nhan_vien;
-- viet 5 trigger cho cac rang buoc ngu nghia
-- 1 . Mỗi phòng ban phải có một quản lý có ít nhất 6 năm kinh nghiệm làm việc trong công ty.
DELIMITER $$
-- Create the trigger
CREATE TRIGGER exp_over_6years_onINSERT
AFTER insert ON phong_ban
FOR EACH ROW
BEGIN
    DECLARE emp_exp INT;
    -- Calculate the number of years the employee has worked at the company
    SELECT TIMESTAMPDIFF(YEAR, start_date, CURDATE())
    INTO emp_exp
    FROM ls_congviec
    WHERE maso_nv = NEW.maso_nv_quanly
    LIMIT 1;
    -- Check if the employee's experience is less than 6 years
    IF emp_exp < 6 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nhân viên này làm việc chưa đủ 6 năm tại công ty!';
    END IF;
END$$
-- Reset the delimiter to the default ;
DELIMITER ;
DELIMITER $$
-- Create the trigger
CREATE TRIGGER exp_over_6years_onUPDATE
AFTER update ON phong_ban
FOR EACH ROW
BEGIN
    DECLARE emp_exp INT;

    -- Calculate the number of years the employee has worked at the company
    SELECT TIMESTAMPDIFF(YEAR, start_date, CURDATE())
    INTO emp_exp
    FROM ls_congviec
    WHERE maso_nv = NEW.maso_nv_quanly
    LIMIT 1;

    -- Check if the employee's experience is less than 6 years
    IF emp_exp < 6 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nhân viên này làm việc chưa đủ 6 năm tại công ty!';
    END IF;
END$$
-- Reset the delimiter to the default ;
DELIMITER ;

-- Trigger 2: Quy định số giờ làm thêm không vượt quá 1/2 số giờ tối thiểu , so gio lam them duoc tinh toan khi so gio toi thieu < so gio hien tai
DELIMITER $$
CREATE TRIGGER cham_cong
BEFORE UPDATE ON bangchamcong
FOR EACH ROW
BEGIN
    DECLARE sogiolamthem DECIMAL(5,2);
    DECLARE sogiotoithieu DECIMAL(5,2);
    SELECT sogio_toithieu INTO sogiotoithieu
    FROM bangchamcong
    WHERE maso_nv = NEW.maso_nv
    AND thang = NEW.thang
    AND nam = NEW.nam;
    IF NEW.sogio_hientai > sogiotoithieu THEN
        SET sogiolamthem = NEW.sogio_hientai - sogiotoithieu;
        SET NEW.sogio_hientai = sogiotoithieu;
        SET NEW.sogio_lamthem = sogiolamthem;
        IF NEW.sogio_lamthem > sogiotoithieu / 2 THEN
            SET NEW.sogio_lamthem = sogiotoithieu / 2;
        END IF;
    END IF;
END $$
DELIMITER ;
select * from bangchamcong where  maso_nv = 'NV0000002' and thang = 11 and nam = 2024 ; 
update bangchamcong 
set sogio_hientai = sogio_hientai + 400 
where  maso_nv = 'NV0000002' and thang = 11 and nam = 2024 ;
select * from bangchamcong where  maso_nv = 'NV0000002' and thang = 11 and nam = 2024 ; 

-- (22/11) Khi thêm một nhân viên mới vào 1 phòng ban thì cập nhật số lượng nhân viên trong phòng ban đó
DELIMITER $$
CREATE TRIGGER update_soluong_nhanvien_khithemnhanvien
BEFORE INSERT
ON nhan_vien
FOR EACH ROW
BEGIN
	UPDATE phong_ban
	SET soluongnhanvien = soluongnhanvien + 1
	WHERE masophongban = NEW.masophongban;
END;
$$
DELIMITER ;
-- Khi thay doi ma phong ban o bang nhan _vien
DELIMITER $$
CREATE TRIGGER update_soluong_nhanvien_khichuyenphongban
BEFORE UPDATE
ON nhan_vien
FOR EACH ROW
BEGIN
    -- Khai báo biến để lưu mã phòng ban cũ
    DECLARE old_dept_id CHAR(9);
    -- Tìm mã phòng ban cũ
    SET old_dept_id = OLD.masophongban;
    -- Giảm số lượng nhân viên ở phòng ban cũ
    UPDATE phong_ban
    SET soluongnhanvien = soluongnhanvien - 1
    WHERE masophongban = old_dept_id;
    -- Tăng số lượng nhân viên ở phòng ban mới
    UPDATE phong_ban
    SET soluongnhanvien = soluongnhanvien + 1
    WHERE masophongban = NEW.masophongban;
END $$
DELIMITER ;
DELIMITER $$

CREATE TRIGGER update_soluong_nhanvien_khixoa
BEFORE DELETE
ON nhan_vien
FOR EACH ROW
BEGIN
    -- Khai báo biến để lưu mã phòng ban của nhân viên bị xóa
    DECLARE old_dept_id CHAR(9);
    
    -- Tìm mã phòng ban của nhân viên bị xóa
    SET old_dept_id = OLD.masophongban;

    -- Giảm số lượng nhân viên trong phòng ban cũ
    UPDATE phong_ban
    SET soluongnhanvien = soluongnhanvien - 1
    WHERE masophongban = old_dept_id;
END $$
DELIMITER ;

select * from phong_ban	phong_ban


