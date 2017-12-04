create database hitchhiking;
use hitchhiking;
#drop database hitchhiking;
show tables;

CREATE TABLE hikers (
    id_h INT(15) PRIMARY KEY AUTO_INCREMENT,
    name_h VARCHAR(20) NOT NULL,
    surname_h VARCHAR(20) NOT NULL,
    sex_h ENUM('man', 'woman') NOT NULL,
    town_h VARCHAR(20),
    birth_date_h DATE,
    mail_h VARCHAR(30) NOT NULL
);

CREATE TABLE drivers (
    id_d INT(15) PRIMARY KEY AUTO_INCREMENT,
    name_d VARCHAR(20) NOT NULL,
    surname_d VARCHAR(20) NOT NULL,
    sex_d ENUM('man', 'woman') NOT NULL,
    town_d VARCHAR(20),
    birth_date_d DATE,
    mail_d VARCHAR(30) NOT NULL,
    car_brand_d VARCHAR(20) NOT NULL
);

CREATE TABLE trips (
    id_t INT(15) PRIMARY KEY AUTO_INCREMENT,
    town_start VARCHAR(20) NOT NULL,
    town_finish VARCHAR(20) NOT NULL,
    date_start DATE NOT NULL,
    date_finish DATE NOT NULL,
    free_place ENUM('0', '1') NOT NULL,
    points_in_km INT NOT NULL,
    CHECK (date_finish >= date_start)
);

CREATE TABLE trips_drivers_hikers (
    id_t INT(15) NOT NULL,
    id_d INT(15) NOT NULL,
    id_h INT(15),
    FOREIGN KEY (id_t)
        REFERENCES trips (id_t),
    FOREIGN KEY (id_d)
        REFERENCES drivers (id_d),
    FOREIGN KEY (id_h)
        REFERENCES hikers (id_h)
);

CREATE TABLE hikers_logins (
    id_h INT(15) PRIMARY KEY,
    login_h VARCHAR(20) NOT NULL,
    password_h VARCHAR(20) NOT NULL,
    date_created DATE NOT NULL,
    access_type_h VARCHAR(15) DEFAULT 'hiker',
    FOREIGN KEY (id_h)
        REFERENCES hikers (id_h)
);

CREATE TABLE drivers_logins (
    id_d INT(15) PRIMARY KEY,
    login_d VARCHAR(20) NOT NULL,
    password_d VARCHAR(20) NOT NULL,
    date_created DATE NOT NULL,
    access_type_d VARCHAR(15) DEFAULT 'driver',
    FOREIGN KEY (id_d)
        REFERENCES drivers (id_d)
);

CREATE TABLE admins_logins (
    id_a INT(15) PRIMARY KEY AUTO_INCREMENT,
    login_a VARCHAR(20) NOT NULL,
    password_a VARCHAR(20) NOT NULL,
    date_created DATE NOT NULL,
    access_type_a VARCHAR(15) DEFAULT 'admin'
);

CREATE OR REPLACE VIEW ranking_hikers AS
    SELECT 
        h.id_h,
        h.name_h,
        h.surname_h,
        h.sex_h,
        SUM(t.points_in_km) AS total_points_h
    FROM
        hikers h
            LEFT JOIN
        trips_drivers_hikers t_d_h ON (h.id_h = t_d_h.id_h)
            LEFT JOIN
        trips t ON (t_d_h.id_t = t.id_t)
    GROUP BY h.id_h
    ORDER BY t.points_in_km DESC;

CREATE OR REPLACE VIEW ranking_drivers AS
    SELECT 
        d.id_d,
        d.name_d,
        d.surname_d,
        d.sex_d,
        SUM(t.points_in_km) AS total_points_d
    FROM
        drivers d
            LEFT JOIN
        trips_drivers_hikers t_d_h ON (d.id_d = t_d_h.id_d)
            LEFT JOIN
        trips t ON (t_d_h.id_t = t.id_t)
    GROUP BY d.id_d
    ORDER BY t.points_in_km DESC;

###drop trigger free_place;
###drop trigger no_free_place;

-- TRIGGERS --
# marking car as already reserved by hiker
create trigger no_free_place
after update on trips_drivers_hikers
for each row 
update trips set free_place ='0' where new.id_t=trips.id_t and new.id_h is not null; 

 select * from trips_drivers_hikers;
# changing status of free_place in trips table to 1 when the hiker's application is cancelled
create trigger free_place
after update on trips_drivers_hikers
for each row
update trips set free_place ='1' where new.id_t=id_t and new.id_h is null;

# inserting trip to table trips_drivers_hikers after adding new trip to table trips by driver
create trigger new_trip_in_table_trips_drivers_hikers
after insert on trips
for each row
insert into trips_drivers_hikers set id_t=NEW.id_t, id_d=1;# DOCELOWO W PYTHONIE POBIERAM ID KIEROWCY KTÓRY TWORZY TRIP: id_d='DRIVER'S LOGIN';

# removing trip from table trips after removing it from trips_drivers_hikers
create trigger remove_trip_from_table_trips
after delete on trips_drivers_hikers
for each row
delete from trips where id_t=old.id_t;

