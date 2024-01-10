SET VERIFY OFF
SET SERVEROUTPUT ON
--6. Formula?i în limbaj natural o problem? pe care s? o rezolva?i folosind un subprogram stocat
--independent care s? utilizeze toate cele 3 tipuri de colec?ii studiate. Apela?i subprogramul.
--
--Creati o procedura stocata independent care sa intoarca numarul de specializari procesate.
--Procedura va afisa numele,salariul, id_angajat , certificarile si specializarile fermierilor cu cel 
--mai mic salariu in functie de specializare.(fermierul cu salariul cel mai mic din fiecare specializare).
--De asemenea aflati cat la suta din angajati cu salariu mai mare ca un parametru dat de la tastatura sunt fermieri 
--si afisati numele prenumele si salariul lor in ordine crescatoare
--In cazul in care in schema exista specializari in care nu lucreaza nimeni se va afisa un mesaj corespunzator.

select * from fermier;
select * from specializare;
select * from angajat;
CREATE OR REPLACE PROCEDURE afisare (nr_specializari OUT NUMBER, p_salariu IN angajat.salariu%TYPE) IS

--tablou indexat 
    TYPE tablou_indexat IS TABLE OF fermier%ROWTYPE INDEX BY BINARY_INTEGER;
--tablou imbricat
    TYPE tablou_imbricat1 IS TABLE OF angajat.nume%TYPE;
    TYPE tablou_imbricat2 IS TABLE OF specializare.nume_s%TYPE;
--vector
    TYPE vector IS VARRAY(15) OF angajat.salariu%TYPE;
--extra:tip record 
    TYPE fermier_record IS RECORD (
        f_nume angajat.nume%TYPE,
        f_prenume angajat.prenume%TYPE,
        f_salariu angajat.salariu%TYPE
    );
    TYPE date_fermier IS VARRAY(100) OF fermier_record;
    date_fermier_var date_fermier:=date_fermier();
    t_ind tablou_indexat;
    t_imb tablou_imbricat1:= tablou_imbricat1();
    t_spc tablou_imbricat2;
    vec vector:= vector();
    
    v_salariu angajat.salariu%TYPE;
    v_nume angajat.nume%TYPE;
    v_nr NUMBER;
    v_nr_angajati NUMBER;
    v_nr_fermieri NUMBER;
    v_procent NUMBER;
    exceptia_mea EXCEPTION;
BEGIN
    
--obtinem angajatul si certificarea acestuia
    SELECT f.id_angajat,f.certificari
    BULK COLLECT INTO  t_ind
    FROM angajat a JOIN fermier f ON (f.id_angajat = a.id_angajat)
            JOIN urmeaza u ON (u.id_angajat = f.id_angajat)
            JOIN specializare s ON (s.id_specializare = u.id_specializare)
    WHERE a.salariu = ( SELECT min(salariu)
                        FROM angajat a2
                        JOIN fermier f2 ON (f2.id_angajat = a2.id_angajat)
                        JOIN urmeaza u2 ON (u2.id_angajat = f2.id_angajat)
                        JOIN specializare s2 ON (s2.id_specializare=u2.id_specializare)
                        WHERE s.id_specializare = s2.id_specializare)
     ORDER BY nume;
    --obtine salariu si nume 
    FOR i in t_ind.FIRST..t_ind.LAST LOOP
        SELECT nume, salariu
        INTO v_nume, v_salariu
        FROM angajat 
        WHERE id_angajat = t_ind(i).id_angajat;
        
        t_imb.extend;
        t_imb(i):= v_nume;
        vec.extend;
        vec(i):= v_salariu;
    END LOOP;
    
    --obtinem specializarea
    SELECT nume_s
    BULK COLLECT INTO  t_spc
    FROM angajat a JOIN fermier f ON (f.id_angajat = a.id_angajat)
            JOIN urmeaza u ON (u.id_angajat = f.id_angajat)
            JOIN specializare s ON (s.id_specializare = u.id_specializare)
    WHERE a.salariu = ( SELECT min(salariu)
                        FROM angajat a2
                        JOIN fermier f2 ON (f2.id_angajat = a2.id_angajat)
                        JOIN urmeaza u2 ON (u2.id_angajat = f2.id_angajat)
                        JOIN specializare s2 ON (s2.id_specializare=u2.id_specializare)
                        WHERE s.id_specializare = s2.id_specializare)
    ORDER BY nume;
    --vedem daca exista specializari fara angajati
    SELECT count(*)
    INTO v_nr
    FROM specializare;
    
    nr_specializari:=CARDINALITY(t_spc);
    
    --afisez datele obtinute 
    FOR i in t_ind.FIRST..t_ind.LAST LOOP
    DBMS_OUTPUT.PUT_LINE('Fermierul cu salariul cel mai mic din specializare: '||t_spc(i)||' este '||t_imb(i)||
    ',avand id-ul: '|| t_ind(i).id_angajat || ', salariul: ' ||vec(i)|| ' si are certificatul: '||t_ind(i).certificari);
    END LOOP;
    IF v_nr != nr_specializari THEN
        DBMS_OUTPUT.PUT_LINE ('Exista specializari in care nu lucreaza nimeni!');
    END IF; 
    
    --aflare procent
    
    IF p_salariu <=0 THEN
      RAISE exceptia_mea;
    END IF;
    
    SELECT count(id_angajat)
    INTO v_nr_angajati
    FROM angajat
    WHERE salariu > p_salariu;
    
    SELECT count(f.id_angajat)
    INTO v_nr_fermieri
    FROM fermier f join angajat a on (f.id_angajat=a.id_angajat)
    WHERE salariu > p_salariu;
   
    
    v_procent := round((v_nr_fermieri*100)/v_nr_angajati,4);
    DBMS_OUTPUT.PUT_LINE('Procentul de fermier cu salariu mai mare: '||v_procent||' %'); 
    SELECT nume, prenume, salariu
    BULK COLLECT INTO date_fermier_var
    FROM fermier f join angajat a on (f.id_angajat=a.id_angajat)
    WHERE salariu > p_salariu;
    --afisare
    FOR i in date_fermier_var.FIRST..date_fermier_var.LAST LOOP
    DBMS_OUTPUT.PUT_LINE('Fermierul: '||date_fermier_var(i).f_nume || ' '||date_fermier_var(i).f_prenume|| ' are salariul: '||date_fermier_var(i).f_salariu);
    END LOOP;

    EXCEPTION
    WHEN SUBSCRIPT_OUTSIDE_LIMIT THEN
     RAISE_APPLICATION_ERROR (-20144, 'Incercati sa aceesati nested_tabelul sau varray elementul la o pozitie inafara lui');
    WHEN COLLECTION_IS_NULL THEN
     RAISE_APPLICATION_ERROR (-20145, 'Nu ati initializat colectia de date');
     WHEN ZERO_DIVIDE THEN
     RAISE_APPLICATION_ERROR (-20146, 'Calcularea procentului va impartii la 0 produsul!');
      WHEN exceptia_mea THEN
     RAISE_APPLICATION_ERROR (-20147, 'Salariu nu poate fi un numar negativ sau 0');
     WHEN others THEN
     RAISE_APPLICATION_ERROR (SQLCODE, SQLERRM);

END;
/
--calcularea imparte procentul la 0
DECLARE
    nr_specializari NUMBER;
BEGIN
    afisare(nr_specializari,4563456789);
    DBMS_OUTPUT.PUT_LINE('S-au afisat: '||nr_specializari|| ' rezultate din prima interogare');
END;
/
--se afiseaza 8 fermieri
DECLARE
    nr_specializari NUMBER;
BEGIN
    afisare(nr_specializari,4569);
    DBMS_OUTPUT.PUT_LINE('S-au afisat: '||nr_specializari|| ' rezultate din prima interogare');
END;
/
--salariul nu poate fi negativ
DECLARE
    nr_specializari NUMBER;
BEGIN
    afisare(nr_specializari,-5);
    DBMS_OUTPUT.PUT_LINE('S-au afisat: '||nr_specializari|| ' rezultate din prima interogare');
END;
/


DELETE FROM specializare where id_specializare= 231;
--pentru exceptiile  SUBSCRIPT_OUTSIDE_LIMIT si COLLECTION_IS_NULL ele vor fi apelate doar daca codul scris este gresit




-----------------------------------------------------------------------------------------------

--7. Formula?i în limbaj natural o problem? pe care s? o rezolva?i folosind un subprogram stocat
--independent care s? utilizeze 2 tipuri diferite de cursoare studiate, unul dintre acestea fiind cursor
--parametrizat, dependent de cel?lalt cursor. Apela?i subprogramul.
--
--cursor parametrizat si cursor dinamic - expresii cursor
--
--Enunt:
--Sa se determine datele personale ale fiecarui utilizator ce apartine unei categorii de rating dat de catre comerciant.
--Prin date personale se intelege: prenume, id-user, numarul de telefon si adresa comenzii cat si numarul lui de comenzi
--si cate persoane au lucrat la acele comenzi
select * from utilizator;
select * from comanda;
select * from comerciant;
select * from angajat;
rollback;

CREATE OR REPLACE PROCEDURE utilizator_comerciant (p_rating IN utilizator.rating_vanzator%TYPE) IS
TYPE refcursor IS REF CURSOR;
CURSOR date_personale IS 
    SELECT id_user, prenume,
        CURSOR (SELECT nr_telefon, adresa
                FROM comanda c
                WHERE u.id_user = c.id_user)
    FROM utilizator u
    WHERE rating_vanzator = p_rating;
