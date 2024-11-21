


create database db_assignment;
use db_assignment;
create table nhan_vien(
	maso_nv char(9) primary key check (maso_nv like '_________'),
    hoten varchar(20) not null,
    ngaysinh date,
    gioitinh varchar(4) check (gioitinh ='nam' or gioitinh ='nu' or gioitinh ='khac'),
    cccd char(12) unique check (cccd like '____________' and cccd regexp'[0-9]+$'),
    loainhanvien varchar(10) check (loainhanvien ='chinh thuc' or loainhanvien ='thu viec'),
    masophongban char(9) 
);

create table phong_ban(
	masophongban char (9) primary key check (masophongban like '_________'),
    mota varchar(100) not null,
    tenphongban varchar(30) not null,
    ngaythanhlap date not null,
    maso_nv_quanly char (9) not null
);
CREATE TABLE nvSDT (
    maso_nv CHAR(9) NOT NULL,
    sdt CHAR(10) NOT NULL CHECK (sdt LIKE '__________' AND sdt REGEXP '^[0-9]{10}$'),
    PRIMARY KEY (maso_nv, sdt),
    CONSTRAINT fk_sdt FOREIGN KEY (maso_nv) REFERENCES nhan_vien(maso_nv)
);

create table nvDIACHI (
	maso_nv char (9) not null,
    sonha varchar (30) not null,
    tenduong varchar (30) not null,
    phuong varchar(30) not null,
    tinh_thanhpho varchar (3) not null,
    primary key (maso_nv , sonha, tenduong, phuong, tinh_thanhpho),
    constraint fk_diachi foreign key (maso_nv)  references nhan_vien(maso_nv)
);
create table nvEMAIL (
	maso_nv char (9) not null,
    email varchar(40) not null check (email like '%_@_%'),
    primary key (maso_nv , email),
    constraint fk_email foreign key (maso_nv) references nhan_vien(maso_nv)
);

CREATE TABLE bangluong (
    maso_nv CHAR(9) NOT NULL,
    thang INT CHECK(thang >= 1 AND thang <= 12) NOT NULL,
    nam YEAR NOT NULL,
    luongcoban DECIMAL(10, 2) NOT NULL DEFAULT 0 CHECK (luongcoban >= 0),
    luonglamthem DECIMAL(10, 2) NOT NULL DEFAULT 0 CHECK (luonglamthem >= 0),
    xangxe DECIMAL(10, 2) NOT NULL DEFAULT 0 CHECK (xangxe >= 0),
    antrua DECIMAL(10, 2) NOT NULL DEFAULT 0 CHECK (antrua >= 0),
    hotrokhac DECIMAL(10, 2) NOT NULL DEFAULT 0 CHECK (hotrokhac >= 0),
    bhxh DECIMAL(10, 2) NOT NULL DEFAULT 0 CHECK (bhxh >= 0),
    bhyt DECIMAL(10, 2) NOT NULL DEFAULT 0 CHECK (bhyt >= 0),
    thue DECIMAL(10, 2) NOT NULL DEFAULT 0 CHECK (thue >= 0),
    khautru DECIMAL(10, 2) NOT NULL DEFAULT 0 CHECK (khautru >= 0),
    luongthucte DECIMAL(10, 2) NOT NULL DEFAULT 0 CHECK (luongthucte >= 0),
    primary	key (maso_nv, thang, nam),
    constraint fk_bangluong foreign key(maso_nv) references nhan_vien(maso_nv)
);


create table bangchamcong(
	maso_nv char(9) not null,
    thang int check (thang <=12 and thang>=1) not null,
    nam year not null,
    sogio_hientai dec(5,2) not null check (sogio_hientai >=0),
	sogio_toithieu dec(5,2) not null check (sogio_toithieu >=0),
    sogio_lamthem dec(5,2) not null check (sogio_lamthem >=0),
    primary key (maso_nv ,thang,nam),
    constraint fk_chamcong foreign key (maso_nv) references nhan_vien (maso_nv)
);

SET FOREIGN_KEY_CHECKS=1;
create table ngaylamviec (
	maso_nv char (9) not null ,
    thang  int  not null,
    nam year not null,
    ngay int not null,
    trangthai varchar (20) not null check (trangthai = 'lam' or trangthai = 'nghi tru luong' or trangthai ='nghi tru phep' ),
    giovao timestamp not null check(time(giovao) >= 70000 and time(giovao) <= 203000  ) ,
    giora timestamp not null check(time(giora) >= 70000 and time(giora) <= 203000  ) ,
    primary key (maso_nv, thang, nam , ngay) ,
    constraint fk_ngaylamviec foreign key (maso_nv , thang , nam ) references bangchamcong (maso_nv, thang, nam),
    CHECK(DATE(giovao)= DATE(giora) and time(giovao) <time(giora)),
    CHECK(DAY(giovao)=ngay AND MONTH(giovao)=thang AND YEAR(giovao)=nam)
);



