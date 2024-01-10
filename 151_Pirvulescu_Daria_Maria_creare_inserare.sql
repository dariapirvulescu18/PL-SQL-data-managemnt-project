CREATE SEQUENCE SEQ_CUSCA
INCREMENT by 1
START WITH 1
MAXVALUE 9
NOCYCLE;

CREATE SEQUENCE SEQ_SOL
INCREMENT by 1
START WITH 10
MAXVALUE 19
NOCYCLE;

CREATE SEQUENCE SEQ_ANGAJAT
INCREMENT by 1
START WITH 200
MAXVALUE 321
NOCYCLE;
drop sequence seq_angajat;
CREATE SEQUENCE SEQ_SPECIALIZARE
INCREMENT by 1
START WITH 230
MAXVALUE 240
NOCYCLE;

CREATE SEQUENCE SEQ_CAMION_DE_MARFA 
INCREMENT by 1
START WITH 40
MAXVALUE 149
NOCYCLE;
drop sequence SEQ_CAMION_DE_MARFA ;

CREATE SEQUENCE SEQ_ISTORIC
INCREMENT by 1
START WITH 500
MAXVALUE 520
NOCYCLE;

CREATE SEQUENCE SEQ_ACTIVITATE
INCREMENT by 1
START WITH 60
MAXVALUE 169
NOCYCLE;

drop sequence SEQ_ACTIVITATE;
CREATE SEQUENCE SEQ_UTILIZATOR
INCREMENT by 1
START WITH 70
MAXVALUE 179
NOCYCLE;
drop sequence SEQ_UTILIZATOR;
CREATE SEQUENCE SEQ_ANIMAL
INCREMENT by 1
START WITH 80
MAXVALUE 89
NOCYCLE;

CREATE SEQUENCE SEQ_TEREN
INCREMENT by 1
START WITH 90
MAXVALUE 99
NOCYCLE;

CREATE SEQUENCE SEQ_PLANTA
INCREMENT by 1
START WITH 100
MAXVALUE 109
NOCYCLE;

CREATE SEQUENCE SEQ_COMANDA
INCREMENT by 1
START WITH 110
MAXVALUE 319
NOCYCLE;

drop sequence SEQ_COMANDA;
 CREATE TABLE CUSCA(
        id_cusca number(5) constraint pkid_cusca primary key,
        lungime number(5),
        latime number(5),
        capacitate number(5)
    );

CREATE TABLE SOL (
    id_sol number(5)constraint pkid_sol primary key,
    densitate number(5,2),
    grad_de_fertilitate CHAR(8) CHECK (grad_de_fertilitate IN ('crescuta', 'scazuta'))
);
CREATE TABLE ANGAJAT (
    id_angajat number(5) constraint pkid_angajat primary key,
    nume VARCHAR(25),
    prenume VARCHAR(25),
    salariu number(15)constraint salary not NULL,
    data_nastere DATE,
    sex CHAR(4) CHECK (sex IN ('f', 'm')),
    nationalitate VARCHAR(12)
);

CREATE TABLE SPECIALIZARE (
    id_specializare number(5) constraint pkid_specializare primary key,
    data_infiintarii date,
    nume_s varchar(50)
);

CREATE TABLE CAMION_DE_MARFA (
    id_camion number(5) constraint pkid_camion primary key,
    capacitate number(10),
    id_sofer number(5) constraint fk_camion_angajat1 references SOFER(id_sofer)
);
drop table camion_de_marfa;
CREATE TABLE ISTORIC (
    id_istoric number(5) constraint pkid_istoric primary key,
    data_angajarii DATE,
    data_promovarii DATE,
    productivitate varchar(8)  CHECK (productivitate IN ('crescuta', 'scazuta')),
    id_angajat number(5) constraint fk_istoric_angajat references ANGAJAT(id_angajat)
);

CREATE TABLE ACTIVITATE (
    id_activitate number(5) constraint pkid_activitate primary key,
    data_desfasurare DATE,
    ora VARCHAR(5),
    stare_curenta varchar(25) CHECK (stare_curenta IN ('in desfasurare','finalizata','anulata'))
);
drop table activitate;
drop table organizeaza;
CREATE TABLE UTILIZATOR (
    id_user number(5)  constraint pkid_user primary key,
    nume VARCHAR(25),
    prenume VARCHAR(25),
    rating_vanzator VARCHAR(25) CHECK (rating_vanzator IN ('bronz','argint','aur'))
);
drop table utilizator;

CREATE TABLE ANIMAL (
    id_animal number(5) constraint pkid_animal primary key,
    id_cusca number(5),
    rasa VARCHAR(25),
    nr_animale number(10),
    constraint fk_cod_cusca foreign key (id_cusca) references CUSCA(id_cusca)
);

CREATE TABLE TEREN (
    id_teren number(5)constraint pkid_teren primary key,
    id_sol number(5),
    arie number(10),
    constraint fk_cod_sol foreign key (id_sol) references SOL(id_sol)
);

CREATE TABLE PLANTA (
    id_planta number(5) constraint pkid_planta primary key,
    id_sol number(5),
    id_teren number(5),
    calitate VARCHAR(5)  CHECK (calitate IN ('intai', 'doi','trei')),
    cantitate number(10),
    denumire VARCHAR2(50),
    constraint fk_cod_soll foreign key (id_sol) references SOL(id_sol),
    constraint fk_cod_teren foreign key (id_teren) references TEREN(id_teren)
    
);

CREATE TABLE COMANDA (
    id_comanda number(5)constraint pkid_comanda primary key,
    id_user number(5),
    adresa VARCHAR(50),
    nr_telefon number(10)constraint telefon not NULL unique,
    constraint fk_cod_user foreign key (id_user) references UTILIZATOR(id_user),
    id_angajat number(5) constraint fk_comanda_angajat references ANGAJAT(id_angajat)
);