CURSOR comm (v_id_user utilizator.id_user%TYPE)IS
        SELECT COUNT(c.id_comanda),COUNT(DISTINCT c.id_angajat)
        FROM comanda c JOIN angajat a ON c.id_angajat = a.id_angajat
        WHERE id_user = v_id_user
        GROUP BY id_user;

v_cursor refcursor;
d_id_user utilizator.id_user%TYPE;
d_prenume_user utilizator.prenume%TYPE;
ref_tel comanda.nr_telefon%TYPE;
ref_adresa comanda.adresa%TYPE;

c_nr_comenzi NUMBER;
c_nr_angajati NUMBER;

exceptia_mea EXCEPTION;

BEGIN
    IF p_rating !='aur' AND p_rating !='argint' AND p_rating !='bronz' THEN
    RAISE exceptia_mea;
    END IF;
    OPEN date_personale;
    LOOP
        FETCH date_personale INTO d_id_user, d_prenume_user, v_cursor;
        EXIT WHEN  date_personale%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('-------------------------------------');
        DBMS_OUTPUT.PUT_LINE ('Utilizatorul numit '||d_prenume_user || ' cu id-ul: ' || d_id_user || ' are:');
        DBMS_OUTPUT.PUT_LINE('-------------------------------------');
        OPEN comm(d_id_user);
        LOOP
            FETCH comm INTO c_nr_comenzi, c_nr_angajati;
            EXIT WHEN comm%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('Nr comenzi: ' || c_nr_comenzi);
            DBMS_OUTPUT.PUT_LINE('Nr angajati care au lucrat la acele comenzi: ' || c_nr_angajati);
        END LOOP;
        IF comm%ROWCOUNT =0 THEN
            DBMS_OUTPUT.PUT_LINE('Utilizatorul nu a plasat nicio comanda');
            EXIT;
        END IF;
        CLOSE comm;
        DBMS_OUTPUT.PUT_LINE('Aceste comenzi s-au facut pe urmatoarele numere de telefon si la urmatoarele adrese: ');
        LOOP
            FETCH v_cursor INTO ref_tel, ref_adresa;
            EXIT WHEN v_cursor%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('Adresa: '||ref_adresa||' Nr telefon: '||ref_tel);
        END LOOP;
    END LOOP;
    CLOSE date_personale;
   EXCEPTION
    WHEN exceptia_mea THEN
     RAISE_APPLICATION_ERROR (-20145, 'Nu ati introdus date corecte de la tastatura!');
    WHEN others THEN
     RAISE_APPLICATION_ERROR (SQLCODE, SQLERRM);
END;
/

BEGIN
utilizator_comerciant('argint');
END;
/  
BEGIN
utilizator_comerciant('argi');
END;
/ 
commit;


--8. Formula?i în limbaj natural o problem? pe care s? o rezolva?i folosind un subprogram stocat
--independent de tip func?ie care s? utilizeze într-o singur? comand? SQL 3 dintre tabelele definite.
--Defini?i minim 2 excep?ii proprii. Apela?i subprogramul astfel încât s? eviden?ia?i toate cazurile
--definite ?i tratate.
--enunt:Sa se obtina codurile angajatilor numele si productivitatea celor care sunt atasati la 
--toate activitatile care au starea de activitate 'in desfasurare' si se desfasoara dupa ora 09 dimineata
select * from activitate;
select * from contabil;
select * from activitate;
select * from angajat;
select * from istoric;
commit;
desc activitate;
CREATE OR REPLACE TYPE obiect_activitati IS OBJECT (id_ang NUMBER(4),
                                                    nume VARCHAR2(35),
                                                    productivitate VARCHAR2(35));
/ 
CREATE OR REPLACE TYPE tablou_obiecte_a IS TABLE OF obiect_activitati; 
/
CREATE OR REPLACE FUNCTION activitati (p_ora activitate.ora%TYPE default '09:00',p_stare activitate.stare_curenta%TYPE default 'in desfasurare')
    RETURN tablou_obiecte_a IS tablou_act tablou_obiecte_a;
    exceptie_ora EXCEPTION;
    exceptie_stare EXCEPTION;
    exceptie_null EXCEPTION;
BEGIN
IF NOT REGEXP_LIKE(p_ora, '^(0[0-9]|1[0-9]|2[0-4]):([0-5][0-9])$') THEN
    RAISE exceptie_ora;
END IF;
IF p_stare!='in desfasurare' AND p_stare!='anulata' AND  p_stare!='finalizata'THEN
    RAISE exceptie_stare;
END IF;
SELECT obiect_activitati(a.id_angajat, nume, productivitate)
BULK COLLECT INTO tablou_act
FROM organizeaza o JOIN angajat a ON (o.id_angajat = a.id_angajat)
                   JOIN istoric i ON (i.id_angajat = a.id_angajat)
WHERE id_activitate in (SELECT id_activitate
                        FROM ACTIVITATE
                        WHERE ora = p_ora AND stare_curenta = p_stare )
GROUP BY a.id_angajat, nume, productivitate
HAVING count(id_activitate)= (SELECT count(*)
                            FROM ACTIVITATE
                            WHERE ora = p_ora AND stare_curenta = p_stare);

IF CARDINALITY(tablou_act)=0 THEN
RAISE exceptie_null;
END IF;
RETURN tablou_act;
 EXCEPTION
    WHEN exceptie_ora THEN
     RAISE_APPLICATION_ERROR (-20146, 'Nu ati introdus prima valoare sub format de ora');
     RETURN NULL;
     WHEN exceptie_stare THEN
     RAISE_APPLICATION_ERROR (-20147, 'Nu ati introdus a doua valoare corect ');
     RETURN NULL;
     WHEN exceptie_null THEN
     RAISE_APPLICATION_ERROR (-20148, 'Nu s-au gasit angajati care sa indeplineasca criteriile cerute');
     RETURN NULL;
     WHEN others THEN
     RAISE_APPLICATION_ERROR (SQLCODE, SQLERRM);
     RETURN NULL;
END;
/
--testare cand nu se apeleaza nicio exceptie
DECLARE
v_result tablou_obiecte_a;
v_id NUMBER(4);
v_nume VARCHAR2(35);
v_prod VARCHAR2(35);
BEGIN
    v_result:=activitati('09:00','in desfasurare');
    DBMS_OUTPUT.PUT_LINE('Angajatii sunt:');
    FOR i in v_result.FIRST..v_result.LAST LOOP
        v_id:=v_result(i).id_ang;
        v_nume:= v_result(i).nume;
        v_prod:= v_result(i).productivitate;
         DBMS_OUTPUT.PUT_LINE('Nume: '||v_nume||' id: '||v_id||' productivitatea: '||v_prod);
    END LOOP;
END;
/
--testare cand se afiseaza exceptie_ora
DECLARE
v_result tablou_obiecte_a;
v_id NUMBER(4);
v_nume VARCHAR2(35);
v_prod VARCHAR2(35);
BEGIN
    v_result:=activitati('99:00','in desfasurare');
    DBMS_OUTPUT.PUT_LINE('Angajatii sunt:');
    FOR i in v_result.FIRST..v_result.LAST LOOP
        v_id:=v_result(i).id_ang;
        v_nume:= v_result(i).nume;
        v_prod:= v_result(i).productivitate;
         DBMS_OUTPUT.PUT_LINE('Nume: '||v_nume||' id: '||v_id||' productivitatea: '||v_prod);
    END LOOP;
END;
/
--testare cand se afiseaza exceptie_stare
DECLARE
v_result tablou_obiecte_a;
v_id NUMBER(4);
v_nume VARCHAR2(35);
v_prod VARCHAR2(35);
BEGIN
    v_result:=activitati('09:00','in desfasurareeee');
    DBMS_OUTPUT.PUT_LINE('Angajatii sunt:');
    FOR i in v_result.FIRST..v_result.LAST LOOP
        v_id:=v_result(i).id_ang;
        v_nume:= v_result(i).nume;
        v_prod:= v_result(i).productivitate;
         DBMS_OUTPUT.PUT_LINE('Nume: '||v_nume||' id: '||v_id||' productivitatea: '||v_prod);
    END LOOP;
END;
/
--testare cand nu se gasesc angajati care sa respecte criteriile
DECLARE
v_result tablou_obiecte_a;
v_id NUMBER(4);
v_nume VARCHAR2(35);
v_prod VARCHAR2(35);
BEGIN
    v_result:=activitati('09:11','in desfasurare');
    DBMS_OUTPUT.PUT_LINE('Angajatii sunt:');
    FOR i in v_result.FIRST..v_result.LAST LOOP
        v_id:=v_result(i).id_ang;
        v_nume:= v_result(i).nume;
        v_prod:= v_result(i).productivitate;
         DBMS_OUTPUT.PUT_LINE('Nume: '||v_nume||' id: '||v_id||' productivitatea: '||v_prod);
    END LOOP;
END;
/
--9. Formula?i în limbaj natural o problem? pe care s? o rezolva?i folosind un subprogram stocat
--independent de tip procedur? care s? utilizeze într-o singur? comand? SQL 5 dintre tabelele
--definite. Trata?i toate excep?iile care pot ap?rea, incluzând excep?iile NO_DATA_FOUND ?i
--TOO_MANY_ROWS. Apela?i subprogramul astfel încât s? eviden?ia?i toate cazurile tratate.
--
--Enunt: Sa se gaseasca animalul ingrijit de fermierul care are experienta în domeniu maxima pentru specializarile
--care au mai mult de o înregistrare în tabelul URMEAZA,iar data de înfiintare a specializarii este
--ulterioara datei trimise ca parametru functiei 
--Defaultul va fi data de 1 ianuarie 1986.
--daca exista mai mule specializari care indeplinesc conditiile si sunt urmate de mia multi fermieri sau daca fermierul
--care indeplineste conditiile ingrijeste mai multe animale se va afisa un mesaj corespunzator
--de asemenea daca nu exista animale sau fermieri care sa indeplineasca conditiile se va afisa un mesaj corespunzator
select * from angajat;
select * from animal;
select * from ingrijeste;
select * from specializare;
select * from urmeaza;
update  ingrijeste set id_angajat=202 where id_animal=86;
commit;
drop function nume_animal;
CREATE OR REPLACE PROCEDURE nume_animal (p_data_infiintarii VARCHAR default '1986-01-01', v_rasa OUT animal.rasa%TYPE) IS 
     v_data DATE;
    exceptie_data EXCEPTION;
    exceptie_data_viitor EXCEPTION;
    