# registering new hiker
create trigger new_hiker
after insert on hikers
for each row
insert into hikers_logins set id_h = new.id_h, login_h='trigger', password_h='trigger', date_created=curdate(); 

# registering new driver
create trigger new_driver
after insert on drivers
for each row
insert into drivers_logins set id_d = new.id_d, login_d='trigger', password_d='trigger', date_created=curdate(); 

-- DRIVER --
# registering
insert into drivers (name_d, surname_d, sex_d, town_d, birth_date_d, mail_d, car_brand_d) values ('name', 'surname', 'man', 'town', '1987-07-21', 'name@gmail.com', 'BMW');
insert into drivers (name_d, surname_d, sex_d, town_d, birth_date_d, mail_d, car_brand_d) values ('name', 'surname', 'woman', 'town', '1987-07-21', 'name@gmail.com', 'BMW');
insert into drivers (name_d, surname_d, sex_d, town_d, birth_date_d, mail_d, car_brand_d) values ('name', 'surname', 'man', 'town', '1987-07-21', 'name@gmail.com', 'BMW');

# adding a new trip
insert into trips (town_start, town_finish, date_start, date_finish, free_place, points_in_km) values ('town', 'town', '2017-12-02', '2017-12-03', '1', 250);
insert into trips (town_start, town_finish, date_start, date_finish, free_place, points_in_km) values ('town', 'town', '2017-12-02', '2017-12-03', '1', 250);
insert into trips (town_start, town_finish, date_start, date_finish, free_place, points_in_km) values ('town', 'town', '2017-12-02', '2017-12-03', '1', 250);
insert into trips (town_start, town_finish, date_start, date_finish, free_place, points_in_km) values ('town', 'town', '2017-12-02', '2017-12-03', '1', 250);
insert into trips (town_start, town_finish, date_start, date_finish, free_place, points_in_km) values ('town', 'town', '2017-12-02', '2017-12-03', '1', 250);

# rejecting hiker's application
UPDATE trips_drivers_hikers 
SET 
    id_h = NULL
WHERE
    id_t = 000;

# cancelling trip
delete from trips_drivers_hikers where id_t = 3;

# deleting account
DELETE FROM drivers_logins 
WHERE
    id_d = 3;

-- HIKER --
# registering
insert into hikers (name_h, surname_h, sex_h, town_h, birth_date_h, mail_h) values ('name', 'surname', 'woman', 'town', '1987-07-21', 'name@gmail.com' );
insert into hikers (name_h, surname_h, sex_h, town_h, birth_date_h, mail_h) values ('name', 'surname', 'woman', 'town', '1987-07-21', 'name@gmail.com' );
insert into hikers (name_h, surname_h, sex_h, town_h, birth_date_h, mail_h) values ('name', 'surname', 'woman', 'town', '1987-07-21', 'name@gmail.com' );
insert into hikers (name_h, surname_h, sex_h, town_h, birth_date_h, mail_h) values ('name', 'surname', 'woman', 'town', '1987-07-21', 'name@gmail.com' );

# searching for any free car
SELECT trips.*, drivers.*  FROM trips left join trips_drivers_hikers on (trips.id_t=trips_drivers_hikers.id_t) left join drivers on (trips_drivers_hikers.id_d=drivers.id_d) where trips.id_t = (SELECT trips.id_t where trips.free_place = '1');
# searching for a car with specific requirements
SELECT trips.*, drivers.*  FROM trips left join trips_drivers_hikers on (trips.id_t=trips_drivers_hikers.id_t) left join drivers on (trips_drivers_hikers.id_d=drivers.id_d) where trips.id_t = (SELECT trips.id_t where trips.free_place = '1' and trips.town_start = 'Warsaw' and trips.town_finish = 'Cracov' and trips.date_start = '2017-12-01') ;

# booking place on trip
update trips_drivers_hikers set id_h=2 where id_t=1;

# cancelling the booking
update trips_drivers_hikers set id_h=null where id_t=000;

# deleting account
DELETE FROM hikers_logins WHERE id_h = 000;

-- ADMIN --
# deleting hiker
DELETE FROM hikers_logins WHERE id_h = 000;

# deleting driver
DELETE FROM drivers_logins WHERE id_d = 000;

# reseting password for hiker
update hikers_logins set password_h = 'password2' WHERE id_h = 000;

# reseting password for driver
update drivers_logins set password_d = 'password2' WHERE id_d = 000;

-- INSERTS FOR TESTS --
#insert into hikers (name_h, surname_h, sex_h, town_h, birth_date_h, mail_h) values ('name', 'surname', 'man', 'town', '1987-07-21', 'name@gmail.com');

#insert into drivers (name_d, surname_d, sex_d, town_d, birth_date_d, mail_d, car_brand_d) values ('name', 'surname', 'man', 'town', '1983-07-05', 'name@gmail.com', 'Opel');

#insert into trips (town_start, town_finish, date_start, date_finish, free_place, points_in_km) values ('town', 'town', '2017-12-05', '2017-12-05', '1', 250);