drop table comanda;
CREATE TABLE ARE_ (
    id_sol number(5) constraint codul_solului references SOL(id_sol),
    id_teren number(5) constraint codul_terenului references TEREN(id_teren),
    constraint are_pk primary key(id_sol, id_teren)
);

CREATE TABLE ANGAJAT (
    id_angajat number(5) constraint pkid_angajat primary key,
    nume VARCHAR(25),
    prenume VARCHAR(25),
    salariu number(15)constraint salary not NULL,
    data_nastere DATE,
    sex CHAR(4) CHECK (sex IN ('f', 'm')),
    nationalitate VARCHAR(12)
);
CREATE TABLE FERMIER(
    id_angajat number(5) primary key references ANGAJAT(id_angajat),
    certificari VARCHAR(12)
);


CREATE TABLE SOFER(
    id_sofer number(5)  primary key references ANGAJAT(id_angajat),
    categorie_permis VARCHAR(20)
   
);
drop table sofer;
CREATE TABLE CONTABIL(
    id_angajat number(5)  primary key references ANGAJAT(id_angajat),
    educatie VARCHAR (60)
   
);

CREATE TABLE COMERCIANT(
    id_angajat number(5)  primary key references ANGAJAT(id_angajat),
    volumul_de_vanzari VARCHAR(12) CHECK ( volumul_de_vanzari IN ('scazut', 'mediu','crescut'))
);

CREATE TABLE INGRIJESTE(
    id_sol number(5) constraint codul_sol references SOL(id_sol),
    id_teren number(5) constraint codul_teren references TEREN(id_teren),
    id_planta number(5) constraint codul_planta references PLANTA(id_planta),
    id_cusca number(5) constraint codul_cusca references CUSCA(id_cusca),
    id_animal number(5) constraint codul_animalului references ANIMAL(id_animal),
    id_angajat number(5) constraint codul_angajatului references ANGAJAT(id_angajat),
    constraint ingrijeste_pk primary key(id_sol, id_teren, id_planta, id_cusca, id_animal, id_angajat)
);


CREATE TABLE URMEAZA(
    id_specializare number(5) constraint codul_specializarii references SPECIALIZARE(id_specializare),
    id_angajat number(5) constraint codul_angajat references ANGAJAT(id_angajat),
    experienta_in_domeniu number(3) not null,
    constraint urmeaza_pk primary key(id_specializare, id_angajat)
);


CREATE TABLE ORGANIZEAZA(
    id_activitate number(5) constraint codul_activitatii references ACTIVITATE(id_activitate),
    id_angajat number(5) constraint codul_angajat2 references ANGAJAT(id_angajat),
    locatie VARCHAR(40),
    constraint organizeaza_pk primary key(id_activitate, id_angajat)
);

drop table organizeaza;

INSERT INTO CUSCA (id_cusca, lungime, latime, capacitate)
VALUES(SEQ_CUSCA.NEXTVAL, 100, 50, 10);
INSERT INTO CUSCA (id_cusca, lungime, latime, capacitate)
VALUES (SEQ_CUSCA.NEXTVAL, 120, 60, 12);
INSERT INTO CUSCA (id_cusca, lungime, latime, capacitate)
VALUES(SEQ_CUSCA.NEXTVAL, 80, 40, 8);
INSERT INTO CUSCA (id_cusca, lungime, latime, capacitate)
VALUES(SEQ_CUSCA.NEXTVAL, 150, 75, 15);
INSERT INTO CUSCA (id_cusca, lungime, latime, capacitate)
VALUES(SEQ_CUSCA.NEXTVAL, 90, 45, 9);
INSERT INTO CUSCA (id_cusca, lungime, latime, capacitate)
VALUES(SEQ_CUSCA.NEXTVAL, 110, 55, 11);
INSERT INTO CUSCA (id_cusca, lungime, latime, capacitate)
VALUES(SEQ_CUSCA.NEXTVAL, 130, 65, 13);
INSERT INTO CUSCA (id_cusca, lungime, latime, capacitate)
VALUES (SEQ_CUSCA.NEXTVAL, 70, 35, 7);

select * from cusca;


INSERT INTO SOL (id_sol, densitate, grad_de_fertilitate)
VALUES (SEQ_SOL.NEXTVAL, 1.25, 'crescuta');
INSERT INTO SOL (id_sol, densitate, grad_de_fertilitate)
VALUES (SEQ_SOL.NEXTVAL, 1.10, 'scazuta');
INSERT INTO SOL (id_sol, densitate, grad_de_fertilitate)
VALUES (SEQ_SOL.NEXTVAL, 1.35, 'crescuta');
INSERT INTO SOL (id_sol, densitate, grad_de_fertilitate)
VALUES (SEQ_SOL.NEXTVAL, 1.18, 'crescuta');
INSERT INTO SOL (id_sol, densitate, grad_de_fertilitate)
VALUES (SEQ_SOL.NEXTVAL, 1.05, 'scazuta');
INSERT INTO SOL (id_sol, densitate, grad_de_fertilitate)
VALUES (SEQ_SOL.NEXTVAL, 1.30, 'crescuta');
INSERT INTO SOL (id_sol, densitate, grad_de_fertilitate)
VALUES(SEQ_SOL.NEXTVAL, 1.15, 'scazuta');
INSERT INTO SOL (id_sol, densitate, grad_de_fertilitate)
VALUES(SEQ_SOL.NEXTVAL, 1.22, 'crescuta');
select * from sol;