BEGIN
    IF NOT REGEXP_LIKE(p_data_infiintarii, '^\d{4}-\d{2}-\d{2}$') THEN
        RAISE exceptie_data;
    END IF;
    
    v_data:=TO_DATE(p_data_infiintarii, 'YYYY-MM-DD');
    IF v_data >SYSDATE THEN
        RAISE exceptie_data_viitor;
    END IF;
    SELECT an.rasa
    INTO v_rasa
    FROM urmeaza u
        JOIN fermier f ON u.id_angajat = f.id_angajat
        JOIN specializare s ON u.id_specializare = s.id_specializare
        JOIN angajat a ON u.id_angajat = a.id_angajat
        JOIN ingrijeste i ON a.id_angajat = i.id_angajat
        JOIN animal an ON an.id_animal = i.id_animal
        WHERE (u.experienta_in_domeniu, u.id_specializare) IN (
            SELECT MAX(experienta_in_domeniu), id_specializare
            FROM urmeaza
            GROUP BY id_specializare
            HAVING COUNT(*) > 1
        )
        AND s.data_infiintarii > v_data;
                
    EXCEPTION
	WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003,'Nu exista niciun fermier care sa respecte cerintele problemei sau nu exista niciun animal care sa fie ingrijit de acel fermier');
	WHEN TOO_MANY_ROWS THEN
		RAISE_APPLICATION_ERROR(-20004,'Exista mai multe animale ingrijite de acest fermier sau mai multi fermieri care respecta cerinta  ');
    WHEN exceptie_data THEN
        RAISE_APPLICATION_ERROR(-20005,'Ati introdus un format al datei incorect!');  
    WHEN exceptie_data_viitor THEN
        RAISE_APPLICATION_ERROR(-20006,'Ati introdus o data din viitor!');
	WHEN OTHERS THEN
		RAISE_APPLICATION_ERROR(SQLCODE,SQLERRM);
        
END;
/
--test pt cand exista un fermier care sa indeplineasca criteriile si exista un animal ingrijit de acest fermier
DECLARE
 v_nume animal.rasa%TYPE;
BEGIN
    nume_animal('1986-01-01',v_nume);
    DBMS_OUTPUT.PUT_LINE('Animal: '|| v_nume);
END;
/
--test pt data incorect
DECLARE
 v_nume animal.rasa%TYPE;
BEGIN
    nume_animal('abc',v_nume);
    DBMS_OUTPUT.PUT_LINE('Animal: '|| v_nume);
END;
/
--test pt data data din viitor
DECLARE
 v_nume animal.rasa%TYPE;
BEGIN
    nume_animal('2025-01-01',v_nume);
    DBMS_OUTPUT.PUT_LINE('Animal: '|| v_nume);
END;
/
--test pentru cand exista mai multe animale ingrijite de fermierul care indeplineste criteriile sau mai multi fermieri

DECLARE
 v_nume animal.rasa%TYPE;
BEGIN
    nume_animal('1944-01-01', v_nume);
    DBMS_OUTPUT.PUT_LINE('Animal: '|| v_nume);
END;
/
--test pt cand nu exista animale ingrijite sau fermieri sa respecte criteriile
DECLARE
 v_nume animal.rasa%TYPE;
BEGIN
    nume_animal('2023-01-01',v_nume);
    DBMS_OUTPUT.PUT_LINE('Animal: '|| v_nume);
END;
/
commit;


--10. Definiti un trigger de tip LMD la nivel de comanda. Declansati trigger-ul.
--Vom ilustra triggerul apeland o procedura care insereaza, updateaza si sterge din tabelul utilizator.
--Se vor gasi utilizatorii care au cele mai multe comenzi. Se va updata ratingul lor la 'aur'. Daca numarul lor e mai mare decat parametrul procedurii
--se va mai insera un utilizator in tabelul utilizator, daca este mai mic se va sterge un utilizator random din tabelul comanda. 
--ENUNT:
--Sa se salveze intr-un tabel informativ utilizator_info  descriile actiunilor facute de un utilizator asupra tabelului  utilizator
--Prin descrieri se intelege:
-- -numele actiunii (insert,delete si update sunt pe tabelul utilizator)
--      +se poate insera doar in intervalul orar 09:00-17:00
--      + poate sterge din tabel doar utilizatorul 'dariapirvulescu18'
--      +se pot updata  tabelul doar in ziua de marti
-- -data in care a fost facuta actiunea
-- -numele utilizatorului care a facut actiunea
-- -ora la care s-a facut actiunea
-- -daca s-au apelat exceptii, codul si numele


select * from utilizator;
update utilizator set rating_vanzator='argint' where id_user=72;
update utilizator set rating_vanzator='bronz' where id_user=74;

delete from utilizator where id_user=95;
commit;
select * from comanda;
SELECT
    t.*,
    t.exceptii.v_error_message AS error_message,
    t.exceptii.v_error_cod AS error_code
FROM
   utilizator_info t;

select * from utilizator_info;
rollback;
--tabel pentru a insera informatiile
CREATE OR REPLACE TYPE erori_ex10 AS OBJECT (v_error_message VARCHAR(300),
                               v_error_cod NUMBER(8));
/
CREATE TABLE utilizator_info(id_operatie NUMBER PRIMARY KEY,
                             nume_actiune VARCHAR2(25),
                             data_actiune DATE,
                             ora_actiune TIMESTAMP,
                             nume_utilizator VARCHAR2(25),
                             exceptii erori_ex10
                            );
/
drop table utilizator_info;

CREATE SEQUENCE SEQ_UT_INFO
INCREMENT by 1
START WITH 1
MAXVALUE 170
NOCYCLE;
/

CREATE OR REPLACE TRIGGER trig_ex10
    BEFORE INSERT OR UPDATE OR DELETE ON utilizator
DECLARE
    v_error_message VARCHAR2(255) := 'Nu s-a intampinat nicio eroare';
    v_error_cod NUMBER := 0;
    exceptia_mea EXCEPTION;
