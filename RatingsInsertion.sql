CREATE TABLE Ratings (
    RATINGID INT PRIMARY KEY,
    IDREVIEW INT,
    HOTELID INT,
    CleanlinessScore INT,
    PriceScore INT,
    ServiceScore INT,
    LocationScore INT,
    FOREIGN KEY (IDREVIEW) REFERENCES Review(IDREVIEW), 
    FOREIGN KEY (HOTELID) REFERENCES Hotel(HOTELID)
);

CREATE SEQUENCE Ratings_SEQ
START WITH 1
INCREMENT BY 1
NOCACHE;

DECLARE
    fh_reviews   UTL_FILE.FILE_TYPE;     

    v_idreview   ratings.IDREVIEW%TYPE;  
    v_hotelid    ratings.HOTELID%TYPE;
    v_cleanliness_score   ratings.CleanlinessScore%TYPE;
    v_price_score         ratings.PriceScore%TYPE;
    v_service_score       ratings.ServiceScore%TYPE;
    v_location_score      ratings.LocationScore%TYPE;

    v_line       VARCHAR2(4000);         
    v_rating_count NUMBER := 0;         
    v_error_count  NUMBER := 0;        

BEGIN
    DBMS_OUTPUT.PUT_LINE('Starting Ratings file processing...');

 
    BEGIN
        fh_reviews := UTL_FILE.FOPEN('EXT_DIR', 'processed_reviews_output.csv', 'r');
        DBMS_OUTPUT.PUT_LINE('Opened Ratings file.');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error opening Ratings file: ' || SQLERRM);
            RAISE;
    END;


    LOOP
        BEGIN

            UTL_FILE.GET_LINE(fh_reviews, v_line);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                EXIT;  
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error reading Ratings file: ' || SQLERRM);
                EXIT;
        END;

        BEGIN
            
            v_idreview := TO_NUMBER(REGEXP_SUBSTR(v_line, '^[^,]+'));           
            v_hotelid := TO_NUMBER(REGEXP_SUBSTR(v_line, '[^,]+', 1, 2));       
            v_cleanliness_score := TO_NUMBER(REGEXP_SUBSTR(v_line, '[^,]+', 1, 3)); 
            v_price_score := TO_NUMBER(REGEXP_SUBSTR(v_line, '[^,]+', 1, 4));      
            v_service_score := TO_NUMBER(REGEXP_SUBSTR(v_line, '[^,]+', 1, 5));    
            v_location_score := TO_NUMBER(REGEXP_SUBSTR(v_line, '[^,]+', 1, 6));   

            IF v_idreview IS NULL OR v_hotelid IS NULL OR v_cleanliness_score IS NULL OR 
               v_price_score IS NULL OR v_service_score IS NULL OR v_location_score IS NULL THEN
                CONTINUE; 
            END IF;

  
            BEGIN
                INSERT INTO Ratings (RATINGID, IDREVIEW, HOTELID, CleanlinessScore, PriceScore, ServiceScore, LocationScore)
                VALUES (Ratings_SEQ.NEXTVAL, v_idreview, v_hotelid, v_cleanliness_score, v_price_score, v_service_score, v_location_score);

                v_rating_count := v_rating_count + 1;
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Error inserting rating record: ' || SQLERRM || ' for line: ' || v_line);
                    v_error_count := v_error_count + 1;
            END;

        END; 

    END LOOP;

    UTL_FILE.FCLOSE(fh_reviews);
    DBMS_OUTPUT.PUT_LINE('Closed Ratings file.');

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Ratings file processing completed. Total Ratings Inserted: ' || v_rating_count || ', Total Errors: ' || v_error_count);

EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            UTL_FILE.FCLOSE(fh_reviews);
        EXCEPTION WHEN OTHERS THEN NULL; END;
        RAISE;
END;
/

CREATE TABLE RATINGSAVERAGE (
    HOTELID NUMBER(38,0),
    AVERAGE_CLEANLINESSSCORE NUMBER(38,0),
    AVERAGE_PRICESCORE NUMBER(38,0),
    AVERAGE_SERVICESCORE NUMBER(38,0),
    AVERAGE_LOCATIONSCORE NUMBER(38,0)
);

INSERT INTO RATINGSAVERAGE (HOTELID, AVERAGE_CLEANLINESSSCORE, AVERAGE_PRICESCORE, AVERAGE_SERVICESCORE, AVERAGE_LOCATIONSCORE)
SELECT 
    HOTELID,
    ROUND(AVG(CLEANLINESSSCORE), 0) AS AVERAGE_CLEANLINESSSCORE,
    ROUND(AVG(PRICESCORE), 0) AS AVERAGE_PRICESCORE,
    ROUND(AVG(SERVICESCORE), 0) AS AVERAGE_SERVICESCORE,
    ROUND(AVG(LOCATIONSCORE), 0) AS AVERAGE_LOCATIONSCORE
FROM RATINGS
GROUP BY HOTELID
ORDER BY HOTELID;

select * from ratingsaverage;


SELECT HOTELID, AVERAGE_CLEANLINESSSCORE, AVERAGE_PRICESCORE,
       AVERAGE_SERVICESCORE, AVERAGE_LOCATIONSCORE FROM RATINGSAVERAGE
