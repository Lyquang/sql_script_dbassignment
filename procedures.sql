

DELIMITER $$
create PROCEDURE them_nhan_vien_chinh_thuc(
    IN p_maso_nv CHAR(9),
    IN p_hoten VARCHAR(20),
    IN p_ngaysinh DATE,
    IN p_gioitinh VARCHAR(4),
    IN p_cccd CHAR(12),
    IN p_loainhanvien VARCHAR(10),
    IN p_masophongban CHAR(9),
    IN p_bhxh VARCHAR(20),
    IN p_maso_nguoiquanly CHAR(9),
    IN p_sdt CHAR(10),
    IN p_sonha VARCHAR(30),
    IN p_tenduong VARCHAR(30),
    IN p_phuong VARCHAR(30),
    IN p_tinh_thanhpho VARCHAR(3),
    IN p_email VARCHAR(40),
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_vitri VARCHAR(30),
    IN p_luongcoban DECIMAL(10,2),
    IN p_thang INT,
    IN p_nam YEAR,
    IN p_sogio_hientai DECIMAL(5,2) ,
    IN p_sogio_toithieu DECIMAL(5,2) , -- Default minimum hours in a month (e.g., 160 hours)
    IN p_sogio_lamthem DECIMAL(5,2) , -- Default overtime
    IN p_stk VARCHAR(30),
    IN p_ten_ngan_hang VARCHAR(20)
)
BEGIN
    -- 1. Insert into nhan_vien table
    INSERT INTO nhan_vien (maso_nv, hoten, ngaysinh, gioitinh, cccd, loainhanvien, masophongban)
    VALUES (p_maso_nv, p_hoten, p_ngaysinh, p_gioitinh, p_cccd, p_loainhanvien, p_masophongban);
    -- 2. Insert into nv_chinhthuc table (permanent employee details)
    INSERT INTO nv_chinhthuc (maso_nv, bhxh, maso_nguoiquanly)
    VALUES (p_maso_nv, p_bhxh, p_maso_nguoiquanly);

    -- 3. Insert into nvSDT table (phone number)
    INSERT INTO nvSDT (maso_nv, sdt)
    VALUES (p_maso_nv, p_sdt);

	-- 4. Insert into nvDIACHI table (address)
    INSERT INTO nvDIACHI (maso_nv, sonha, tenduong, phuong, tinh_thanhpho)
    VALUES (p_maso_nv, p_sonha, p_tenduong, p_phuong, p_tinh_thanhpho);

    -- 5. Insert into nvEMAIL table (email address)
    INSERT INTO nvEMAIL (maso_nv, email)
    VALUES (p_maso_nv, p_email);

    -- 6. Insert into hopdong table (contract)
    INSERT INTO hopdong (maso, start_date, end_date, vitri, maso_nv)
    VALUES (p_maso_nv, p_start_date, p_end_date, p_vitri, p_maso_nv);

    -- 7. Insert into ls_congviec table (job information)
    INSERT INTO ls_congviec (maso_nv, stt, start_date, chucvu, loai_nv, luong_coban, maso_phongban)
    VALUES (p_maso_nv, 1, p_start_date, p_vitri, 'chinh thuc', p_luongcoban, p_masophongban);

    -- 8. Insert into bangluong table (salary information)
    INSERT INTO bangluong (maso_nv, thang, nam, luongcoban, luonglamthem, xangxe, antrua, hotrokhac, bhxh, bhyt, thue, khautru, luongthucte)
    VALUES (p_maso_nv, p_thang, p_nam, p_luongcoban, 0, 0, 0, 0, 0, 0, 0, 0, p_luongcoban); -- Example salary structure

    -- 9. Insert into bangchamcong table (attendance information)
    INSERT INTO bangchamcong (maso_nv, thang, nam, sogio_hientai, sogio_toithieu, sogio_lamthem)
    VALUES (p_maso_nv, p_thang, p_nam, p_sogio_hientai, p_sogio_toithieu, p_sogio_lamthem);

    -- 10. Insert into taikhoan table (bank account information)
    INSERT INTO taikhoan (stk, ten_ngan_hang, maso_nv)
    VALUES (p_stk, p_ten_ngan_hang, p_maso_nv);
END $$
DELIMITER ;