BEGIN
    IF INSERTING THEN   
        IF TO_CHAR(SYSDATE, 'HH24:MI') NOT BETWEEN '09:00' AND '17:00' THEN
            v_error_message := 'Nu puteti sa inserati date in tabelul utilizator in afara orelor de munca!';
            v_error_cod := -20001;
        END IF;
        INSERT INTO utilizator_info(id_operatie,nume_actiune,data_actiune,nume_utilizator,ora_actiune,exceptii)
        VALUES (SEQ_UT_INFO.NEXTVAL,'INSERTING',CURRENT_TIMESTAMP,USER,SYSTIMESTAMP,erori_ex10(v_error_message, v_error_cod));
    END IF;

    v_error_message := 'Nu s-a intampinat nicio eroare';
    v_error_cod := 0;

    IF UPDATING THEN   
        IF TO_CHAR (SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH') IN ('THU')  THEN
            v_error_message := 'Nu puteti sa actualizati datele in ziua de JOI';
            v_error_cod := -20002;
        END IF;
        INSERT INTO utilizator_info(id_operatie,nume_actiune,data_actiune,nume_utilizator,ora_actiune,exceptii)
        VALUES (SEQ_UT_INFO.NEXTVAL,'UPDATING',CURRENT_TIMESTAMP,USER,SYSTIMESTAMP,erori_ex10(v_error_message, v_error_cod));
    END IF;

    v_error_message := 'Nu s-a intampinat nicio eroare';
    v_error_cod := 0;

    IF DELETING THEN 
         IF USER!='C##DARIAPIRVULESCU18' THEN
            v_error_message := 'Nu aveti drepturi sa stergeti acest user';
            v_error_cod := -20003;
         END IF;
        INSERT INTO utilizator_info(id_operatie,nume_actiune,data_actiune,nume_utilizator,ora_actiune,exceptii)
        VALUES ( SEQ_UT_INFO.NEXTVAL,'DELETING',CURRENT_TIMESTAMP,USER,SYSTIMESTAMP,erori_ex10(v_error_message, v_error_cod));
    END IF;

    IF v_error_cod != 0 THEN
        RAISE exceptia_mea;
    END IF;
     DBMS_OUTPUT.PUT_LINE('S-a declansat triggerul');
    EXCEPTION
    WHEN exceptia_mea THEN
        RAISE_APPLICATION_ERROR(-20345, 'S-au produs 1 sau mai multe exceptii. Verifica tabelul utilizator_info pentru a vedea!');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(SQLCODE, SQLERRM);
END;
/


ALTER TRIGGER trig_ex10 DISABLE;
--procedura pentru a testa triggerul
CREATE OR REPLACE PROCEDURE operatii_comanda_utilizator (nr_maxim NUMBER DEFAULT 3) IS  
    TYPE tablou_indexat IS TABLE OF utilizator.id_user%TYPE INDEX BY BINARY_INTEGER;
    t_ind tablou_indexat;
    t_ind2 tablou_indexat;
    
    v_count NUMBER;
    v_random_index NUMBER;
    v_random_user_id NUMBER;
    exceptia_mea EXCEPTION;
BEGIN
    IF nr_maxim<0 THEN
    RAISE exceptia_mea;
    END IF;
    WITH subq AS (
        SELECT id_user, COUNT(*) AS numar_comenzi
        FROM comanda
        GROUP BY id_user
        ORDER BY COUNT(*) DESC
    )
    SELECT u.id_user 
    BULK COLLECT INTO t_ind
    FROM utilizator u
    JOIN subq s ON u.id_user = s.id_user
    WHERE s.numar_comenzi = (SELECT max(numar_comenzi)
                             FROM subq
                             );
     --update                        
    FOR i in t_ind.FIRST..t_ind.LAST LOOP
        UPDATE utilizator
        SET rating_vanzator = 'aur'
        WHERE id_user=t_ind(i);
         DBMS_OUTPUT.PUT_LINE('UPDATE');
    END LOOP;
    
    v_count:= t_ind.COUNT;
    
    IF v_count >= nr_maxim THEN
        --insert
        INSERT INTO UTILIZATOR (id_user, nume, prenume,rating_vanzator)
        VALUES(SEQ_UTILIZATOR.NEXTVAL, 'Pirvulescu', 'Daria','bronz');
         DBMS_OUTPUT.PUT_LINE('INSERT');
    ELSE
        --delete
        SELECT id_user
        BULK COLLECT INTO t_ind2
        FROM comanda;
         DBMS_OUTPUT.PUT_LINE('DELETE');
        --alegem un utiliztaor random
        v_random_index := TRUNC(DBMS_RANDOM.VALUE * t_ind2.COUNT) + 1;
        v_random_user_id := t_ind2(v_random_index);
        --trebuie sters mai intai din comanda pentru a nu incalca constrangerea de cheie externa
        DELETE FROM comanda WHERE id_user= v_random_user_id;
        DELETE FROM utilizator WHERE id_user= v_random_user_id;
       
    END IF;
    EXCEPTION
    WHEN exceptia_mea THEN
        RAISE_APPLICATION_ERROR(-20009,'Ati introdus un numar negativ');
	WHEN OTHERS THEN
		RAISE_APPLICATION_ERROR(SQLCODE,SQLERRM); 
END;
/
rollback;
BEGIN
operatii_comanda_utilizator(4);
END;
/
BEGIN
operatii_comanda_utilizator(-2);
END;
/
BEGIN
operatii_comanda_utilizator(2);
END;
/

rollback;
--11.)Definiti un trigger de tip LMD la nivel de linie. Declansati trigger-ul.
--ENUNT:
-- Definiti un trigger de tip LMD la nivel de linie. Un sofer nu poate sa conduca mai mult de 1 camion. 
--Inserarea soferilor se face pe baza tabelului sofer (daca angajatul nu exista in id_sofer el nu poate fi pus in camion_de_marfa).
--Acest tip de trigger poate genera o eroare de MUTATING TABLE 
--Vom exemplifica si cazul in care se genereaza si cazul in care nu se genereaza aceasta eroare.


--trigger MUTATING TABLE 
select * from camion_de_marfa;
select * from sofer;
select * from contabil;
select * from angajat;
rollback;
insert into sofer values(218,'b');
rollback;
CREATE OR REPLACE TRIGGER trig_ex11_mutating
    BEFORE INSERT OR UPDATE OF id_sofer ON camion_de_marfa
    FOR EACH ROW
DECLARE
    v_nr_camioane NUMBER := 0;
    TYPE tablou_indexat IS TABLE OF sofer.id_sofer%TYPE INDEX BY BINARY_INTEGER;
    t_ind tablou_indexat;
    ok BOOLEAN:=FALSE;
BEGIN
    SELECT COUNT(*)
    INTO v_nr_camioane
    FROM camion_de_marfa 
    WHERE id_sofer = :NEW.id_sofer;
    
    SELECT id_sofer
    BULK COLLECT INTO t_ind
    FROM sofer;
    
    FOR i in t_ind.FIRST..t_ind.LAST LOOP
        IF t_ind(i)= :NEW.id_sofer THEN
            ok:=TRUE;
            EXIT;
        END IF;
    END LOOP;
    IF ok=FALSE THEN
        -- Înseamn? c? încerc?m s? inser?m un id_sofer care nu este din tabelul sofer
        RAISE_APPLICATION_ERROR(-20001, 'Incercati sa atribuiti unui angajat care nu este sofer un camion de marfa');
    END IF;

    IF v_nr_camioane >= 1 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Incercati sa atribuiti unui sofer mai mult de 1 camion');
    END IF;

END;
/
INSERT into camion_de_marfa values( SEQ_CAMION_DE_MARFA.NEXTVAL,34,210);--nu da eroare mutating
INSERT into camion_de_marfa values( SEQ_CAMION_DE_MARFA.NEXTVAL,34,211);--incerc sa inserez un angajat care nu e sofer
INSERT into camion_de_marfa values( SEQ_CAMION_DE_MARFA.NEXTVAL,34,206);--incerc sa atribui unui sofer mai multe camioane

INSERT into camion_de_marfa 
SELECT SEQ_CAMION_DE_MARFA.NEXTVAL,34,210
FROM dual; --da eroare mutating

UPDATE camion_de_marfa SET id_sofer=210 WHERE id_camion=40;--da eroare mutating
ALTER Trigger trig_ex11_mutating disable;

--Problema se rezolva prin folosirea unui COMPOUND TRIGGER

CREATE OR REPLACE TRIGGER trig_ex11_corect
    FOR INSERT OR UPDATE OF id_sofer ON camion_de_marfa
COMPOUND TRIGGER
TYPE sofer IS RECORD(id_sofer NUMBER(4),
                   nr_camioane NUMBER(4));
TYPE tablou_indexat1 IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE tablou_indexat2 IS TABLE OF sofer INDEX BY PLS_INTEGER;
        t_ind2 tablou_indexat2;
        t_ind1 tablou_indexat1;
        contor NUMBER(4) := 0;
        ok BOOLEAN:=FALSE;
BEFORE STATEMENT IS
    BEGIN
        contor := 0;
        SELECT id_sofer, COUNT(*)
        BULK COLLECT INTO t_ind2
        FROM camion_de_marfa 
        GROUP BY id_sofer;
END BEFORE STATEMENT;
BEFORE EACH ROW IS 
    BEGIN
        FOR i in 1..t_ind2.LAST LOOP
            IF  t_ind2(i).id_sofer = :NEW.id_sofer AND t_ind2(i).nr_camioane + contor >= 1 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Incercati sa atribuiti unui sofer mai mult de 1 camion');
            END IF;
        END LOOP;
        contor := contor + 1;
        
        SELECT id_sofer
        BULK COLLECT INTO t_ind1
        FROM sofer;
        
        FOR i in t_ind1.FIRST..t_ind1.LAST LOOP
            IF t_ind1(i)= :NEW.id_sofer THEN
                ok:=TRUE;
                EXIT;
            END IF;
        END LOOP;
        IF ok=FALSE THEN
            
            RAISE_APPLICATION_ERROR(-20001, 'Incercati sa atribuiti unui angajat care nu este sofer un camion de marfa');
        END IF;
    END BEFORE EACH ROW;
END trig_ex11_corect;
/
rollback;
INSERT into camion_de_marfa values( SEQ_CAMION_DE_MARFA.NEXTVAL,34,210);--nu da eroare mutating
INSERT into camion_de_marfa values( SEQ_CAMION_DE_MARFA.NEXTVAL,34,211);--incerc sa inserez un angajat care nu e sofer
INSERT into camion_de_marfa values( SEQ_CAMION_DE_MARFA.NEXTVAL,34,206);--incerc sa atribui unui sofer mai multe camioane

INSERT into camion_de_marfa 
SELECT SEQ_CAMION_DE_MARFA.NEXTVAL,34,202
FROM dual; --nu mai da eroare mutating

UPDATE camion_de_marfa SET id_sofer=205 WHERE id_camion=40;-- nu mai da eroare mutating

select * from camion_de_marfa;
select * from sofer;
delete from camion_de_marfa where id_camion=80;
commit;


--12. Defini?i un trigger de tip LDD. Declan?a?i trigger-ul.
--Enunt: Defini?i un trigger de tip LDD care sa insereze intr-un tabel mai multe date despre 
--operatiile facute pe schema 
--Tabelul se va numi trig_ldd_info si va avea
-- +id_info
-- +numele celui care a facut operatia
-- +ce obiect a modificat
-- +ce operatie a facut pe obiectul respectiv
-- +in ce data a facut operatia
-- +daca a intampinat erori in a opera pe obiectele din schema 
-- +host-ul
-- +ip-ul
CREATE SEQUENCE SEQ_trig_ldd
INCREMENT by 1
START WITH 1
MAXVALUE 170
CYCLE;
drop sequence SEQ_trig_ldd;
CREATE TABLE trig_ldd_info( id_info NUMBER(4),
                            nume_utilizator VARCHAR(100),
                            nume_obiect_modificat VARCHAR(100),
                            nume_operatie VARCHAR(100),
                            data DATE,
                            exceptii VARCHAR(3000),
                            host VARCHAR2(30),
                            IP VARCHAR2(30)
);
select * from trig_ldd_info;
CREATE OR REPLACE TRIGGER ldd_trigger_procedure
AFTER CREATE OR ALTER OR DROP OR SERVERERROR  OR LOGON ON SCHEMA
BEGIN
   INSERT INTO trig_ldd_info (id_info, nume_utilizator, nume_obiect_modificat, nume_operatie, data, exceptii, host, IP)
    VALUES (SEQ_trig_ldd.NEXTVAL, USER, SYS.DICTIONARY_OBJ_NAME, SYS.SYSEVENT, SYSDATE, DBMS_UTILITY.FORMAT_ERROR_STACK, SYS_CONTEXT('USERENV', 'HOST'), SYS_CONTEXT('USERENV', 'IP_ADDRESS'));