INSERT INTO ANGAJAT (id_angajat, nume, prenume, salariu, data_nastere, sex, nationalitate)
VALUES (SEQ_ANGAJAT.NEXTVAL, 'Popescu', 'Ion', 5000, to_date('1980-01-01','yyyy-mm-dd'), 'm', 'Romanian');
INSERT INTO ANGAJAT (id_angajat, nume, prenume, salariu, data_nastere, sex, nationalitate)
VALUES (SEQ_ANGAJAT.NEXTVAL, 'Ionescu', 'Maria', 4500, to_date('1989-04-01','yyyy-mm-dd'), 'f', 'Romanian');
    INSERT INTO ANGAJAT (id_angajat, nume, prenume, salariu, data_nastere, sex, nationalitate)
VALUES(SEQ_ANGAJAT.NEXTVAL, 'Smith', 'John', 6000, to_date('1970-06-09','yyyy-mm-dd'), 'm', 'English');
    INSERT INTO ANGAJAT (id_angajat, nume, prenume, salariu, data_nastere, sex, nationalitate)
VALUES(SEQ_ANGAJAT.NEXTVAL, 'Müller', 'Hans', 5500, to_date('1986-09-11','yyyy-mm-dd'), 'm', 'German');
    INSERT INTO ANGAJAT (id_angajat, nume, prenume, salariu, data_nastere, sex, nationalitate)
VALUES(SEQ_ANGAJAT.NEXTVAL, 'García', 'Ana', 4800, to_date('1984-01-07','yyyy-mm-dd'), 'f', 'Spanish');
    INSERT INTO ANGAJAT (id_angajat, nume, prenume, salariu, data_nastere, sex, nationalitate)
VALUES(SEQ_ANGAJAT.NEXTVAL, 'Rossi', 'Marco', 5200, to_date('1988-11-01','yyyy-mm-dd'), 'm', 'Italian');
    INSERT INTO ANGAJAT (id_angajat, nume, prenume, salariu, data_nastere, sex, nationalitate)
VALUES(SEQ_ANGAJAT.NEXTVAL, 'Li', 'Wei', 4900, to_date('1985-08-01','yyyy-mm-dd'), 'm', 'Chinese');
    INSERT INTO ANGAJAT (id_angajat, nume, prenume, salariu, data_nastere, sex, nationalitate)
VALUES(SEQ_ANGAJAT.NEXTVAL, 'Kim', 'Ji-hyun', 4700, to_date('1978-01-21','yyyy-mm-dd'), 'f', 'Korean');
INSERT INTO ANGAJAT (id_angajat, nume, prenume, salariu, data_nastere, sex, nationalitate)
VALUES (SEQ_ANGAJAT.NEXTVAL, 'Popovici', 'Andrei', 5200, to_date('1981-03-15','yyyy-mm-dd'), 'm', 'Romanian');
INSERT INTO ANGAJAT (id_angajat, nume, prenume, salariu, data_nastere, sex, nationalitate)
VALUES (SEQ_ANGAJAT.NEXTVAL, 'Lopez', 'Maria', 4800, to_date('1983-07-20','yyyy-mm-dd'), 'f', 'Spanish');
INSERT INTO ANGAJAT (id_angajat, nume, prenume, salariu, data_nastere, sex, nationalitate)
VALUES (SEQ_ANGAJAT.NEXTVAL, 'Schmidt', 'Julia', 5300, to_date('1980-05-10','yyyy-mm-dd'), 'f', 'German');
INSERT INTO ANGAJAT (id_angajat, nume, prenume, salariu, data_nastere, sex, nationalitate)
VALUES (SEQ_ANGAJAT.NEXTVAL, 'Russo', 'Giuseppe', 5500, to_date('1975-12-03','yyyy-mm-dd'), 'm', 'Italian');
INSERT INTO ANGAJAT (id_angajat, nume, prenume, salariu, data_nastere, sex, nationalitate)
VALUES (SEQ_ANGAJAT.NEXTVAL, 'Chen', 'Li', 5000, to_date('1982-09-28','yyyy-mm-dd'), 'f', 'Chinese');
INSERT INTO ANGAJAT (id_angajat, nume, prenume, salariu, data_nastere, sex, nationalitate)
VALUES (SEQ_ANGAJAT.NEXTVAL, 'Lee', 'Min-ji', 4600, to_date('1987-02-12','yyyy-mm-dd'), 'f', 'Korean');
INSERT INTO ANGAJAT (id_angajat, nume, prenume, salariu, data_nastere, sex, nationalitate)
VALUES (SEQ_ANGAJAT.NEXTVAL, 'Garcia', 'Juan', 5100, to_date('1984-10-05','yyyy-mm-dd'), 'm', 'Spanish');
INSERT INTO ANGAJAT (id_angajat, nume, prenume, salariu, data_nastere, sex, nationalitate)
VALUES (SEQ_ANGAJAT.NEXTVAL, 'Müller', 'Laura', 5400, to_date('1986-06-18','yyyy-mm-dd'), 'f', 'German');
INSERT INTO ANGAJAT (id_angajat, nume, prenume, salariu, data_nastere, sex, nationalitate)
VALUES (SEQ_ANGAJAT.NEXTVAL, 'Sato', 'Hiroshi', 4900, to_date('1983-09-09','yyyy-mm-dd'), 'm', 'Japanese');
INSERT INTO ANGAJAT (id_angajat, nume, prenume, salariu, data_nastere, sex, nationalitate)
VALUES (SEQ_ANGAJAT.NEXTVAL, 'Russo', 'Anna', 4700, to_date('1985-04-25','yyyy-mm-dd'), 'f', 'Italian');
INSERT INTO ANGAJAT (id_angajat, nume, prenume, salariu, data_nastere, sex, nationalitate)
VALUES (SEQ_ANGAJAT.NEXTVAL, 'Kowalski', 'Adam', 5200, to_date('1980-08-21','yyyy-mm-dd'), 'm', 'Polish');
INSERT INTO ANGAJAT (id_angajat, nume, prenume, salariu, data_nastere, sex, nationalitate)
VALUES (SEQ_ANGAJAT.NEXTVAL, 'López', 'Carmen', 4800, to_date('1982-03-07','yyyy-mm-dd'), 'f', 'Spanish');


