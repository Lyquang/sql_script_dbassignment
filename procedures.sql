

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
-- 0 . check nhan vien phai du 18 tuoi va khac null
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
-- ##################################################################################
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
-- ##################################################################################
-- 2. them nhan vien chinh thuc  
DELIMITER //
CREATE PROCEDURE insert_into_nhanvien_chinhthuc (
	msnv CHAR(9), 
    hovaten VARCHAR(20), 
    ngaysinh DATE, 
    gioitinh VARCHAR(4), 
    cccd CHAR(12), 
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
	call insert_into_nhanvien(msnv,hovaten,ngaysinh,gioitinh,cccd,'chinh thuc',masophongban) ;
    insert nv_chinhthuc (maso_nv , bhxh , maso_nguoiquanly) values (msnv , bhxh , maso_nguoiquanly);
end //
DELIMITER ;
-- ##################################################################################
 -- 3. them nhan vien thu viec  
DELIMITER //
CREATE PROCEDURE insert_into_nhanvien_thuviec (
    msnv CHAR(9), 
    hovaten VARCHAR(20), 
    ngaysinh DATE, 
    gioitinh VARCHAR(4), 
    cccd CHAR(12), 
    loai_nhan_vien VARCHAR(10), 
    masophongban CHAR(9),
    start_date DATE,
    end_date DATE,
    nguoiquanly CHAR(9)
)
BEGIN 
    -- Check if start_date and end_date are provided
    IF start_date IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hay nhap ngay bat dau thu viec !';
    END IF;
    IF end_date IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hay nhap ngay ket thuc thu viec!';
    END IF;
    -- Check if nguoiquanly (manager) is provided
    IF nguoiquanly IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nhan vien thu viec phai co nhan vien chinh thuc quan ly !';
    END IF;
    -- Ensure probation period is at least 1 month (30 days)
    IF DATEDIFF(end_date, start_date) < 30 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Thoi gian thu viec phai it nhat 1 thang!';
    END IF;
    -- Insert the new employee into the main table (insert_into_nhanvien)
    CALL insert_into_nhanvien(msnv, hovaten, ngaysinh, gioitinh, cccd, loai_nhan_vien, masophongban);
    -- Insert the probation details into the nv_thuviec table
    INSERT INTO nv_thuviec (maso_nv, start_date, end_date, nv_giamsat)
    VALUES (msnv, start_date, end_date, nguoiquanly);
END //
DELIMITER ;
-- ##################################################################################
-- 4. them ls cong viec
DELIMITER //

CREATE PROCEDURE insert_into_ls_congviec (
    msnv CHAR(9),
    start_date DATE,
    chucvu VARCHAR(30),
    loainv VARCHAR(10),
    lcb DECIMAL(10,2),
    mspb CHAR(9)
)
BEGIN
    -- Khai báo biến
    DECLARE cur_stt INT;
    -- Kiểm tra các tham số đầu vào
    CALL check_ms(msnv);
    IF start_date IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hãy thêm ngày bắt đầu!';
    END IF;
    IF chucvu IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hãy thêm chức vụ!';
    END IF;
    IF loainv IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hãy thêm loại nhân viên!';
    END IF;
    IF loainv NOT IN ('chinh thuc', 'thu viec') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loại nhân viên không tồn tại!';
    END IF;
    IF lcb IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hãy thêm lương cơ bản!';
    END IF;
    IF mspb IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hãy thêm mã phòng ban!';
    END IF;
    -- Kiểm tra xem mã phòng ban có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM phong_ban WHERE masophongban = mspb) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mã phòng ban không tồn tại!';
    END IF;
    -- Kiểm tra nếu nhân viên đã có trong bảng ls_congviec
    IF EXISTS (SELECT 1 FROM ls_congviec WHERE maso_nv = msnv) THEN
        -- Lấy giá trị stt cao nhất cho nhân viên
        SELECT MAX(stt) INTO cur_stt
        FROM ls_congviec
        WHERE maso_nv = msnv;
        -- Thêm công việc mới cho nhân viên, tăng stt lên 1
        INSERT INTO ls_congviec (maso_nv, stt, start_date, chucvu, loai_nv, luong_coban, maso_phongban)
        VALUES (msnv, cur_stt + 1, start_date, chucvu, loainv, lcb, mspb);
    ELSE
        -- Nếu nhân viên chưa có trong bảng, thêm công việc mới với stt = 1
        INSERT INTO ls_congviec (maso_nv, stt, start_date, chucvu, loai_nv, luong_coban, maso_phongban)
        VALUES (msnv, 1, start_date, chucvu, loainv, lcb, mspb);
    END IF;
END //
DELIMITER ;

-- CALL insert_into_ls_congviec('NV0000001', '2023-11-01', 'Trưởng phòng', 'chinh thuc', 25000000.00, 'PB0000001');


-- ##########################################################

-- 1 Tìm tên , luong thuc te của nhân viên có lương thực tế cao nhất trong tháng a va nam b cua phong ban c co luong thuc te > d
drop PROCEDURE if exists tim_maxluong_withinPhongban_inMonth ;
DELIMITER //
CREATE PROCEDURE tim_maxluong_withinPhongban_inMonth ( t int , n int  , d dec(10,2) )
BEGIN
	select distinct nv.hoten,nv.maso_nv , bl2.luongthucte
    from (	select max(bl.luongthucte) as maxluong , nv.masophongban as mspb
			from bangluong as bl , nhan_vien as nv
			where bl.thang =  t and bl.nam =  n and nv.maso_nv = bl.maso_nv
			group by nv.masophongban
            ) as m , nhan_vien as nv, bangluong as bl2 
	where   nv.masophongban = m.mspb and bl2.luongthucte = m.maxluong and nv.maso_nv = bl2.maso_nv
	GROUP BY nv.hoten, nv.maso_nv, bl2.luongthucte
	HAVING bl2.luongthucte >  d 
	ORDER BY bl2.luongthucte;
END // 
DELIMITER ;
call tim_maxluong_withinPhongban_inMonth (3,22222 , 10);
