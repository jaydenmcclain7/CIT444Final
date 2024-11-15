CREATE OR REPLACE DIRECTORY ext_dir AS 'C:\Users\jayde\OneDrive - Indiana University\Desktop\IUPUI Fall 2024\CIT 44400\Final Project';

CREATE TABLE hotel (
    HOTELID NUMBER(38, 0) PRIMARY KEY,    
    NAME    VARCHAR2(100 BYTE) NOT NULL,  
    CITY    VARCHAR2(100 BYTE),           
    COUNTRY VARCHAR2(100 BYTE)            
);

CREATE TABLE review (
    IDREVIEW NUMBER PRIMARY KEY,        
    HOTELID  NUMBER NOT NULL,          
    REVIEW   CLOB,                      
    CONSTRAINT fk_hotel FOREIGN KEY (HOTELID) REFERENCES hotel (HOTELID)  
);



DECLARE
    fh_hotels    UTL_FILE.FILE_TYPE;

    v_hotelid    hotel.HOTELID%TYPE;
    v_name       hotel.NAME%TYPE;
    v_city       hotel.CITY%TYPE;
    v_country    hotel.COUNTRY%TYPE;

    v_line       VARCHAR2(4000);

    v_hotel_count NUMBER := 0;
    v_error_count NUMBER := 0;

BEGIN

    DBMS_OUTPUT.PUT_LINE('Starting Hotels file processing...');

    BEGIN
        fh_hotels := UTL_FILE.FOPEN('EXT_DIR', 'Hotels.csv', 'r');
        DBMS_OUTPUT.PUT_LINE('Opened Hotels file.');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error opening Hotels file: ' || SQLERRM);
            RAISE;
    END;

    LOOP
        BEGIN
            UTL_FILE.GET_LINE(fh_hotels, v_line);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                EXIT;
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error reading Hotels file: ' || SQLERRM);
                EXIT;
        END;

        IF REGEXP_LIKE(v_line, '^\d+') THEN
            v_hotelid := TO_NUMBER(REGEXP_SUBSTR(v_line, '^[^,]+'));
        ELSE
            CONTINUE;
        END IF;
        v_name := REGEXP_SUBSTR(v_line, '[^,]+', 1, 2);  
        v_city := REGEXP_SUBSTR(v_line, '[^,]+', 1, 3); 
        v_country := REGEXP_SUBSTR(v_line, '[^,]+', 1, 4); 

        IF v_name IS NULL OR v_city IS NULL OR v_country IS NULL THEN
            CONTINUE;  
        END IF;

        BEGIN
            INSERT INTO hotel (HOTELID, NAME, CITY, COUNTRY)
            VALUES (v_hotelid, v_name, v_city, v_country);
            
            v_hotel_count := v_hotel_count + 1;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error inserting hotel record: ' || SQLERRM || ' for line: ' || v_line);
                v_error_count := v_error_count + 1;
        END;
    END LOOP;

    UTL_FILE.FCLOSE(fh_hotels);
    DBMS_OUTPUT.PUT_LINE('Closed Hotels file.');

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Hotels file processing completed. Total Hotels Inserted: ' || v_hotel_count || ', Total Errors: ' || v_error_count);

EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            UTL_FILE.FCLOSE(fh_hotels);
        EXCEPTION WHEN OTHERS THEN NULL; END;
        RAISE;
END;
/