select * from angajat;

INSERT INTO SPECIALIZARE (id_specializare, data_infiintarii, nume_s)
VALUES (SEQ_SPECIALIZARE.NEXTVAL, to_date('1983-09-09','yyyy-mm-dd'), 'Cultivarea cerealelor');
INSERT INTO SPECIALIZARE (id_specializare, data_infiintarii, nume_s)
VALUES (SEQ_SPECIALIZARE.NEXTVAL, to_date('1993-08-09','yyyy-mm-dd'), 'Cresterea animalelor');
INSERT INTO SPECIALIZARE (id_specializare,data_infiintarii, nume_s)
VALUES (SEQ_SPECIALIZARE.NEXTVAL, to_date('2003-11-09','yyyy-mm-dd'), 'Horticultura si gradinarit');
INSERT INTO SPECIALIZARE (id_specializare, data_infiintarii, nume_s)
VALUES (SEQ_SPECIALIZARE.NEXTVAL, to_date('1999-09-10','yyyy-mm-dd'), 'Apicultura (cresterea albinelor)');
INSERT INTO SPECIALIZARE (id_specializare, data_infiintarii, nume_s)
VALUES (SEQ_SPECIALIZARE.NEXTVAL, to_date('2000-12-21','yyyy-mm-dd'), 'Viticultura si vinificatie');
INSERT INTO SPECIALIZARE (id_specializare, data_infiintarii, nume_s)
VALUES (SEQ_SPECIALIZARE.NEXTVAL, to_date('1997-01-22','yyyy-mm-dd'), 'Piscicultura (cresterea pestilor)');
INSERT INTO SPECIALIZARE (id_specializare, data_infiintarii, nume_s)
VALUES (SEQ_SPECIALIZARE.NEXTVAL, to_date('1999-01-17','yyyy-mm-dd'), 'Cresterea pasarilor');
INSERT INTO SPECIALIZARE (id_specializare, data_infiintarii, nume_s)
VALUES (SEQ_SPECIALIZARE.NEXTVAL, to_date('1995-06-14','yyyy-mm-dd'), 'Cultivarea plantelor medicinale si aromatice');
INSERT INTO SPECIALIZARE (id_specializare, data_infiintarii, nume_s)
VALUES (SEQ_SPECIALIZARE.NEXTVAL, to_date('1995-08-14','yyyy-mm-dd'), 'Cultivarea plante ornamentale');

select * from specializare;

INSERT INTO CAMION_DE_MARFA (id_camion, capacitate,id_sofer)
VALUES(SEQ_CAMION_DE_MARFA.NEXTVAL, 50,205);
    INSERT INTO CAMION_DE_MARFA (id_camion, capacitate,id_sofer)
VALUES(SEQ_CAMION_DE_MARFA.NEXTVAL, 60,206);
    INSERT INTO CAMION_DE_MARFA (id_camion, capacitate,id_sofer)
VALUES(SEQ_CAMION_DE_MARFA.NEXTVAL, 45,207);
    INSERT INTO CAMION_DE_MARFA (id_camion, capacitate, id_sofer)
VALUES(SEQ_CAMION_DE_MARFA.NEXTVAL, 55,208);
    INSERT INTO CAMION_DE_MARFA (id_camion, capacitate, id_sofer)
VALUES(SEQ_CAMION_DE_MARFA.NEXTVAL, 4,209);

select * from camion_de_marfa;

INSERT INTO ISTORIC (id_istoric, data_angajarii, data_promovarii, productivitate, id_angajat )
VALUES (SEQ_ISTORIC.NEXTVAL, TO_DATE('15-01-2020', 'dd-mm-yyyy'), TO_DATE('10-03-2022', 'dd-mm-yyyy'), 'crescuta',200);
    INSERT INTO ISTORIC (id_istoric, data_angajarii, data_promovarii, productivitate,id_angajat)
VALUES(SEQ_ISTORIC.NEXTVAL, TO_DATE('20-06-2019', 'dd-mm-yyyy'), TO_DATE('05-09-2021', 'dd-mm-yyyy'), 'scazuta',201);
    INSERT INTO ISTORIC (id_istoric, data_angajarii, data_promovarii, productivitate,id_angajat)
VALUES(SEQ_ISTORIC.NEXTVAL, TO_DATE('01-02-2021', 'dd-mm-yyyy'), NULL, 'crescuta',202);
    INSERT INTO ISTORIC (id_istoric, data_angajarii, data_promovarii, productivitate,id_angajat)
VALUES(SEQ_ISTORIC.NEXTVAL, TO_DATE('10-09-2020', 'dd-mm-yyyy'), TO_DATE('01-05-2022', 'dd-mm-yyyy'), 'crescuta',203);
    INSERT INTO ISTORIC (id_istoric, data_angajarii, data_promovarii, productivitate,id_angajat)
VALUES(SEQ_ISTORIC.NEXTVAL, TO_DATE('25-11-2019', 'dd-mm-yyyy'), NULL, 'scazuta',204);
    INSERT INTO ISTORIC (id_istoric, data_angajarii, data_promovarii, productivitate,id_angajat)
VALUES(SEQ_ISTORIC.NEXTVAL, TO_DATE('03-04-2020', 'dd-mm-yyyy'), TO_DATE('15-01-2022', 'dd-mm-yyyy'), 'crescuta',205);
    INSERT INTO ISTORIC (id_istoric, data_angajarii, data_promovarii, productivitate,id_angajat)
