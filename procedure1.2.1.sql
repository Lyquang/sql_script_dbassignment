-- them vao bang nhan vien 
select * from nhanvien;
drop procedure if exists insert_into_nhanvien ;
DELIMITER //
CREATE PROCEDURE insert_into_nhanvien ( 
    msnv CHAR(9), 
    hoten VARCHAR(20), 
    ngaysinh DATE, 
    gioitinh VARCHAR(4), 
    cccd CHAR(12), 
    lnv VARCHAR(10), 
    mspb CHAR(9)  
)
BEGIN
    CALL check_ms(msnv);
    IF hoten IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hay nhap ten!';
    END IF;
    CALL check_dob(ngaysinh);
    CALL check_cccd(cccd);
    IF gioitinh IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hay nhap gioi tinh!';
    END IF;
    IF gioitinh NOT IN ('nam', 'nu', 'khac') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Gioi tinh khong hop le!';
    END IF;
    IF lnv IS NULL THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hay nhap loai nhan vien!';
    END IF;
    IF lnv NOT IN ('chinh thuc', 'thu viec') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loai nhan vien khong ton tai!';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM phongban WHERE mspb = mspb) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ma phong ban khong ton tai!';
    END IF;
    INSERT INTO nhanvien (msnv, hoten, ngaysinh, gioitinh, cccd, loainhanvien, mspb) 
    VALUES (msnv, hoten, ngaysinh, gioitinh, cccd, lnv, mspb);
END
//
DELIMITER ;

-- 1.2.1 Procedure them lich suw cong viec

