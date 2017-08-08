BEGIN
FOR SELECT B_SUBSTR(PROPS,B_STRPOS(:CurName,PROPS), /*Получаем пары "Field=Value,",Если CurName/PrevName не последние в списке PROPS */
STRPOS(',',B_SUBSTR(PROPS,B_STRPOS(:CurName,PROPS),200))),B_SUBSTR(PROPS,B_STRPOS(:PrevName,PROPS),
STRPOS(',',B_SUBSTR(PROPS,B_STRPOS(:PrevName,PROPS),200))),SIGNALID FROM SIGNAL WHERE TYPENAME = :TypeName
INTO :PROP,:PREVPROP,:sigID
DO BEGIN
PROP = TRIM(PROP);
PREVPROP = TRIM(PREVPROP);
SELECT PROPS FROM SIGNAL WHERE SIGNALID = :sigID
INTO :CurProps;
if (PROP = '') then begin /*получаем NAME=VALUE, если CurName последний в списке*/
    SELECT B_SUBSTR(PROPS,B_STRPOS(:CurName,PROPS),100)FROM SIGNAL WHERE SIGNALID= :SIGid
    INTO :PROP;
    UPDATE SIGNAL SET PROPS = STRSTUFF(PROPS,STRPOS(:PROP,:curprops)-1, /*вырезаем полученную строку из PROPS*/
    200,'') WHERE SIGNALID = :sigid;
    PROP = SUBSTR(PROP,1,STRLEN(TRIM(PROP)))|| ','; /*Получаем :PROP (см. первый запрос)*/
end else /*вырезаем полученную строку из PROPS если CurName в списке не последнее*/
    UPDATE SIGNAL SET PROPS = STRSTUFF(PROPS,STRPOS(:PROP,:CurProps),
    STRPOS(',',B_SUBSTR(PROPS,STRPOS(:PROP,:curprops)+1,200))+1,'') WHERE SIGNALID = :sigid;
if ((prevname is NULL) or (prevname = ''))   then /*если CurName устанавливается первым*/
    PREVPROP = '';
else if (PREVPROP ='') then begin /*если CurName устанавливается последним*/
    SELECT B_SUBSTR(PROPS,B_STRPOS(','||:PrevName,PROPS)+1,100) FROM SIGNAL WHERE SIGNALID= :SIGid
    INTO :PREVPROP;
    PREVPROP = SUBSTR(PREVPROP,1,STRLEN(TRIM(PREVPROP)))|| ','; /*Получаем стандартное :PREVPROP (см. первый запрос)*/
end
SELECT PROPS FROM SIGNAL WHERE SIGNALID = :sigID
INTO :CurProps;
if (PREVPROP ='') then /*Если поле устанавливается первым*/
    UPDATE SIGNAL SET PROPS = STRSTUFF(PROPS,0,0,:PROP) WHERE SIGNALID = :sigid; /*на PROPS без STRSTUFF ругается*/
else if (STRPOS(PREVPROP,CurProps)=0) then begin /*вставляет в конец строки*/
    UPDATE SIGNAL SET PROPS = STRSTUFF(PROPS,STRLEN(TRIM(PROPS))+1,0,',' || STRSTUFF(:PROP,STRLEN(TRIM(:PROP)),1,''))
    WHERE SIGNALID = :SIGID;
end else  /*вставляет после PrevName*/
    UPDATE SIGNAL SET PROPS = STRSTUFF(PROPS,STRPOS(:PREVPROP,:CurProps)+STRLEN(TRIM(:PREVPROP)),0,:PROP)
    WHERE SIGNALID = :SIGID;
SELECT PROPS FROM SIGNAL WHERE SIGNALID = :sigID
INTO :CurProps; /*для отслеживания изменений в отладчике*/
END
END

