

-- 0.  check maso nhan vien phai co dung 9 ky tu 
DELIMITER //
CREATE PROCEDURE check_ms (IN msnv VARCHAR(100))
BEGIN
	if msnv is null then 
		signal sqlstate '45000' set message_text ='Hay nhap ma so nhan vien!';
	end if ;
    IF LENGTH(msnv) != 9 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ma so nhan vien nay khong dung 9 ky tu!';
    END IF;
END //
DELIMITER ;
-- 0 . check nhan vien phai du 18 tuoi 
DELIMITER //
CREATE PROCEDURE check_dob (IN dob DATE)
BEGIN
	if dob is null then
		signal sqlstate '45000' set message_text = 'Hay nhap ngay sinh !';
	end if;
    IF TIMESTAMPDIFF(YEAR, dob, CURDATE()) < 18 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Nhan vien chua du 18 tuoi!';
    END IF;
END //
DELIMITER ;
-- check cccd phai co 12 ky tu va phai toan la so
DELIMITER //
CREATE PROCEDURE check_cccd (in cccd varchar(100))
BEGIN
	if cccd is null then 
		signal sqlstate '45000' set message_text = 'Hay nhap cccd !';
	end if;
    IF length(cccd) != 12 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'CCCD chua dung 12 ky tu';
    END IF;
    IF cccd NOT REGEXP '^[0-9]{12}$' THEN
		SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'CCCD phai la cac ky tu so!';
	end if ;
END //
DELIMITER ;

-- -------------------------------------------------------------------------------------
-- 1. Thêm mới một nhân viên vào bảng nhan_vien 
DELIMITER //
CREATE PROCEDURE insert_into_nhanvien ( 
    msnv CHAR(9), 
    hovaten VARCHAR(20), 
    ngaysinh DATE, 
    gioitinh VARCHAR(4), 
    cccd CHAR(12), 
    loai_nhan_vien VARCHAR(10), 
    masophongban CHAR(9)  
)
BEGIN
    CALL check_ms(msnv);
    IF hovaten IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hay nhap ten!';
    END IF;
    CALL check_dob(ngaysinh);
    CALL check_cccd(cccd);
    IF gioitinh IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hay nhap gioi tinh !';
    END IF;
    IF gioitinh NOT IN ('nam', 'nu', 'khac') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Gioi tinh khong hop le!';
    END IF;
    IF loai_nhan_vien IS NULL THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hay nhap loai nhan vien!';
    END IF;
    IF loai_nhan_vien NOT IN ('chinh thuc', 'thu viec') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loai nhan vien khong ton tai!';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM phong_ban WHERE masophongban = phong_ban.masophongban) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ma phong ban khong ton tai!';
    END IF;
    insert nhan_vien (maso_nv,hoten,ngaysinh,gioitinh,cccd , loainhanvien , masophongban) values (msnv,hovaten,ngaysinh,gioitinh,cccd,loai_nhan_vien,masophongban);
END //
DELIMITER ;
-- 2. them nhan vien chinh thuc  
DELIMITER //
CREATE PROCEDURE insert_into_nhanvien_chinhthuc (
	msnv CHAR(9), 
    hovaten VARCHAR(20), 
    ngaysinh DATE, 
    gioitinh VARCHAR(4), 
    cccd CHAR(12), 
    loai_nhan_vien VARCHAR(10), 
    masophongban CHAR(9)  ,
    bhxh varchar(20),
    nguoiquanly char(9)
)
begin 
	if bhxh is null then
		signal sqlstate '45000' set message_text = 'Hay them BHXH !';
	end if ;
    if nguoiquanly not in (select maso_nv from nv_chinhthuc) then
		signal sqlstate '45000' set message_text = 'Nhan vien quan ly khong ton tai !';
	end if;
	call insert_into_nhanvien(msnv,hovaten,ngaysinh,gioitinh,cccd,loai_nhan_vien,masophongban) ;
    insert nv_chinhthuc (maso_nv , bhxh , maso_nguoiquanly) values (msnv , bhxh , maso_nguoiquanly);
end //
DELIMITER ;




