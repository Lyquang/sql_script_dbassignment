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
-- ##########################################################

-- 1 Tìm tên , luong thuc te của nhân viên có lương thực tế cao nhất trong tháng a va nam b cua phong ban c co luong thuc te > d
drop PROCEDURE if exists tim_maxluong_withinPhongban_inMonth ;
DELIMITER //
CREATE PROCEDURE tim_maxluong_withinPhongban_inMonth ( t int , n int  , d dec(10,2) )
BEGIN
    select distinct nv.hoten, nv.msnv , bl2.luongthucte
    from (
        select max(bl.luongthucte) as maxluong , nv.mspb as mspb
        from bangluong as bl , nhanvien as nv
        where bl.thang =  t and bl.nam =  n and nv.msnv = bl.msnv
        group by nv.mspb
    ) as m , nhanvien as nv, bangluong as bl2 
    where   nv.mspb = m.mspb and bl2.luongthucte = m.maxluong and nv.msnv = bl2.msnv
    GROUP BY nv.hoten, nv.msnv, bl2.luongthucte
    HAVING bl2.luongthucte >  d 
    ORDER BY bl2.luongthucte;
END // 
DELIMITER ;
select * from bangluong;

update bangluong
set luongthucte = 100000
where msnv = 'NV0000009';

call tim_maxluong_withinPhongban_inMonth (1,2000 , 0);