END;
/

--triger pentru a sterge datele din tabelul trigg_ldd_info
--deoarece acesta se poate supraincarca cu date
CREATE OR REPLACE TRIGGER deletee
BEFORE INSERT ON trig_ldd_info
DECLARE
 v_record_count NUMBER;
 BEGIN
  SELECT COUNT(*) INTO v_record_count FROM trig_ldd_info;
    IF v_record_count >= 10 THEN
        DELETE  from trig_ldd_info;
        DBMS_OUTPUT.PUT_LINE('S-au sters datele din tabelul trig_ldd_info');
        --se va apela o procedura pentru a dezactiva triggerul de tip LDD
        date_trigger();
    END IF;
END;
/
--procedura pentru a afisa date despre triggerul ldd
CREATE OR REPLACE PROCEDURE date_trigger IS TYPE tip_c IS REF CURSOR;
c_user tip_c;
v_status USER_TRIGGERS.STATUS%TYPE;
v_owner USER_TRIGGERS.TABLE_OWNER%TYPE;
v_desc USER_TRIGGERS.DESCRIPTION%TYPE;
BEGIN
    OPEN c_user FOR
        'SELECT STATUS,TABLE_OWNER,DESCRIPTION 
         FROM USER_TRIGGERS 
         WHERE lower(TRIGGER_NAME)=''ldd_trigger_procedure''';
    LOOP
        FETCH c_user INTO v_status,v_owner, v_desc;
		EXIT WHEN c_user%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('Utilizatorul '||v_owner||' are in schema triggerul ldd_trigger_procedure cu statusul: '||v_status||' descris ca:  '||v_desc);
	DBMS_OUTPUT.PUT_LINE('Pentru a nu se mai umple tabelul trigg_ldd_info se recomanda dezactivarea triggerului ldd_trigger_procedure');
    END LOOP;
CLOSE c_user;
END;
/
ALTER TRIGGER ldd_trigger_procedure DISABLE;
ALTER TRIGGER deletee DISABLE;
DROP TRIGGER C##DARIAPIRVULESCU18.ldd_trigger_procedure;
DROP TRIGGER C##DARIAPIRVULESCU18.deletee;


--testare
CREATE TABLE test_table2(id NUMBER, name VARCHAR2(50));
ALTER TABLE test_table2 ADD description2 VARCHAR2(100);
DROP TABLE test_table2;
INSERT INTO test_table2 (id) VALUES (1);

select * from trig_ldd_info;
commit;
rollback;


--13. Defini?i un pachet care s? con?in? toate obiectele definite în cadrul proiectului.
--tipul obiect de la ex il vom lasa inafara pachetlui, iar in pachet
--v-om implementa cerintele returnand de data aceasta o colectie RECORD
CREATE OR REPLACE PACKAGE pack_ex13
IS
--EX6
	 PROCEDURE afisare (nr_specializari OUT NUMBER, p_salariu IN angajat.salariu%TYPE);
--EX7
     PROCEDURE utilizator_comerciant (p_rating IN utilizator.rating_vanzator%TYPE);
--Ex8
    TYPE record_activitati IS RECORD (id_ang NUMBER(4),
                                      nume VARCHAR2(35),
                                     productivitate VARCHAR2(35));
    
    TYPE tablou_record_a IS TABLE OF record_activitati; 

    FUNCTION activitati (p_ora activitate.ora%TYPE default '09:00',p_stare activitate.stare_curenta%TYPE default 'in desfasurare')
    RETURN tablou_record_a;
--Ex9
    PROCEDURE nume_animal (p_data_infiintarii VARCHAR default '1986-01-01', v_rasa OUT animal.rasa%TYPE);
--Ex10-procedura pt a testa triggerul
    PROCEDURE operatii_comanda_utilizator (nr_maxim NUMBER DEFAULT 3); 
--ex12 - procedura pentru a vedea date despre trigger
    PROCEDURE date_trigger; 
END;
/
CREATE OR REPLACE PACKAGE BODY pack_ex13
IS
--EX6
    PROCEDURE afisare (nr_specializari OUT NUMBER, p_salariu IN angajat.salariu%TYPE) IS
    
    --tablou indexat 
        TYPE tablou_indexat IS TABLE OF fermier%ROWTYPE INDEX BY BINARY_INTEGER;
    --tablou imbricat
        TYPE tablou_imbricat1 IS TABLE OF angajat.nume%TYPE;
        TYPE tablou_imbricat2 IS TABLE OF specializare.nume_s%TYPE;
    --vector
        TYPE vector IS VARRAY(15) OF angajat.salariu%TYPE;
    --extra:tip record 
        TYPE fermier_record IS RECORD (
            f_nume angajat.nume%TYPE,
            f_prenume angajat.prenume%TYPE,
            f_salariu angajat.salariu%TYPE
        );
        TYPE date_fermier IS VARRAY(100) OF fermier_record;
        date_fermier_var date_fermier:=date_fermier();
        t_ind tablou_indexat;
        t_imb tablou_imbricat1:= tablou_imbricat1();
        t_spc tablou_imbricat2;
        vec vector:= vector();
        
        v_salariu angajat.salariu%TYPE;
        v_nume angajat.nume%TYPE;
        v_nr NUMBER;
        v_nr_angajati NUMBER;
        v_nr_fermieri NUMBER;
        v_procent NUMBER;
        exceptia_mea EXCEPTION;
    BEGIN
        
    --obtinem angajatul si certificarea acestuia
        SELECT f.id_angajat,f.certificari
        BULK COLLECT INTO  t_ind
        FROM angajat a JOIN fermier f ON (f.id_angajat = a.id_angajat)
                JOIN urmeaza u ON (u.id_angajat = f.id_angajat)
                JOIN specializare s ON (s.id_specializare = u.id_specializare)
        WHERE a.salariu = ( SELECT min(salariu)
                            FROM angajat a2
                            JOIN fermier f2 ON (f2.id_angajat = a2.id_angajat)
                            JOIN urmeaza u2 ON (u2.id_angajat = f2.id_angajat)
                            JOIN specializare s2 ON (s2.id_specializare=u2.id_specializare)
                            WHERE s.id_specializare = s2.id_specializare)
         ORDER BY nume;
        --obtine salariu si nume 
        FOR i in t_ind.FIRST..t_ind.LAST LOOP
            SELECT nume, salariu
            INTO v_nume, v_salariu
            FROM angajat 
            WHERE id_angajat = t_ind(i).id_angajat;
            
            t_imb.extend;
            t_imb(i):= v_nume;
            vec.extend;
            vec(i):= v_salariu;
        END LOOP;
        
        --obtinem specializarea
        SELECT nume_s
        BULK COLLECT INTO  t_spc
        FROM angajat a JOIN fermier f ON (f.id_angajat = a.id_angajat)
                JOIN urmeaza u ON (u.id_angajat = f.id_angajat)
                JOIN specializare s ON (s.id_specializare = u.id_specializare)
        WHERE a.salariu = ( SELECT min(salariu)
                            FROM angajat a2
                            JOIN fermier f2 ON (f2.id_angajat = a2.id_angajat)
                            JOIN urmeaza u2 ON (u2.id_angajat = f2.id_angajat)
                            JOIN specializare s2 ON (s2.id_specializare=u2.id_specializare)
                            WHERE s.id_specializare = s2.id_specializare)
        ORDER BY nume;
        --vedem daca exista specializari fara angajati
        SELECT count(*)
        INTO v_nr
        FROM specializare;
        
        nr_specializari:=CARDINALITY(t_spc);
        
        --afisez datele obtinute 
        FOR i in t_ind.FIRST..t_ind.LAST LOOP
        DBMS_OUTPUT.PUT_LINE('Fermierul cu salariul cel mai mic din specializare: '||t_spc(i)||' este '||t_imb(i)||
        ',avand id-ul: '|| t_ind(i).id_angajat || ', salariul: ' ||vec(i)|| ' si are certificatul: '||t_ind(i).certificari);
        END LOOP;
        IF v_nr != nr_specializari THEN
            DBMS_OUTPUT.PUT_LINE ('Exista specializari in care nu lucreaza nimeni!');
        END IF; 
        
        --aflare procent
        
        IF p_salariu <=0 THEN
          RAISE exceptia_mea;
        END IF;
        
        SELECT count(id_angajat)
        INTO v_nr_angajati
        FROM angajat
        WHERE salariu > p_salariu;
        
        SELECT count(f.id_angajat)
        INTO v_nr_fermieri
        FROM fermier f join angajat a on (f.id_angajat=a.id_angajat)
        WHERE salariu > p_salariu;
       
        
        v_procent := round((v_nr_fermieri*100)/v_nr_angajati,4);
        DBMS_OUTPUT.PUT_LINE('Procentul de fermier cu salariu mai mare: '||v_procent||' %'); 
        SELECT nume, prenume, salariu
        BULK COLLECT INTO date_fermier_var
        FROM fermier f join angajat a on (f.id_angajat=a.id_angajat)
        WHERE salariu > p_salariu;
        --afisare
        FOR i in date_fermier_var.FIRST..date_fermier_var.LAST LOOP
        DBMS_OUTPUT.PUT_LINE('Fermierul: '||date_fermier_var(i).f_nume || ' '||date_fermier_var(i).f_prenume|| ' are salariul: '||date_fermier_var(i).f_salariu);
        END LOOP;
    
        EXCEPTION
        WHEN SUBSCRIPT_OUTSIDE_LIMIT THEN
         RAISE_APPLICATION_ERROR (-20144, 'Incercati sa aceesati nested_tabelul sau varray elementul la o pozitie inafara lui');
        WHEN COLLECTION_IS_NULL THEN
         RAISE_APPLICATION_ERROR (-20145, 'Nu ati initializat colectia de date');
         WHEN ZERO_DIVIDE THEN
         RAISE_APPLICATION_ERROR (-20146, 'Calcularea procentului va impartii la 0 produsul!');
          WHEN exceptia_mea THEN
         RAISE_APPLICATION_ERROR (-20147, 'Salariu nu poate fi un numar negativ sau 0');
         WHEN others THEN
         RAISE_APPLICATION_ERROR (SQLCODE, SQLERRM);
    
    END;
--EX7
    PROCEDURE utilizator_comerciant (p_rating IN utilizator.rating_vanzator%TYPE) IS
    TYPE refcursor IS REF CURSOR;
    CURSOR date_personale IS 
        SELECT id_user, prenume,
            CURSOR (SELECT nr_telefon, adresa
                    FROM comanda c
                    WHERE u.id_user = c.id_user)
        FROM utilizator u
        WHERE rating_vanzator = p_rating;
    CURSOR comm (v_id_user utilizator.id_user%TYPE)IS
            SELECT COUNT(c.id_comanda),COUNT(DISTINCT c.id_angajat)
            FROM comanda c JOIN angajat a ON c.id_angajat = a.id_angajat
            WHERE id_user = v_id_user
            GROUP BY id_user;
    
    v_cursor refcursor;
    d_id_user utilizator.id_user%TYPE;
    d_prenume_user utilizator.prenume%TYPE;
    ref_tel comanda.nr_telefon%TYPE;
    ref_adresa comanda.adresa%TYPE;
    
    c_nr_comenzi NUMBER;
    c_nr_angajati NUMBER;
    
    exceptia_mea EXCEPTION;
    
    BEGIN
        IF p_rating !='aur' AND p_rating !='argint' AND p_rating !='bronz' THEN
        RAISE exceptia_mea;
        END IF;
        OPEN date_personale;
        LOOP
            FETCH date_personale INTO d_id_user, d_prenume_user, v_cursor;
            EXIT WHEN  date_personale%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('-------------------------------------');
            DBMS_OUTPUT.PUT_LINE ('Utilizatorul numit '||d_prenume_user || ' cu id-ul: ' || d_id_user || ' are:');
            DBMS_OUTPUT.PUT_LINE('-------------------------------------');
            OPEN comm(d_id_user);
            LOOP
                FETCH comm INTO c_nr_comenzi, c_nr_angajati;
                EXIT WHEN comm%NOTFOUND;
                DBMS_OUTPUT.PUT_LINE('Nr comenzi: ' || c_nr_comenzi);
                DBMS_OUTPUT.PUT_LINE('Nr angajati care au lucrat la acele comenzi: ' || c_nr_angajati);
            END LOOP;
            IF comm%ROWCOUNT =0 THEN
                DBMS_OUTPUT.PUT_LINE('Utilizatorul nu a plasat nicio comanda');
                EXIT;
            END IF;
            CLOSE comm;
            DBMS_OUTPUT.PUT_LINE('Aceste comenzi s-au facut pe urmatoarele numere de telefon si la urmatoarele adrese: ');
            LOOP
                FETCH v_cursor INTO ref_tel, ref_adresa;
                EXIT WHEN v_cursor%NOTFOUND;
                DBMS_OUTPUT.PUT_LINE('Adresa: '||ref_adresa||' Nr telefon: '||ref_tel);
            END LOOP;
        END LOOP;
        CLOSE date_personale;
       EXCEPTION
        WHEN exceptia_mea THEN
         RAISE_APPLICATION_ERROR (-20145, 'Nu ati introdus date corecte de la tastatura!');
        WHEN others THEN
         RAISE_APPLICATION_ERROR (SQLCODE, SQLERRM);
    END;
--EX8
    FUNCTION activitati (p_ora activitate.ora%TYPE default '09:00',p_stare activitate.stare_curenta%TYPE default 'in desfasurare')
    RETURN tablou_record_a IS tablou_act tablou_record_a;
    exceptie_ora EXCEPTION;
    exceptie_stare EXCEPTION;
    exceptie_null EXCEPTION;
    BEGIN
    IF NOT REGEXP_LIKE(p_ora, '^(0[0-9]|1[0-9]|2[0-4]):([0-5][0-9])$') THEN
        RAISE exceptie_ora;
    END IF;
    IF p_stare!='in desfasurare' AND p_stare!='anulata' AND  p_stare!='finalizata'THEN
        RAISE exceptie_stare;
    END IF;
    SELECT a.id_angajat, nume, productivitate
    BULK COLLECT INTO tablou_act
    FROM organizeaza o JOIN angajat a ON (o.id_angajat = a.id_angajat)
                       JOIN istoric i ON (i.id_angajat = a.id_angajat)
    WHERE id_activitate in (SELECT id_activitate
                            FROM ACTIVITATE
                            WHERE ora = p_ora AND stare_curenta = p_stare )
    GROUP BY a.id_angajat, nume, productivitate
    HAVING count(id_activitate)= (SELECT count(*)
                                FROM ACTIVITATE
                                WHERE ora = p_ora AND stare_curenta = p_stare);
    
    IF CARDINALITY(tablou_act)=0 THEN
    RAISE exceptie_null;
    END IF;
    RETURN tablou_act;
     EXCEPTION
        WHEN exceptie_ora THEN
         RAISE_APPLICATION_ERROR (-20146, 'Nu ati introdus prima valoare sub format de ora');
         RETURN NULL;
         WHEN exceptie_stare THEN
         RAISE_APPLICATION_ERROR (-20147, 'Nu ati introdus a doua valoare corect ');
         RETURN NULL;
         WHEN exceptie_null THEN
         RAISE_APPLICATION_ERROR (-20148, 'Nu s-au gasit angajati care sa indeplineasca criteriile cerute');
         RETURN NULL;
         WHEN others THEN
         RAISE_APPLICATION_ERROR (SQLCODE, SQLERRM);
         RETURN NULL;
    END;
--EX9
    PROCEDURE nume_animal (p_data_infiintarii VARCHAR default '1986-01-01', v_rasa OUT animal.rasa%TYPE) IS 
         v_data DATE;
        exceptie_data EXCEPTION;
        exceptie_data_viitor EXCEPTION;
        
    BEGIN
        IF NOT REGEXP_LIKE(p_data_infiintarii, '^\d{4}-\d{2}-\d{2}$') THEN
            RAISE exceptie_data;
        END IF;
        
        v_data:=TO_DATE(p_data_infiintarii, 'YYYY-MM-DD');
        IF v_data >SYSDATE THEN
            RAISE exceptie_data_viitor;
        END IF;
        SELECT an.rasa
        INTO v_rasa
        FROM urmeaza u
            JOIN fermier f ON u.id_angajat = f.id_angajat
            JOIN specializare s ON u.id_specializare = s.id_specializare
            JOIN angajat a ON u.id_angajat = a.id_angajat
            JOIN ingrijeste i ON a.id_angajat = i.id_angajat
            JOIN animal an ON an.id_animal = i.id_animal
            WHERE (u.experienta_in_domeniu, u.id_specializare) IN (
                SELECT MAX(experienta_in_domeniu), id_specializare
                FROM urmeaza
                GROUP BY id_specializare
                HAVING COUNT(*) > 1
            )
            AND s.data_infiintarii > v_data;
                    
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20003,'Nu exista niciun fermier care sa respecte cerintele problemei sau nu exista niciun animal care sa fie ingrijit de acel fermier');
        WHEN TOO_MANY_ROWS THEN
            RAISE_APPLICATION_ERROR(-20004,'Exista mai multe animale ingrijite de acest fermier sau mai multi fermieri care respecta cerinta  ');
        WHEN exceptie_data THEN
            RAISE_APPLICATION_ERROR(-20005,'Ati introdus un format al datei incorect!');  
        WHEN exceptie_data_viitor THEN
            RAISE_APPLICATION_ERROR(-20006,'Ati introdus o data din viitor!');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(SQLCODE,SQLERRM);
            
    END;

--ex10 procedura pentru a testa triggerul
    PROCEDURE operatii_comanda_utilizator (nr_maxim NUMBER DEFAULT 3) IS  
        TYPE tablou_indexat IS TABLE OF utilizator.id_user%TYPE INDEX BY BINARY_INTEGER;
        t_ind tablou_indexat;
        t_ind2 tablou_indexat;
        
        v_count NUMBER;
        v_random_index NUMBER;
        v_random_user_id NUMBER;
        exceptia_mea EXCEPTION;
    BEGIN
        IF nr_maxim<0 THEN
        RAISE exceptia_mea;
        END IF;
        WITH subq AS (
            SELECT id_user, COUNT(*) AS numar_comenzi
            FROM comanda
            GROUP BY id_user
            ORDER BY COUNT(*) DESC
        )
        SELECT u.id_user 
        BULK COLLECT INTO t_ind
        FROM utilizator u
        JOIN subq s ON u.id_user = s.id_user
        WHERE s.numar_comenzi = (SELECT max(numar_comenzi)
                                 FROM subq
                                 );
         --update                        
        FOR i in t_ind.FIRST..t_ind.LAST LOOP
            UPDATE utilizator
            SET rating_vanzator = 'aur'
            WHERE id_user=t_ind(i);
            
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('UPDATE');
        v_count:= t_ind.COUNT;
        
        IF v_count >= nr_maxim THEN
            --insert
            INSERT INTO UTILIZATOR (id_user, nume, prenume,rating_vanzator)
            VALUES(SEQ_UTILIZATOR.NEXTVAL, 'Pirvulescu', 'Daria','bronz');
              DBMS_OUTPUT.PUT_LINE('INSERT');
        ELSE
            --delete
            SELECT id_user
            BULK COLLECT INTO t_ind2
            FROM comanda;
            DBMS_OUTPUT.PUT_LINE('DELETE');
            --alegem un utiliztaor random
            v_random_index := TRUNC(DBMS_RANDOM.VALUE * t_ind2.COUNT) + 1;
            v_random_user_id := t_ind2(v_random_index);
            --trebuie sters mai intai din comanda pentru a nu incalca constrangerea de cheie externa
            DELETE FROM comanda WHERE id_user= v_random_user_id;
            DELETE FROM utilizator WHERE id_user= v_random_user_id;
           
        END IF;
        EXCEPTION
        WHEN exceptia_mea THEN
            RAISE_APPLICATION_ERROR(-20009,'Ati introdus un numar negativ');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(SQLCODE,SQLERRM); 
    END;
--ex12 -procedura pentru a afisa date despre trigger
    PROCEDURE date_trigger IS TYPE tip_c IS REF CURSOR;
    c_user tip_c;
    v_status USER_TRIGGERS.STATUS%TYPE;
    v_owner USER_TRIGGERS.TABLE_OWNER%TYPE;
    v_desc USER_TRIGGERS.DESCRIPTION%TYPE;
    BEGIN
        OPEN c_user FOR
            'SELECT STATUS,TABLE_OWNER,DESCRIPTION 
             FROM USER_TRIGGERS 
             WHERE lower(TRIGGER_NAME)=''ldd_trigger_procedure''';
        LOOP
            FETCH c_user INTO v_status,v_owner, v_desc;
            EXIT WHEN c_user%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Utilizatorul '||v_owner||' are in schema triggerul ldd_trigger_procedure cu statusul: '||v_status||' descris ca:  '||v_desc);
        DBMS_OUTPUT.PUT_LINE('Pentru a nu se mai umple tabelul trigg_ldd_info se recomanda dezactivarea triggerului ldd_trigger_procedure');
        END LOOP;
    CLOSE c_user;
    END;