drop procedure if exists insert_into_ls_congviec;
DELIMITER //
CREATE PROCEDURE insert_into_ls_congviec (
    msnv CHAR(9),
    start_date DATE,
    chucvu VARCHAR(30),
    loainv VARCHAR(10),
    lcb DECIMAL(10,2),
    tenpb varchar (30)
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
    IF lcb IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hãy thêm lương cơ bản!';
    END IF;
    -- Kiểm tra nếu nhân viên đã có trong bảng ls_congviec
    IF EXISTS (SELECT 1 FROM lscongviec as ls WHERE ls.msnv = msnv) THEN
        -- Lấy giá trị stt cao nhất cho nhân viên
        SELECT MAX(stt) INTO cur_stt
        FROM lscongviec as ls
		WHERE ls.msnv = msnv;
        -- Thêm công việc mới cho nhân viên, tăng stt lên 1
        INSERT INTO lscongviec (msnv, stt, startdate, chucvu, loainv, luongcoban, tenphongban)
        VALUES (msnv, cur_stt + 1, start_date, chucvu, loainv, lcb, tenpb);
    ELSE
        -- Nếu nhân viên chưa có trong bảng, thêm công việc mới với stt = 1
        INSERT INTO lscongviec (msnv, stt, startdate, chucvu, loainv, luongcoban, tenphongban)
        VALUES (msnv, 1, start_date, chucvu, loainv, lcb, tenpb);
    END IF;
END //
DELIMITER ;


-- 1.2.1 procedure Them 1 nhan vien chinh thuc 
DROP PROCEDURE IF EXISTS insert_nvchinhthuc;
DELIMITER //
CREATE PROCEDURE insert_nvchinhthuc (
    msnv CHAR(9), 
    hovaten VARCHAR(20), 
    ngaysinh DATE, 
    gioitinh VARCHAR(4), 
    cccd CHAR(12), 
    masophongban CHAR(9),
    bhxh VARCHAR(20),
    nguoiquanly CHAR(9),
    startdate DATE,
    chucvu VARCHAR(20),
    lcb DECIMAL(10,2),
    sogiotoithieu INT
)
BEGIN
    IF bhxh IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hay them BHXH!';
    END IF;
    IF nguoiquanly IS NOT NULL AND nguoiquanly NOT IN (SELECT msnv FROM nvchinhthuc) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nhan vien quan ly khong ton tai!';
    END IF;
    CALL insert_into_nhanvien(msnv, hovaten, ngaysinh, gioitinh, cccd, 'chinh thuc', masophongban);
    INSERT INTO nvchinhthuc (msnv, bhxh, nguoiquanly) 
    VALUES (msnv, bhxh, nguoiquanly);

    -- Truy vấn tên phòng ban trực tiếp khi thêm vào lịch sử công việc
    CALL insert_into_ls_congviec(
        msnv, 
        startdate, 
        chucvu, 
        'chinh thuc', 
        lcb, 
        (SELECT tenphongban FROM phongban WHERE mspb = masophongban)
    );
    INSERT INTO bangluong(msnv, thang, nam, luongcoban) 
    VALUES (msnv, MONTH(startdate), YEAR(startdate), lcb);
    INSERT INTO bangchamcong (msnv, thang, nam, sogiohientai, sogiotoithieu, sogiolamthem) 
    VALUES (msnv, MONTH(startdate), YEAR(startdate), 0, sogiotoithieu, 0);

END //
DELIMITER ;

select * from nhanvien as a ,nvchinhthuc as b, lscongviec as c , bangluong as d , bangchamcong as e
where a.msnv = b.msnv and b.msnv= c.msnv and c.msnv = d.msnv and d.msnv = e.msnv and a.msnv ='NV0000008';

CALL insert_nvchinhthuc(
    'NV0000011', 
    'Le Thi Duyen', 
    '1990-12-12', 
    'nu', 
    '120406080012', 
    'PB0000001', 
    'BHXH0007', 
    NULL, 
    '2000-01-01', 
    'Nhan vien', 
    7000.00 ,
    10000 
);
-- 1.2.1 xoa 1 nhan vien   
-- handle xoa thang la manager
DELIMITER $$
CREATE PROCEDURE delete_nhanvien(IN p_msnv CHAR(9))
BEGIN
    IF EXISTS (SELECT 1 FROM nhanvien WHERE msnv = p_msnv) THEN
        DELETE FROM nhanvien WHERE msnv = p_msnv;
        SELECT 'Nhan vien da duoc xoa thanh cong' AS message;
    ELSE
        SELECT 'Khong co nhan vien nay' AS message;
    END IF;
END $$
DELIMITER ;

call delete_nhanvien('NV0000008');
select * from nhanvien ;
select * from nvchinhthuc ;
select * from bangluong ;
select * from bangchamcong ; 
select * from phongban;


-- 1.2.1 procedure sua ten nhan vien 
DELIMITER $$
CREATE PROCEDURE sua_ten_nhanvien(
    IN p_msnv CHAR(9),       
    IN p_hoten_moi VARCHAR(30) 
)
BEGIN
    IF EXISTS (SELECT 1 FROM nhanvien WHERE msnv = p_msnv) THEN
        UPDATE nhanvien
        SET hoten = p_hoten_moi
        WHERE msnv = p_msnv;
        SELECT CONCAT('Tên của nhân viên mã ', p_msnv, ' đã được cập nhật thành ', p_hoten_moi) AS message;
    ELSE
        SELECT CONCAT('Không tìm thấy nhân viên với mã số ', p_msnv) AS message;
    END IF;
END $$
DELIMITER ;
call sua_ten_nhanvien ('NV0000007','pham van quoc viet');
select * from nhanvien;

-- 1.2.1 DU AN
-- them du an
drop procedure if exists them_duan;
DELIMITER $$
CREATE PROCEDURE them_duan (
    IN p_maDA CHAR(9),
    IN p_tong_von_dau_tu DECIMAL(20),
    IN p_start_date DATE,
    IN p_ten_DA VARCHAR(100),
    IN p_mota VARCHAR(100),
    IN p_ma_phong_ban_quanly CHAR(9)
)
BEGIN
    IF p_maDA IS NULL OR LENGTH(p_maDA) != 9 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ma so du an khong duoc null va phai co dung 9 ky tu';
    END IF;
    IF p_tong_von_dau_tu < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tong von dau tu lon hon hoac bang 0';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM phongban WHERE mspb = p_ma_phong_ban_quanly) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ma phong ban quan ly nay khong ton tai';
    END IF;
    INSERT INTO duan (maDA, tong_von_dau_tu, start_date, ten_DA, mota, ma_phong_ban_quanly)
    VALUES (p_maDA, p_tong_von_dau_tu, p_start_date, p_ten_DA, p_mota, p_ma_phong_ban_quanly);
END $$

DELIMITER ;

-- xoa du an
drop procedure if exists xoa_duan;
DELIMITER $$
CREATE PROCEDURE xoa_duan (
    IN p_maDA CHAR(9)
)
BEGIN
    IF p_maDA IS NULL OR LENGTH(p_maDA) != 9 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ma du an phai co dung 9 ky tu';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM duan WHERE maDA = p_maDA) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Du an nay khong ton tai.';
    END IF;
    DELETE FROM duan WHERE maDA = p_maDA;

END $$

DELIMITER ;
-- sua du an 
drop procedure if exists sua_ten_duan ;
DELIMITER $$
CREATE PROCEDURE sua_ten_duan (
    IN p_maDA CHAR(9),         
    IN p_ten_DA VARCHAR(100)   
)
BEGIN
    -- Kiểm tra mã dự án
    IF p_maDA IS NULL OR LENGTH(p_maDA) != 9 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ma du an phai co dung 9 ky tu va khong duoc de trong';
    END IF;

    -- Kiểm tra tên dự án mới
    IF p_ten_DA IS NULL OR LENGTH(p_ten_DA) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ten du an khong duoc de trong ';
    END IF;

    -- Kiểm tra dự án có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM duan WHERE maDA = p_maDA) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dự án với mã này không tồn tại.';
    END IF;

    -- Cập nhật tên dự án
    UPDATE duan
    SET ten_DA = p_ten_DA
    WHERE maDA = p_maDA;