VALUES(SEQ_ISTORIC.NEXTVAL, TO_DATE('01-03-2021', 'dd-mm-yyyy'), TO_DATE('20-04-2022', 'dd-mm-yyyy'), 'crescuta',206);
INSERT INTO ISTORIC (id_istoric, data_angajarii, data_promovarii, productivitate,id_angajat)
VALUES(SEQ_ISTORIC.NEXTVAL, TO_DATE('10-07-2005', 'dd-mm-yyyy'),  NULL, 'scazuta',207);
INSERT INTO ISTORIC (id_istoric, data_angajarii, data_promovarii, productivitate,id_angajat)
VALUES(SEQ_ISTORIC.NEXTVAL, TO_DATE('10-06-2020', 'dd-mm-yyyy'), TO_DATE('28-07-2022', 'dd-mm-yyyy'), 'scazuta',208);
INSERT INTO ISTORIC (id_istoric, data_angajarii, data_promovarii, productivitate,id_angajat)
VALUES(SEQ_ISTORIC.NEXTVAL, TO_DATE('28-07-2011', 'dd-mm-yyyy'), TO_DATE('18-09-2022', 'dd-mm-yyyy'), 'scazuta',209);
INSERT INTO ISTORIC (id_istoric, data_angajarii, data_promovarii, productivitate,id_angajat)
VALUES(SEQ_ISTORIC.NEXTVAL, TO_DATE('11-07-2011', 'dd-mm-yyyy'), TO_DATE('18-08-2022', 'dd-mm-yyyy'), 'scazuta',210);
INSERT INTO ISTORIC (id_istoric, data_angajarii, data_promovarii, productivitate,id_angajat)
VALUES(SEQ_ISTORIC.NEXTVAL, TO_DATE('09-06-2004', 'dd-mm-yyyy'), TO_DATE('28-02-2022', 'dd-mm-yyyy'), 'crescuta',211);
INSERT INTO ISTORIC (id_istoric, data_angajarii, data_promovarii, productivitate,id_angajat)
VALUES(SEQ_ISTORIC.NEXTVAL, TO_DATE('10-03-2003', 'dd-mm-yyyy'),  NULL, 'scazuta',212);
INSERT INTO ISTORIC (id_istoric, data_angajarii, data_promovarii, productivitate,id_angajat)
VALUES(SEQ_ISTORIC.NEXTVAL, TO_DATE('19-07-2019', 'dd-mm-yyyy'), TO_DATE('21-04-2022', 'dd-mm-yyyy'), 'scazuta',213);
INSERT INTO ISTORIC (id_istoric, data_angajarii, data_promovarii, productivitate,id_angajat)
VALUES(SEQ_ISTORIC.NEXTVAL, TO_DATE('10-09-2020', 'dd-mm-yyyy'), TO_DATE('16-11-2022', 'dd-mm-yyyy'), 'crescuta',214);
INSERT INTO ISTORIC (id_istoric, data_angajarii, data_promovarii, productivitate,id_angajat)
VALUES(SEQ_ISTORIC.NEXTVAL, TO_DATE('18-02-2015', 'dd-mm-yyyy'),  NULL, 'scazuta',215);
INSERT INTO ISTORIC (id_istoric, data_angajarii, data_promovarii, productivitate,id_angajat)
VALUES(SEQ_ISTORIC.NEXTVAL, TO_DATE('10-01-2015', 'dd-mm-yyyy'), TO_DATE('18-04-2022', 'dd-mm-yyyy'), 'crescuta',216);
INSERT INTO ISTORIC (id_istoric, data_angajarii, data_promovarii, productivitate,id_angajat)
VALUES(SEQ_ISTORIC.NEXTVAL, TO_DATE('02-05-2018', 'dd-mm-yyyy'),  NULL, 'crescuta',217);
INSERT INTO ISTORIC (id_istoric, data_angajarii, data_promovarii, productivitate,id_angajat)
VALUES(SEQ_ISTORIC.NEXTVAL, TO_DATE('01-08-2019', 'dd-mm-yyyy'), TO_DATE('19-09-2022', 'dd-mm-yyyy'), 'scazuta',218);
INSERT INTO ISTORIC (id_istoric, data_angajarii, data_promovarii, productivitate,id_angajat)
VALUES(SEQ_ISTORIC.NEXTVAL, TO_DATE('11-09-2005', 'dd-mm-yyyy'), TO_DATE('01-05-2022', 'dd-mm-yyyy'), 'crescuta',219);

select * from istoric;


INSERT INTO ACTIVITATE (id_activitate, data_desfasurare, ora, stare_curenta)
VALUES (SEQ_ACTIVITATE.NEXTVAL, TO_DATE('2023-01-15', 'YYYY-MM-DD') ,'11:00', 'in desfasurare');
INSERT INTO ACTIVITATE (id_activitate, data_desfasurare, ora,stare_curenta)
VALUES (SEQ_ACTIVITATE.NEXTVAL, TO_DATE('2023-02-20', 'YYYY-MM-DD') , '14:30', 'finalizata');
INSERT INTO ACTIVITATE (id_activitate, data_desfasurare, ora,stare_curenta)
VALUES (SEQ_ACTIVITATE.NEXTVAL, TO_DATE('2023-03-10', 'YYYY-MM-DD') , '16:00',  'anulata');
INSERT INTO ACTIVITATE (id_activitate, data_desfasurare, ora,stare_curenta)
VALUES (SEQ_ACTIVITATE.NEXTVAL, TO_DATE('2023-04-05', 'YYYY-MM-DD') , '11:15',  'in desfasurare');
INSERT INTO ACTIVITATE (id_activitate, data_desfasurare, ora,stare_curenta)
VALUES (SEQ_ACTIVITATE.NEXTVAL, TO_DATE('2023-05-12', 'YYYY-MM-DD') , '13:45',  'in desfasurare');
INSERT INTO ACTIVITATE (id_activitate, data_desfasurare, ora,stare_curenta)
VALUES (SEQ_ACTIVITATE.NEXTVAL, TO_DATE('2023-06-18', 'YYYY-MM-DD') ,'10:30',  'in desfasurare');
INSERT INTO ACTIVITATE (id_activitate, data_desfasurare, ora, stare_curenta)
VALUES (SEQ_ACTIVITATE.NEXTVAL, TO_DATE('2023-07-25', 'YYYY-MM-DD') , '15:00',  'finalizata');
INSERT INTO ACTIVITATE (id_activitate, data_desfasurare, ora,stare_curenta)
VALUES (SEQ_ACTIVITATE.NEXTVAL, TO_DATE('2023-08-30', 'YYYY-MM-DD') , '09:',  'in desfasurare');