END;
/
--apelare

--EX6
--calcularea imparte procentul la 0
DECLARE
    nr_specializari NUMBER;
BEGIN
    pack_ex13.afisare(nr_specializari,4563456789);
    DBMS_OUTPUT.PUT_LINE('S-au afisat: '||nr_specializari|| ' rezultate din prima interogare');
END;
/
--se afiseaza 8 fermieri
DECLARE
    nr_specializari NUMBER;
BEGIN
    pack_ex13.afisare(nr_specializari,4569);
    DBMS_OUTPUT.PUT_LINE('S-au afisat: '||nr_specializari|| ' rezultate din prima interogare');
END;
/
--salariul nu poate fi negativ
DECLARE
    nr_specializari NUMBER;
BEGIN
    pack_ex13.afisare(nr_specializari,-5);
    DBMS_OUTPUT.PUT_LINE('S-au afisat: '||nr_specializari|| ' rezultate din prima interogare');
END;
/

--EX7 
--se afiseaza date
BEGIN
pack_ex13.utilizator_comerciant('argint');
END;
/  
--nu sunt bune datele de la tastatura
BEGIN
pack_ex13.utilizator_comerciant('argi');
END;
/ 

--EX8
--testare cand nu se apeleaza nicio exceptie
DECLARE
v_result pack_ex13.tablou_record_a;
v_id NUMBER(4);
v_nume VARCHAR2(35);
v_prod VARCHAR2(35);
BEGIN
    v_result:=pack_ex13.activitati('09:00','in desfasurare');
    DBMS_OUTPUT.PUT_LINE('Angajatii sunt:');
    FOR i in v_result.FIRST..v_result.LAST LOOP
        v_id:=v_result(i).id_ang;
        v_nume:= v_result(i).nume;
        v_prod:= v_result(i).productivitate;
         DBMS_OUTPUT.PUT_LINE('Nume: '||v_nume||' id: '||v_id||' productivitatea: '||v_prod);
    END LOOP;