CREATE TABLE nv_chinhthuc (
    maso_nv CHAR(9) PRIMARY KEY,
    bhxh VARCHAR(20) NOT NULL,
    maso_nguoiquanly CHAR(9),
    constraint fk_chinhthuc_to_nhanvien foreign key (maso_nv) references nhan_vien(maso_nv)
);
alter table nv_chinhthuc 
	add constraint fk_quanli foreign key (maso_nguoiquanly)references nv_chinhthuc(maso_nv);

create table nv_thuviec(
	maso_nv char(9) not null primary key  ,
    start_date date not null,
    end_date date not null,
    nv_giamsat char(9) not null,
    constraint fk_thuviec_to_nhanvien foreign key (maso_nv) references nhan_vien(maso_nv),
    check (end_date - start_date >=30),
    constraint fk_giamsat foreign key (nv_giamsat) references nv_chinhthuc (maso_nv)
);

create table ls_congviec (
	maso_nv char (9) not null ,
    stt int not null,
    start_date date not null,
    chucvu varchar(20) not null,
    loai_nv char(10) check (loai_nv = 'chinh thuc' or loai_nv ='thu viec'),
    luong_coban decimal(10,2) not null,
    maso_phongban char(9) not null,
    constraint fk_phongban foreign key (maso_phongban) references phong_ban (masophongban),
    constraint fk_to_nvchinhthuc foreign key (maso_nv) references nv_chinhthuc (maso_nv),
    primary key (maso_nv , stt)
);

create table ketoan (
	maso_nv char(9) primary key ,
    cc_hanhnghe varchar (30) not null,
    constraint fk_ketoan foreign key (maso_nv) references nhan_vien (maso_nv)
);

create table du_an(
	maso_DA char (9) primary key check(maso_DA like '_________'),
    tong_von_dau_tu decimal(20) not null default 0 check (tong_von_dau_tu >=0),
    start_date date not null,
    ten_DA varchar(100) not null,
    mota varchar (100) not null,
    ma_phong_ban_quanly char(9) not null,
    constraint fk_duAn foreign key (ma_phong_ban_quanly) references phong_ban(masophongban)
);


create table nv_thamgia_duan (
	maso_nv char(9) not null,
    maso_da char (9) not null,
    primary key (maso_nv, maso_da),
    constraint fk_nv_thamgia foreign key (maso_nv ) references nhan_vien(maso_nv),
    constraint fk_to_duan foreign key (maso_da) references du_an (maso_DA)
);


create table hoa_don_thanh_toan (
	maso_hoadon char(9) primary key check (maso_hoadon like '_________'),
    ngay_thanhtoan date not null,
    maso_nv char(9) not null,
    thang int check (thang >=1 and thang <=12) not null,
    nam year not null,
    constraint fk_hoadon foreign key (maso_nv , thang , nam) references  bangluong(maso_nv, thang, nam)    
);

create table thanhtoan(
	maso_hoadon char(9) primary key not null,
    maso_ketoan char (9) not null,
    maso_nv char (9) not null,
    constraint fk_to_hoadon foreign key (maso_hoadon) references hoa_don_thanh_toan(maso_hoadon),
	constraint fk_to_ketoan foreign key (maso_ketoan) references ketoan (maso_nv),
    constraint fk_to_nhanvien foreign key (maso_nv) references nhan_vien (maso_nv)
);

create table hopdong (
	maso char(9) primary key check(maso like '_________'),
    start_date date not null,
    end_date date not null,
    vitri varchar (30) not null,
    maso_nv char(9) not null,
    constraint fk_hopdong_to_nhanvien foreign key (maso_nv) references nhan_vien (maso_nv)
);
create table dieukhoan(
	maso char(9) not null,
    dieukhoan varchar(100) not null,
    primary key (maso,dieukhoan),
    constraint fk_dieukhoan_to_hopdong foreign key (maso) references hopdong (maso)
);

create table taikhoan(
	stk varchar (30) not null,
    ten_ngan_hang varchar (20) not null,
    maso_nv char (9) not null,
    primary key (stk, ten_ngan_hang),
    constraint fk_tk_to_nhanvien foreign key (maso_nv) references nhan_vien (maso_nv)
);

alter table nhan_vien
	add constraint fk_masophongban foreign key (masophongban) references phong_ban(masophongban);

alter table phong_ban
	add constraint fk_maso_nv_quanly foreign key(maso_nv_quanly) references nhan_vien(maso_nv) 