select * from activitate;


INSERT INTO UTILIZATOR (id_user, nume, prenume,rating_vanzator)
VALUES(SEQ_UTILIZATOR.NEXTVAL, 'Smith', 'John','aur');
INSERT INTO UTILIZATOR (id_user, nume, prenume,rating_vanzator)
VALUES(SEQ_UTILIZATOR.NEXTVAL, 'Johnson', 'Sarah','bronz');
INSERT INTO UTILIZATOR (id_user, nume, prenume,rating_vanzator)
VALUES(SEQ_UTILIZATOR.NEXTVAL, 'Williams', 'David','argint');
INSERT INTO UTILIZATOR (id_user, nume, prenume,rating_vanzator)
VALUES(SEQ_UTILIZATOR.NEXTVAL, 'Brown', 'Emily','aur');
INSERT INTO UTILIZATOR (id_user, nume, prenume,rating_vanzator)
VALUES(SEQ_UTILIZATOR.NEXTVAL, 'Jones', 'Michael','bronz');
INSERT INTO UTILIZATOR (id_user, nume, prenume,rating_vanzator)
VALUES(SEQ_UTILIZATOR.NEXTVAL, 'Taylor', 'Jessica','aur');
INSERT INTO UTILIZATOR (id_user, nume, prenume,rating_vanzator)
VALUES(SEQ_UTILIZATOR.NEXTVAL, 'Davis', 'Daniel','argint');
INSERT INTO UTILIZATOR (id_user, nume, prenume,rating_vanzator)
VALUES(SEQ_UTILIZATOR.NEXTVAL, 'Miller', 'Olivia','argint');

select * from utilizator;

INSERT INTO ANIMAL (id_animal, id_cusca, rasa, nr_animale)
VALUES(SEQ_ANIMAL.NEXTVAL, 1, 'Caine', 5);
INSERT INTO ANIMAL (id_animal, id_cusca, rasa, nr_animale)
VALUES(SEQ_ANIMAL.NEXTVAL, 2, 'Pisica', 3);
INSERT INTO ANIMAL (id_animal, id_cusca, rasa, nr_animale)
VALUES(SEQ_ANIMAL.NEXTVAL, 3, 'Gaina', 10);
INSERT INTO ANIMAL (id_animal, id_cusca, rasa, nr_animale)
VALUES(SEQ_ANIMAL.NEXTVAL, 4, 'Iepure', 2);
INSERT INTO ANIMAL (id_animal, id_cusca, rasa, nr_animale)
VALUES(SEQ_ANIMAL.NEXTVAL, 5, 'Porc', 4);
INSERT INTO ANIMAL (id_animal, id_cusca, rasa, nr_animale)
VALUES(SEQ_ANIMAL.NEXTVAL, 6, 'Oaie', 6);
INSERT INTO ANIMAL (id_animal, id_cusca, rasa, nr_animale)
VALUES(SEQ_ANIMAL.NEXTVAL, 7, 'Cal', 1);
INSERT INTO ANIMAL (id_animal, id_cusca, rasa, nr_animale)
VALUES(SEQ_ANIMAL.NEXTVAL, 8, 'Rata', 5);

select * from animal;

INSERT INTO TEREN (id_teren, id_sol, arie)
VALUES(SEQ_TEREN.NEXTVAL, 10, 100);
INSERT INTO TEREN (id_teren, id_sol, arie)
VALUES(SEQ_TEREN.NEXTVAL, 11, 200);
INSERT INTO TEREN (id_teren, id_sol, arie)
VALUES(SEQ_TEREN.NEXTVAL, 12, 150);
INSERT INTO TEREN (id_teren, id_sol, arie)
VALUES(SEQ_TEREN.NEXTVAL, 13, 80);
INSERT INTO TEREN (id_teren, id_sol, arie)
VALUES(SEQ_TEREN.NEXTVAL, 14, 120);
INSERT INTO TEREN (id_teren, id_sol, arie)
VALUES(SEQ_TEREN.NEXTVAL, 15, 90);
INSERT INTO TEREN (id_teren, id_sol, arie)
VALUES(SEQ_TEREN.NEXTVAL, 16, 70);
INSERT INTO TEREN (id_teren, id_sol, arie)
VALUES(SEQ_TEREN.NEXTVAL, 17, 110);