END;
/
--testare cand se afiseaza exceptie_ora
DECLARE
v_result pack_ex13.tablou_record_a;
v_id NUMBER(4);
v_nume VARCHAR2(35);
v_prod VARCHAR2(35);
BEGIN
    v_result:=pack_ex13.activitati('99:00','in desfasurare');
    DBMS_OUTPUT.PUT_LINE('Angajatii sunt:');
    FOR i in v_result.FIRST..v_result.LAST LOOP
        v_id:=v_result(i).id_ang;
        v_nume:= v_result(i).nume;
        v_prod:= v_result(i).productivitate;
         DBMS_OUTPUT.PUT_LINE('Nume: '||v_nume||' id: '||v_id||' productivitatea: '||v_prod);
    END LOOP;
END;
/
--testare cand se afiseaza exceptie_stare
DECLARE
v_result pack_ex13.tablou_record_a;
v_id NUMBER(4);
v_nume VARCHAR2(35);
v_prod VARCHAR2(35);
BEGIN
    v_result:=pack_ex13.activitati('09:00','in desfasurareeee');
    DBMS_OUTPUT.PUT_LINE('Angajatii sunt:');
    FOR i in v_result.FIRST..v_result.LAST LOOP
        v_id:=v_result(i).id_ang;
        v_nume:= v_result(i).nume;
        v_prod:= v_result(i).productivitate;
         DBMS_OUTPUT.PUT_LINE('Nume: '||v_nume||' id: '||v_id||' productivitatea: '||v_prod);
    END LOOP;
END;
/
--testare cand nu se gasesc angajati care sa respecte criteriile
DECLARE
v_result pack_ex13.tablou_record_a;
v_id NUMBER(4);
v_nume VARCHAR2(35);
v_prod VARCHAR2(35);
BEGIN
    v_result:=pack_ex13.activitati('09:11','in desfasurare');
    DBMS_OUTPUT.PUT_LINE('Angajatii sunt:');
    FOR i in v_result.FIRST..v_result.LAST LOOP
        v_id:=v_result(i).id_ang;
        v_nume:= v_result(i).nume;
        v_prod:= v_result(i).productivitate;
         DBMS_OUTPUT.PUT_LINE('Nume: '||v_nume||' id: '||v_id||' productivitatea: '||v_prod);
    END LOOP;
END;
/
--EX9
--test pt cand exista un fermier care sa indeplineasca criteriile si exista un animal ingrijit de acest fermier
DECLARE
 v_nume animal.rasa%TYPE;
BEGIN
   pack_ex13.nume_animal( '1986-01-01',v_nume);
    DBMS_OUTPUT.PUT_LINE('Animal: '|| v_nume);
END;
/
--test pt data data incorect
DECLARE
 v_nume animal.rasa%TYPE;
BEGIN
    pack_ex13.nume_animal('abc',v_nume);
    DBMS_OUTPUT.PUT_LINE('Animal: '|| v_nume);
END;
/
--test pt data data din viitor
DECLARE
 v_nume animal.rasa%TYPE;
BEGIN
    pack_ex13.nume_animal('2025-01-01',v_nume);
    DBMS_OUTPUT.PUT_LINE('Animal: '|| v_nume);
END;
/
--test pentru cand exista mai multe animale ingrijite de fermierul care indeplineste criteriile sau mai multi fermieri

DECLARE
 v_nume animal.rasa%TYPE;
BEGIN
    pack_ex13.nume_animal('1944-01-01',v_nume);
    DBMS_OUTPUT.PUT_LINE('Animal: '|| v_nume);
END;
/
--test pt cand nu exista animale ingrijite sau fermieri sa respecte criteriile
DECLARE
 v_nume animal.rasa%TYPE;
BEGIN
    pack_ex13.nume_animal('2023-01-01',v_nume);
    DBMS_OUTPUT.PUT_LINE('Animal: '|| v_nume);
END;
/
--ex10
BEGIN
pack_ex13.operatii_comanda_utilizator(2);
END;
/
BEGIN
pack_ex13.operatii_comanda_utilizator(-2);
END;
/
--ex12
EXECUTE pack_ex13.date_trigger;
commit;