END $$
DELIMITER ;

-- ------------- 


call them_duan('123456789',100 , '2020-02-03' , 'Du an pro' ,'Sky oi ' ,'PB0000001' );
call sua_ten_duan('123456789' , 'sua ten du an');
call xoa_duan ('123456789');

-- 1.2.1 crud phong ban

-- them phong ban
DROP PROCEDURE IF EXISTS THEM_PHONGBAN;
DELIMITER $$
CREATE PROCEDURE them_phongban (
    IN p_mspb CHAR(9),
    IN p_mota VARCHAR(100),
    IN p_tenphongban VARCHAR(30),
    IN p_nv_quanly CHAR(9)
)
BEGIN
    IF p_mspb IS NULL OR LENGTH(p_mspb) != 9 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ma phong ban phai co dung 9 ky tu';
    END IF;
    IF p_tenphongban IS NULL OR LENGTH(p_tenphongban) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ten phong ban khong duoc de trong';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM nhanvien WHERE msnv = p_nv_quanly) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nhan vien khong ton tai !';
    END IF;

    -- Thêm phòng ban
    INSERT INTO phongban (mspb, mota, tenphongban, ngaythanhlap, nv_quanly)
    VALUES (p_mspb, p_mota, p_tenphongban,curdate(), p_nv_quanly);
END $$
DELIMITER ;
call them_phongban('PB0000009','phong ban oi','cuong dep zai' , 'NV0000011');

-- sua phong ban
DROP PROCEDURE IF EXISTS update_tenphongban;
DELIMITER //
CREATE PROCEDURE update_tenphongban (
    in_mspb CHAR(9),         
    in_tenphongban VARCHAR(50) 
)
BEGIN
    -- Cập nhật tên phòng ban trong bảng phongban
    UPDATE phongban
    SET tenphongban = in_tenphongban
    WHERE mspb = in_mspb;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ma phong ban nay khong ton tai';
    END IF;
END //

DELIMITER ;

CALL update_tenphongban('PB0000009', 'Cuong dep zaiiiiii');
select * from phongban;

-- xoa phong ban phai co nguoi thay the
DROP PROCEDURE IF EXISTS delete_phongban;
DELIMITER //

CREATE PROCEDURE delete_phongban(
    in_mspb CHAR(9)  
)
BEGIN
    DECLARE phongban_count INT;
    SELECT COUNT(*) INTO phongban_count
    FROM phongban
    WHERE mspb = in_mspb;
    
    IF phongban_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Phong ban nay khong ton tai';
    ELSE
        DELETE FROM phongban
        WHERE mspb = in_mspb;
    END IF;
END //

DELIMITER ;

call delete_phongban ('PB0000009')