select * from teren;
INSERT INTO PLANTA (id_planta, id_sol, id_teren, calitate, cantitate, denumire)
VALUES(SEQ_PLANTA.NEXTVAL, 10,90, 'intai', 100,'Porumb');
INSERT INTO PLANTA (id_planta, id_sol, id_teren, calitate, cantitate, denumire)
VALUES(SEQ_PLANTA.NEXTVAL, 11, 91, 'doi', 150,'Grau');
INSERT INTO PLANTA (id_planta, id_sol, id_teren, calitate, cantitate, denumire)
VALUES(SEQ_PLANTA.NEXTVAL,  13, 92, 'trei', 200,'Rosie');
INSERT INTO PLANTA (id_planta, id_sol, id_teren, calitate, cantitate, denumire)
VALUES(SEQ_PLANTA.NEXTVAL, 17, 93, 'intai', 80,'Castravete');
INSERT INTO PLANTA (id_planta, id_sol, id_teren, calitate, cantitate, denumire)
VALUES(SEQ_PLANTA.NEXTVAL, 12, 94, 'doi', 120,'Ceapa');
INSERT INTO PLANTA (id_planta, id_sol, id_teren, calitate, cantitate, denumire)
VALUES(SEQ_PLANTA.NEXTVAL,  10, 95, 'trei', 90,'Morcov');
INSERT INTO PLANTA (id_planta, id_sol, id_teren, calitate, cantitate, denumire)
VALUES(SEQ_PLANTA.NEXTVAL,  15,96, 'intai', 70,'Ardei gras');
INSERT INTO PLANTA (id_planta, id_sol, id_teren, calitate, cantitate, denumire)
VALUES(SEQ_PLANTA.NEXTVAL,  15,97, 'doi', 110,'Ananas');

select * from planta;
update planta set denumire='Ananas' where id_planta=107;
commit;
INSERT INTO COMANDA (id_comanda, id_user, adresa, nr_telefon,id_angajat)
VALUES(SEQ_COMANDA.NEXTVAL, 70, 'Adresa 1', 1234567890,215);
INSERT INTO COMANDA (id_comanda, id_user, adresa, nr_telefon,id_angajat)
VALUES(SEQ_COMANDA.NEXTVAL, 71, 'Adresa 2', 9876543210,216);
INSERT INTO COMANDA (id_comanda, id_user, adresa, nr_telefon,id_angajat)
VALUES(SEQ_COMANDA.NEXTVAL, 72, 'Adresa 3', 4567890123,217);
INSERT INTO COMANDA (id_comanda, id_user, adresa, nr_telefon,id_angajat)
VALUES(SEQ_COMANDA.NEXTVAL, 73, 'Adresa 4', 7890123456,218);
INSERT INTO COMANDA (id_comanda, id_user, adresa, nr_telefon,id_angajat)
VALUES(SEQ_COMANDA.NEXTVAL, 74, 'Adresa 5', 2345678901,219);
INSERT INTO COMANDA (id_comanda, id_user, adresa, nr_telefon,id_angajat)
VALUES(SEQ_COMANDA.NEXTVAL, 70, 'Adresa 6', 9345678901,219);
INSERT INTO COMANDA (id_comanda, id_user, adresa, nr_telefon,id_angajat)
VALUES(SEQ_COMANDA.NEXTVAL, 72, 'Adresa 7', 2945678001,217);
INSERT INTO COMANDA (id_comanda, id_user, adresa, nr_telefon,id_angajat)
VALUES(SEQ_COMANDA.NEXTVAL, 74, 'Adresa 8', 2346678901,219);

select * from comanda;

INSERT INTO ARE_ (id_sol, id_teren) VALUES (10, 90);
INSERT INTO ARE_ (id_sol, id_teren) VALUES (12, 91);
INSERT INTO ARE_ (id_sol, id_teren) VALUES (10, 92);
INSERT INTO ARE_ (id_sol, id_teren) VALUES (12, 93);
INSERT INTO ARE_ (id_sol, id_teren) VALUES (12, 94);
INSERT INTO ARE_ (id_sol, id_teren) VALUES (12, 95);
INSERT INTO ARE_ (id_sol, id_teren) VALUES (13, 96);
INSERT INTO ARE_ (id_sol, id_teren) VALUES (13, 97);
INSERT INTO ARE_ (id_sol, id_teren) VALUES (13, 91);
INSERT INTO ARE_ (id_sol, id_teren) VALUES (14, 95);
INSERT INTO ARE_ (id_sol, id_teren) VALUES (14, 96);
INSERT INTO ARE_ (id_sol, id_teren) VALUES (16, 95);

select * from are_;


INSERT INTO FERMIER (id_angajat, certificari)
VALUES (200, 'Certificat1');
INSERT INTO FERMIER (id_angajat, certificari)
VALUES (201, 'Certificat2');
INSERT INTO FERMIER (id_angajat, certificari)
VALUES (202, 'Certificat3');
INSERT INTO FERMIER (id_angajat, certificari)
VALUES (203, 'Certificat4');
INSERT INTO FERMIER (id_angajat, certificari)
VALUES (204, 'Certificat5');

select * from fermier;

INSERT INTO SOFER (id_sofer, categorie_permis)
VALUES (205, 'B');
INSERT INTO SOFER (id_sofer, categorie_permis)
VALUES (206, 'B, C');
INSERT INTO SOFER (id_sofer, categorie_permis)
VALUES (207, 'B, C, D');
INSERT INTO SOFER (id_sofer, categorie_permis)
VALUES (208, 'C');
INSERT INTO SOFER (id_sofer, categorie_permis)
VALUES (209, 'D');
INSERT INTO SOFER (id_sofer, categorie_permis)
VALUES (210, 'D');
INSERT INTO SOFER (id_sofer, categorie_permis)
VALUES (202, 'D');
select * from sofer;

INSERT INTO CONTABIL (id_angajat, educatie)
VALUES (210, 'Facultatea de Economie');
INSERT INTO CONTABIL (id_angajat, educatie)
VALUES (211, 'Facultatea de Contabilitate si Informatica de Gestiune');
INSERT INTO CONTABIL (id_angajat, educatie)
VALUES (212, 'Facultatea de Finante si Banci');
INSERT INTO CONTABIL (id_angajat, educatie)
VALUES (213, 'Facultatea de Administratie si Afaceri');
INSERT INTO CONTABIL (id_angajat, educatie)
VALUES (214, 'Facultatea de Audit si Controlul Afacerilor');