-- 14.)Definiti un pachet care s? includ? tipuri de date complexe ?i obiecte necesare unui flux de ac?iuni integrate, specifice bazei de date definite (minim 2 tipuri de date, minim 2 func?ii, minim 2 proceduri).
--1.)Procedura statistici va analiza tabelul dat ca parametru  din schema si va afisa
-- +numele tabelului
-- + numele coloanei
-- + datele distincte din coloana
-- + densitatea
-- +cand a fost cel mai mult analizat tabelul
--
--2.) Functia info_istoric va returna un tablou imbricat de recorduri
--selectati angajatii cu productivitate dat de parametrul functiei, data_promovarii lor, salariul, numele si prenumele
--
--3.)Procedura update_ang v-a da update la tabelul angajati astfel:
--daca un angajat are data_promovarii null dar are productivitatea crescuta se va updata data_promovarii cu data de azi
--daca un angajat are productivitatea crescuta si are salariu sub 5000 i se va mari salariul cu 10%,doar daca nu a fost deja promovat.
--
--4.)Functia plante va intoarce un tabel imbricate de record de tabel imbricat in care v-om avea toata plantele ingrijite de toti fermierii
--
--
commit;
CREATE OR REPLACE PACKAGE pack_ex14
IS
    PROCEDURE statistici (p_tabel VARCHAR2 DEFAULT 'ANGAJAT');
    
    TYPE record_istoric IS RECORD(
                                    prod VARCHAR2(25),
                                    data_prom DATE,
                                    sal NUMBER(8),
                                    nume VARCHAR2(25),
                                    prenume VARCHAR2(25)
                                );

    TYPE table_of_record_istoric IS TABLE OF pack_ex14.record_istoric;
    FUNCTION info_istoric (p_productivitate istoric.productivitate%TYPE default 'crescuta') RETURN pack_ex14.table_of_record_istoric;
    PROCEDURE update_ang;
    
    TYPE tablou_imbricat_plante IS TABLE OF planta.denumire%TYPE;
    TYPE record_fermier IS RECORD(id_fermier NUMBER(4),
                                 tabel_planta tablou_imbricat_plante
                                    );
    TYPE tablou_imbricat_fermieri IS TABLE OF  record_fermier;   
    FUNCTION plante_f RETURN pack_ex14.tablou_imbricat_fermieri;
END;
/



CREATE OR REPLACE PACKAGE BODY pack_ex14
IS
    
    PROCEDURE statistici (p_tabel VARCHAR2 DEFAULT 'ANGAJAT') IS 
       ex EXCEPTION;
       nr NUMBER;
       v_column_name    all_tab_columns.column_name%TYPE;
       v_num_distinct   all_tab_columns.num_distinct%TYPE;
       v_density        all_tab_columns.density%TYPE;
       v_most_analyzed  all_tab_columns.last_analyzed%TYPE;
       col SYS_REFCURSOR;
    BEGIN
       SELECT COUNT(*)
       INTO nr
       FROM user_tables
       WHERE table_name = UPPER(p_tabel); 
    
       IF nr = 0 THEN
          RAISE ex;
       END IF;
       
       DBMS_OUTPUT.PUT_LINE('Numele tabelului: ' || p_tabel);
       
       OPEN col FOR SELECT column_name, num_distinct, density, last_analyzed
                   FROM all_tab_columns
                   WHERE table_name = UPPER(p_tabel);
       LOOP
         FETCH col INTO  v_column_name,v_num_distinct,v_density,v_most_analyzed ;
         EXIT WHEN col%NOTFOUND;
         DBMS_OUTPUT.PUT_LINE('Coloana analizata: ' || v_column_name);
         DBMS_OUTPUT.PUT_LINE('Date distincte in coloana: ' || v_num_distinct);
         DBMS_OUTPUT.PUT_LINE('Densitate: ' || TO_CHAR(v_density, '0.99'));
         DBMS_OUTPUT.PUT_LINE('Cea mai frecventa analiza: ' || TO_CHAR(v_most_analyzed, 'YYYY-MM-DD HH24:MI:SS'));
         DBMS_OUTPUT.PUT_LINE('--------------------------------------');
       END LOOP;
    CLOSE col;
    EXCEPTION
       WHEN ex THEN
          RAISE_APPLICATION_ERROR(-20001, 'Nu exista acest tabel in schema.');
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(SQLCODE,SQLERRM); 
    END statistici;
----------------------------------------------------------------------------------------------------
    FUNCTION info_istoric (p_productivitate istoric.productivitate%TYPE default 'crescuta')
    RETURN pack_ex14.table_of_record_istoric IS t_ist pack_ex14.table_of_record_istoric:=pack_ex14.table_of_record_istoric();
    ext EXCEPTION;
    BEGIN
        IF p_productivitate NOT IN( 'crescuta', 'scazuta') THEN
            RAISE ext;
        END IF;
        SELECT productivitate,data_promovarii,salariu,nume,prenume
        BULK COLLECT INTO t_ist
        FROM angajat a JOIN istoric i ON(a.id_angajat=i.id_angajat)
        WHERE productivitate=p_productivitate;
        RETURN t_ist;
       EXCEPTION
            WHEN ext THEN
                RAISE_APPLICATION_ERROR(-20009,'Ati introdus date gresite');
                RETURN NULL;
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(SQLCODE,SQLERRM); 
                RETURN NULL;
        
    END info_istoric;
------------------------------------------------------------------------------   
    PROCEDURE update_ang IS
    TYPE tablou_imbricat IS TABLE OF angajat.id_angajat%TYPE;
    t_ind1 tablou_imbricat := tablou_imbricat();
    t_ind2 tablou_imbricat := tablou_imbricat();
    ok NUMBER(1);
    v_old_salary angajat.salariu%TYPE;
    v_new_salary angajat.salariu%TYPE;

BEGIN
    SELECT i.id_angajat
    BULK COLLECT INTO t_ind1
    FROM angajat a JOIN istoric i ON (a.id_angajat = i.id_angajat)
    WHERE productivitate = 'crescuta' AND data_promovarii IS NULL;

    SELECT i.id_angajat
    BULK COLLECT INTO t_ind2
    FROM angajat a JOIN istoric i ON (a.id_angajat = i.id_angajat)
    WHERE productivitate = 'crescuta' AND salariu < 5000;

    FOR i IN t_ind1.FIRST..t_ind1.LAST LOOP
        UPDATE istoric SET data_promovarii = SYSDATE WHERE id_angajat = t_ind1(i);
        DBMS_OUTPUT.PUT_LINE('UPDATE data_promovarii');
    END LOOP;

    FOR i IN t_ind2.FIRST..t_ind2.LAST LOOP
        ok := 1;
        FOR j IN t_ind1.FIRST..t_ind1.LAST LOOP
            IF t_ind1(j) = t_ind2(i) THEN
                ok := 0;
            END IF;
        END LOOP;
        IF ok = 1 THEN
            SELECT salariu INTO v_old_salary FROM angajat WHERE id_angajat = t_ind2(i);
            UPDATE angajat SET salariu = salariu * 1.1 WHERE id_angajat = t_ind2(i);
            SELECT salariu INTO v_new_salary FROM angajat WHERE id_angajat = t_ind2(i);
            DBMS_OUTPUT.PUT_LINE('UPDATE salariu pentru angajatul ' || t_ind2(i));
            DBMS_OUTPUT.PUT_LINE('Salariu vechi: ' || v_old_salary);
            DBMS_OUTPUT.PUT_LINE('Salariu nou: ' || v_new_salary);
        END IF;
    END LOOP;
END update_ang;
----------------------------------------------------------
     FUNCTION plante_f RETURN pack_ex14.tablou_imbricat_fermieri is 
     t_f pack_ex14.tablou_imbricat_fermieri:=pack_ex14.tablou_imbricat_fermieri(); 
     v_plante tablou_imbricat_plante:=tablou_imbricat_plante();
     v_record record_fermier;
     BEGIN
        FOR i in (SELECT id_angajat FROM fermier)LOOP
            v_plante.delete;
            v_record.id_fermier:=i.id_angajat;
            SELECT denumire
            BULK COLLECT INTO v_plante
            FROM fermier f join ingrijeste ii on (f.id_angajat=ii.id_angajat)
                            join planta p on (ii.id_planta=p.id_planta)
            WHERE ii.id_angajat=i.id_angajat;
            v_record.tabel_planta:=v_plante;
            t_f.extend;
            t_f(t_f.count) := v_record;
        END LOOP;
       RETURN t_f;
     END plante_f;
END pack_ex14;
/
--statistici
BEGIN
pack_ex14.statistici();
END;
/
BEGIN
pack_ex14.statistici('a');
END;
/

--info_istoric
DECLARE
    v_result pack_ex14.table_of_record_istoric:=pack_ex14.table_of_record_istoric();
BEGIN
    v_result := pack_ex14.info_istoric('crescuta');

    FOR i IN 1..v_result.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Productivitate: ' || v_result(i).prod ||
            ', Data Promovarii: ' || NVL(TO_CHAR(v_result(i).data_prom, 'YYYY-MM-DD'),'Angajatul nu a fost niciodata promovat') || 
            ', Salariu: ' || v_result(i).sal ||
            ', Nume: ' || v_result(i).nume ||
            ', Prenume: ' || v_result(i).prenume
        );
    END LOOP;
END;
/
DECLARE
    v_result pack_ex14.table_of_record_istoric;
BEGIN
    v_result := pack_ex14.info_istoric('crescut');

    FOR i IN 1..v_result.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Productivitate: ' || v_result(i).prod ||
            ', Data Promovarii: ' || NVL(TO_CHAR(v_result(i).data_prom, 'YYYY-MM-DD'),'Angajatul nu a fost niciodata promovat') || 
            ', Salariu: ' || v_result(i).sal ||
            ', Nume: ' || v_result(i).nume ||
            ', Prenume: ' || v_result(i).prenume
        );
    END LOOP;
END;
/
--procedura update_ang

EXECUTE pack_ex14.update_ang;
rollback;

--functie plante
DECLARE
v_result pack_ex14.tablou_imbricat_fermieri;
BEGIN
    v_result:=pack_ex14.plante_f;
    FOR i in v_result.FIRST..v_result.LAST LOOP
        DBMS_OUTPUT.PUT_LINE('Angajatul cu id_ul: ' ||v_result(i).id_fermier || ' ingrijeste plantele:');
        FOR j in v_result(i).tabel_planta.FIRST..v_result(i).tabel_planta.LAST LOOP
            DBMS_OUTPUT.PUT_LINE('Denumire: '|| v_result(i).tabel_planta(j));
        END LOOP;
    END LOOP;
END;
/