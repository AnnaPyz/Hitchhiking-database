create database hitchhiking2;
use hitchhiking2;
#drop database hitchhiking2;
show tables;

create table hikers(
id_h int(15) primary key auto_increment,
name_h  varchar(20) not null,
surname_h  varchar(20) not null,
sex_h  enum('man', 'woman') not null,
town_h  varchar(20),
birth_date_h date,
mail_h  varchar(30) not null
);

create table drivers(
id_d int(15) primary key auto_increment,
name_d  varchar(20) not null,
surname_d  varchar(20) not null,
sex_d  enum('man', 'woman') not null,
town_d  varchar(20),
birth_date_d date,
mail_d  varchar(30) not null,
car_brand_d  varchar(20) not null
);

create table trips(
id_t int(15) primary key auto_increment,
town_start  varchar(20) not null,
town_finish  varchar(20) not null,
date_start date not null,
date_finish date not null,
free_place enum('0','1') not null,
points_in_km int not null,
check (date_finish >= date_start)
);


create table trips_drivers_hikers(
id_t int(15) not null,
id_d int(15) not null,
id_h int(15),
foreign key (id_t) references trips(id_t),
foreign key (id_d) references drivers(id_d),
foreign key (id_h) references hikers(id_h)
);

create table hikers_logins(
id_h int(15) primary key, 
login_h  varchar(20) not null,
password_h  varchar(20) not null,
date_created date not null,
access_type_h varchar(15) default 'hiker',
foreign key (id_h) references hikers(id_h)
);

create table drivers_logins(
id_d int(15) primary key, 
login_d  varchar(20) not null,
password_d  varchar(20) not null,
date_created date not null,
access_type_d varchar(15) default 'driver',
foreign key (id_d) references drivers(id_d)
);

create table admins_logins(
id_a int(15) primary key auto_increment,
login_a  varchar(20) not null,
password_a  varchar(20) not null,
date_created date not null,
access_type_a varchar(15) default 'admin'
);

create or replace view ranking_hikers as
select h.id_h, h.name_h, h.surname_h, h.sex_h, sum(t.points_in_km) as total_points_h from hikers h left join trips_drivers_hikers t_d_h on (h.id_h = t_d_h.id_h) left join trips t on (t_d_h.id_t = t.id_t) group by h.id_h order by t.points_in_km desc;

create or replace view ranking_drivers as
select d.id_d, d.name_d, d.surname_d, d.sex_d, sum(t.points_in_km) as total_points_d from drivers d left join trips_drivers_hikers t_d_h on (d.id_d = t_d_h.id_d) left join trips t on (t_d_h.id_t = t.id_t) group by d.id_d order by t.points_in_km desc;

/*
# WZÓR TRIGGERA Z INTERNETU:
CREATE TRIGGER testref BEFORE INSERT ON test1
  FOR EACH ROW
  BEGIN
    INSERT INTO test2 SET a2 = NEW.a1;
    DELETE FROM test3 WHERE a3 = NEW.a1;
    UPDATE test4 SET b4 = b4 + 1 WHERE a4 = NEW.a1;
  END;
*/

-- TRIGGERS --
# marking car as already reserved by hiker
create trigger no_free_place
after update on trips_drivers_hikers
for each row 
update trips set free_place ='0' where trips_drivers_hikers.id_t=trips.id_t and trips_drivers_hikers.id_h is not null; 

# changing status of free_place in trips table to 1 when the hiker's application is cancelled
create trigger free_place
after update on trips_drivers_hikers
for each row
update trips t set t.free_place ='1' where id_t=new.id_t;

# inserting trip to table trips_drivers_hikers after adding new trip to table trips by driver
# drop trigger new_trip_in_table_trips_drivers_hikers;
create trigger new_trip_in_table_trips_drivers_hikers
after insert on trips
for each row
insert into trips_drivers_hikers set id_t=NEW.id_t, id_d=1;# DOCELOWO W PYTHONIE POBIERAM ID KIEROWCY KTÓRY TWORZY TRIP: id_d='DRIVER'S LOGIN';

# drop trigger new_hiker;
# registering new hiker
create trigger new_hiker
after insert on hikers
for each row
insert into hikers_logins set id_h = new.id_h, login_h='trigger', password_h='trigger', date_created=curdate(); #jak wprowadzić tu resztę danych z formularza?

# drop trigger new_driver;
# registering new driver
create trigger new_driver
after insert on drivers
for each row
insert into drivers_logins set id_d = new.id_d, login_d='trigger', password_d='trigger', date_created=curdate(); #jak wprowadzić tu resztę danych z formularza?

-- HIKER --
# registering
insert into hikers (name_h, surname_h, sex_h, town_h, birth_date_h, mail_h) values ('name', 'surname', 'woman', 'town', '1987-07-21', 'name@gmail.com' );

# searching for any free car
SELECT trips.*, drivers.*  FROM trips left join trips_drivers_hikers on (trips.id_t=trips_drivers_hikers.id_t) left join drivers on (trips_drivers_hikers.id_d=drivers.id_d) where trips.id_t = (SELECT trips.id_t where trips.free_place = '1');
# searching for a car with specific requirements
SELECT trips.*, drivers.*  FROM trips left join trips_drivers_hikers on (trips.id_t=trips_drivers_hikers.id_t) left join drivers on (trips_drivers_hikers.id_d=drivers.id_d) where trips.id_t = (SELECT trips.id_t where trips.free_place = '1' and trips.town_start = 'Warsaw' and trips.town_finish = 'Cracov' and trips.date_start = '2017-12-01') ;

# selecting trip
#update trips_drivers_hikers set id_h=4 where id_t=5;

# deleting account
delete from hikers_logins where id_h = 000;

-- DRIVER --
# registering
insert into drivers (name_d, surname_d, sex_d, town_d, birth_date_d, mail_d, car_brand_d) values ('name', 'surname', 'man', 'town', '1987-07-21', 'name@gmail.com', 'BMW');

#adding a new trip
#insert into trips (town_start, town_finish, date_start, date_finish, free_place, points_in_km) values ('town', 'town', '2017-12-02', '2017-12-03', '1', 250);

#rejecting hiker's application
update trips_drivers_hikers set id_h = null where id_t=2;

#deleting account
delete from drivers_logins where id_d = 000;

-- ADMIN --
#deleting hiker
delete from hikers_logins where id_h = 000;
#deleting driver
delete from drivers_logins where id_d = 000;
#reseting password for hiker
update hikers_logins set password_h = 'password2' where id_h = 000;
#reseting password for driver
update drivers_logins set password_d = 'password2' where id_d = 000;

-- INSERTS FOR TESTS --
insert into hikers (name_h, surname_h, sex_h, town_h, birth_date_h, mail_h) values ('name', 'surname', 'man', 'town', '1980-07-21', 'name@gmail.com');

insert into drivers (name_d, surname_d, sex_d, town_d, birth_date_d, mail_d, car_brand_d) values ('name', 'surname', 'man', 'town', '1983-07-21', 'name@gmail.com', 'BMW');

#insert into trips (town_start, town_finish, date_start, date_finish, free_place, points_in_km) values ('town', 'town', '2017-12-05', '2017-12-05', '1', 250);