select * from contabil;

INSERT INTO COMERCIANT (id_angajat, volumul_de_vanzari)
VALUES (215, 'mediu');
INSERT INTO COMERCIANT (id_angajat, volumul_de_vanzari)
VALUES (216, 'crescut');
INSERT INTO COMERCIANT (id_angajat, volumul_de_vanzari)
VALUES (217, 'scazut');
INSERT INTO COMERCIANT (id_angajat, volumul_de_vanzari)
VALUES (218, 'mediu');
INSERT INTO COMERCIANT (id_angajat, volumul_de_vanzari)
VALUES (219, 'crescut');

select * from  comerciant;

INSERT INTO INGRIJESTE (id_sol, id_teren, id_planta, id_cusca, id_animal, id_angajat)
VALUES (10, 91, 101, 1, 80, 200);
INSERT INTO INGRIJESTE (id_sol, id_teren, id_planta, id_cusca, id_animal, id_angajat)
VALUES (17, 92, 102, 2, 82, 201);
INSERT INTO INGRIJESTE (id_sol, id_teren, id_planta, id_cusca, id_animal, id_angajat)
VALUES (16, 93, 103, 3, 81, 203);
INSERT INTO INGRIJESTE (id_sol, id_teren, id_planta, id_cusca, id_animal, id_angajat)
VALUES (13, 94, 104, 4, 83, 203);
INSERT INTO INGRIJESTE (id_sol, id_teren, id_planta, id_cusca, id_animal, id_angajat)
VALUES (14, 95, 105, 5, 87, 204);
INSERT INTO INGRIJESTE (id_sol, id_teren, id_planta, id_cusca, id_animal, id_angajat)
VALUES (11, 96, 106, 6, 83, 200);
INSERT INTO INGRIJESTE (id_sol, id_teren, id_planta, id_cusca, id_animal, id_angajat)
VALUES (16, 97, 107, 7, 84, 201);
INSERT INTO INGRIJESTE (id_sol, id_teren, id_planta, id_cusca, id_animal, id_angajat)
VALUES (15, 97, 100, 8, 86, 202);
INSERT INTO INGRIJESTE (id_sol, id_teren, id_planta, id_cusca, id_animal, id_angajat)
VALUES (15, 90, 100, 7, 85, 203);
INSERT INTO INGRIJESTE (id_sol, id_teren, id_planta, id_cusca, id_animal, id_angajat)
VALUES (12, 96, 101, 6, 84, 204);

select * from ingrijeste;

INSERT INTO URMEAZA (id_specializare, id_angajat, experienta_in_domeniu)
VALUES (30, 200, 2);
INSERT INTO URMEAZA (id_specializare, id_angajat, experienta_in_domeniu)
VALUES (31, 201, 3);
INSERT INTO URMEAZA (id_specializare, id_angajat, experienta_in_domeniu)
VALUES (32, 202, 1);
INSERT INTO URMEAZA (id_specializare, id_angajat, experienta_in_domeniu)
VALUES (33, 203, 4);
INSERT INTO URMEAZA (id_specializare, id_angajat, experienta_in_domeniu)
VALUES (34, 204, 2);
INSERT INTO URMEAZA (id_specializare, id_angajat, experienta_in_domeniu)
VALUES (35, 200, 5);
INSERT INTO URMEAZA (id_specializare, id_angajat, experienta_in_domeniu)
VALUES (36, 201, 3);
INSERT INTO URMEAZA (id_specializare, id_angajat, experienta_in_domeniu)
VALUES (37, 202, 2);
INSERT INTO URMEAZA (id_specializare, id_angajat, experienta_in_domeniu)
VALUES (37, 203, 1);
INSERT INTO URMEAZA (id_specializare, id_angajat, experienta_in_domeniu)
VALUES (30, 204, 4);


select * from urmeaza;

INSERT INTO ORGANIZEAZA (id_activitate, id_angajat, locatie)
VALUES (60, 210, 'Hamaru Farm - Barn 1');
INSERT INTO ORGANIZEAZA (id_activitate, id_angajat, locatie)
VALUES (60, 211, 'Hamaru Farm - Greenhouse');
INSERT INTO ORGANIZEAZA (id_activitate, id_angajat, locatie)
VALUES (62, 212, 'Hamaru Farm - Livestock Area');
INSERT INTO ORGANIZEAZA (id_activitate, id_angajat, locatie)
VALUES (63, 213, 'Hamaru Farm - Field 3');
INSERT INTO ORGANIZEAZA (id_activitate, id_angajat, locatie)
VALUES (64, 214, 'Hamaru Farm - Orchard');
INSERT INTO ORGANIZEAZA (id_activitate, id_angajat, locatie)
VALUES (65, 210, 'Green Fields Farm - Milking Parlor');
INSERT INTO ORGANIZEAZA (id_activitate, id_angajat, locatie)
VALUES (66, 211, 'Green Fields Farm - Crop Storage');
INSERT INTO ORGANIZEAZA (id_activitate, id_angajat, locatie)
VALUES (67, 212, 'Green Fields Farm - Poultry House');
INSERT INTO ORGANIZEAZA (id_activitate, id_angajat, locatie)
VALUES (67, 213, 'Green Fields Farm - Barn 2');
INSERT INTO ORGANIZEAZA (id_activitate, id_angajat, locatie)
VALUES (60, 214, 'Green Fields Farm - Vegetable Garden');



select * from organizeaza;

